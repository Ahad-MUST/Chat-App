import 'dart:io';

import 'package:chat/widgets/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool islogin = true;
  bool _isAuthenticating = false;
  final _formkey = GlobalKey<FormState>();
  var Email;
  var Password;
  var Username;
  File? _PickedImage;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    void _submit() async {
      final _isValid = _formkey.currentState!.validate();

      if (!_isValid || !islogin && _PickedImage == null) {
        return;
      }
      _formkey.currentState!.save();
      try {
        setState(() {
          _isAuthenticating = true;
        });
        if (islogin) {
          await _firebase.signInWithEmailAndPassword(
              email: Email, password: Password);
        } else {
          final credentials = await _firebase.createUserWithEmailAndPassword(
              email: Email, password: Password);
          final imagepath = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${credentials.user!.uid}.jpg');

          await imagepath.putFile(_PickedImage!);
          final imageurl = await imagepath.getDownloadURL();

          FirebaseFirestore.instance
              .collection('users')
              .doc(credentials.user!.uid)
              .set({
            'username': Username,
            'ImageURL': imageurl,
            'Email': Email,
          });
        }
      } on FirebaseException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                error.message ?? 'Authentication failed',
              ),
            ),
          ),
        );
        setState(() {
          _isAuthenticating = false;
        });
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Center(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: islogin ? 75 : 25,
                ),
                Image.asset(
                  'images/chat.png',
                  height: 200,
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(
                    alignment: Alignment.center,
                    height: islogin ? height * 0.25 : height * 0.45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!islogin)
                                UserImagePicker(
                                  onPickImage: (Image) {
                                    _PickedImage = Image;
                                  },
                                ),
                              if (!islogin)
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Username'),
                                  validator: (value) {
                                    if (value == null ||
                                        value == '' ||
                                        value.trim().length < 6) {
                                      return 'Username too short';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) => Username = newValue,
                                ),
                              TextFormField(
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                                keyboardType: TextInputType.emailAddress,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (!value!.contains('@')) {
                                    return 'Invalid Email';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  Email = newValue;
                                },
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                                obscureText: true,
                                autocorrect: false,
                                validator: (value) {
                                  if (value!.trim().length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  Password = newValue;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                if (_isAuthenticating)
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                if (!_isAuthenticating)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        islogin
                            ? 'Dont have an account?'
                            : 'Already Have an Account?',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            islogin = !islogin;
                          });
                        },
                        child: Text(
                          islogin ? 'Sign-Up' : 'Login',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 12,
                ),
                if (!_isAuthenticating)
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.login_outlined),
                    label: Text(islogin ? 'Login' : 'Sign-Up'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
