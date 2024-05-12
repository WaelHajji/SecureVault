import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> addElement(String userId, List<String> element) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final elementsRef = userRef.collection('elements');
    await elementsRef.add(element as Map<String, dynamic>);
  }
  Future<void> createUserInFirestore(String uid, String name) async {
    // Validate input
    if (uid.isEmpty || name.isEmpty) {
      throw ArgumentError('Uid and name cannot be empty.');
    }

    final usersCollection = FirebaseFirestore.instance.collection('users');

    try {
      // Create a new document with the user's data
      await usersCollection.doc(uid).set({
        'uid': uid,
        'name': name,
        // Add other user fields if needed (e.g., email, profile picture URL)
      });
      print('User created successfully.');
    } on FirebaseException catch (e) {
      print('Error creating user: ${e.message}');
      // Handle specific errors (optional)
      // e.g., if (e.code == 'already-exists') { ... }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }

  // Sign-up method with additional name field
  Future<void> _signUpWithEmailAndPassword() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,

      );

      final user = credential.user;
      if(user != null){
        createUserInFirestore(user.uid, _nameController.text);

      }
      // After successful signup, potentially store the user's name in Firestore
      // This example omits Firestore integration for brevity, but you can
      // leverage packages like 'cloud_firestore' to achieve this.

      showSnackBar(context,"Sign Up Successful!");

      // Navigate to a different screen (e.g., login screen)
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context,'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context,'The account already exists for that email.');
      } else {
        showSnackBar(context,e.code);
      }
    } catch (e) {
      print(e);
      // Handle other exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _signUpWithEmailAndPassword();
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
