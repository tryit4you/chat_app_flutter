import 'dart:io';

import 'package:chat_app/widgets/auth/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;
  Future<void> _submitAuthForm(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
  ) async {
    AuthResult authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      //...
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child('${authResult.user.uid}.jpg');
      await ref.putFile(image).onComplete;
      final url = await ref.getDownloadURL();
      await Firestore.instance
          .collection('users')
          .document(authResult.user.uid)
          .setData({
        'username': username,
        'email': email,
        'image_url': url,
      });
      setState(() {
        _isLoading = false;
      });
    } on PlatformException catch (error) {
      var message = 'An error occured, please check your credentials!';
      if (error.message != null) {
        message = error.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
