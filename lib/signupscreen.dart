import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hackathon_wael/passwordlistscreen.dart';

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
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PasswordListScreen()));

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
    Size size = MediaQuery.of(context).size;
    double h = size.height, w = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color(0xfff5f7ff),
      ),
      backgroundColor: Color(0xfff5f7ff),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(child:Column(
            children: [
              Image.asset('assets/lock.png'),
              Align(alignment: Alignment.centerLeft,child: Text(
                'Enter your details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0B1533),
                  fontSize: 24,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                ),
              )),
              SizedBox(height: 20,),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when enabled
// Rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when focused
                  ),
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

                  labelText: 'Email / Phone Number',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when enabled
// Rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when focused
                  ),
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
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when enabled
// Rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.transparent, width: 2.0), // Border color and width when focused
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _signUpWithEmailAndPassword();
                  }
                },
                child: Container(
                  width: w,
                  height: h * 0.06,
                  padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 15),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Color(0xFF577DF5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w500,
                          height: 0.07,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
