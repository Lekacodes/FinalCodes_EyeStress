import 'package:app_usage_example/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:math';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp() async {
    final cameras = await availableCameras();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("Signed up: ${userCredential.user!.uid}");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(cameras: cameras)));
    } on FirebaseAuthException catch (e) {
      print("Sign up error: ${e.code} with ${e.message} and ${_emailController.text} and ${_passwordController.text}");
    }
  }

  Future<void> _signIn() async {

    final cameras = await availableCameras();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("Signed in: ${userCredential.user!.uid}");
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(cameras: cameras)));
    } on FirebaseAuthException catch (e) {
      print("Sign in error: ${e.code} with ${e.message} and ${_emailController.text} and ${_passwordController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Auth')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('Sign Up'),
                ),
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

