import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class UserInfoScreen extends StatefulWidget {
  final Function f; // Optional: URL to user's profile image

  const UserInfoScreen({Key? key, required this.f}) : super(key: key);


  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _platformController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Assuming user is already logged in (replace with your authentication logic)
  final _currentUser = FirebaseAuth.instance.currentUser!;
  Future<void> checkAndCreateDocument(String collectionPath, String documentId, Map<String, dynamic> data) async {
    final CollectionReference collection = FirebaseFirestore.instance.collection(collectionPath);
    final docRef = collection.doc(documentId);

    // Perform a transaction to ensure atomicity (optional but recommended)
    await FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      final documentSnapshot = await transaction.get(docRef);
      if (!documentSnapshot.exists) {
        transaction.set(docRef, data);
      }
    });

    // Handle success or failure (optional)
    print('Document checked and created if necessary.');
  }
  Future<void> _storeUserInfo() async {
    final platform = _platformController.text;
    final usernameEmail = _usernameController.text;
    final password = _passwordController.text; // Consider hashing password before storing

    // Create a reference to the user's document in Firestore
    await checkAndCreateDocument("users",_currentUser.uid,{});
    final userRef = FirebaseFirestore.instance.collection('users').doc(_currentUser.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the existing user data or create an empty list if it doesn't exist
      final userData = (await transaction.get(userRef)).data() ?? {};
      print(userData.runtimeType);
      var existingElements = [];
      if(userData.containsKey('passwords'))existingElements = userData['passwords'];

      existingElements.add(platform);
      existingElements.add(usernameEmail);
      existingElements.add(password);

      transaction.update(userRef, {
        'passwords': existingElements,
      });
    });

    print('User information stored in Firestore!');

    // Clear text fields after successful submission (optional)
    _platformController.text = '';
    _usernameController.text = '';
    _passwordController.text = '';
    super.widget.f();
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _platformController,
                decoration: InputDecoration(
                  labelText: 'Platform',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the platform';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username / Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your username or email';
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
                    _storeUserInfo(); // Call the function to store user data
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
