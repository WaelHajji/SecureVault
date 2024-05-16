
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hackathon_wael/locator.dart';
import 'package:hackathon_wael/pages/db/databse_helper.dart';
import 'package:hackathon_wael/pages/models/user.model.dart';
import 'package:hackathon_wael/pages/models/user.model.dart' as usermodel;
import 'package:hackathon_wael/pages/widgets/app_button.dart';
import 'package:hackathon_wael/services/camera.service.dart';
import 'package:hackathon_wael/services/ml_service.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import '../../passwordlistscreen.dart';
import 'app_text_field.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton(
      {Key? key,
      required this.onPressed,
      required this.isLogin,
      required this.reload});
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');

usermodel.User? predictedUser;
  String createEmail(String s){

    s = s.replaceAll(" ", "");
    var random = Random();
    int randomNumber = random.nextInt(100000);
    s = s + randomNumber.toString() + "@gmail.com";
    return s;
  }
  Future<void> addElement(String userId, List<String> element) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final elementsRef = userRef.collection('elements');
    await elementsRef.add(element as Map<String, dynamic>);
  }
  Future<void> createUserInFirestore(String uid, String name, String email, String password) async {
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
        'email': email,
        'password': password
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
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  // Sign-up method with additional name field
  Future<void> _signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,

      );

      final user = credential.user;
      if(user != null){
        createUserInFirestore(user.uid, name,email,password);
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

  Future _signUp(context) async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    String email = createEmail(user);

    await _signUpWithEmailAndPassword(email,password,user);


    usermodel.User userToSave = usermodel.User(
      user: user,
      password: password,
      modelData: predictedData,
    );
    await _databaseHelper.insert(userToSave);
    this._mlService.setPredictedData([]);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PasswordListScreen()));

  }
  Future<bool> _signInWithEmailAndPassword(String name,password) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      String email = await _searchUser(name, password);
      final UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Handle successful sign-in logic here (e.g., navigate to home screen)
      print("Sign In Successful!");

      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PasswordListScreen()));
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print(e.code);
      }
      // Display error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message!),
        ),
      );
    }
    return false;
  }
  Future<String> _searchUser(String name, String password) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: name).where("password", isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String,dynamic> data = querySnapshot.docs.first.data() as Map<String,dynamic>;
        String email = data['email'];
        print("User found with the email: " + email);
        return email;
      } else {
        print("User not found with the given name and password" );
      }
    } catch (e) {
      print("Error while trying to find the email of the user:$e" );
    }
    return "";
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;
    if (this.predictedUser!.password == password) {

      bool success = await _signInWithEmailAndPassword(this.predictedUser!.user,password);
      if(success)Navigator.of(context).push(MaterialPageRoute(builder: (context) => PasswordListScreen()));

    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  Future<usermodel.User?> _predictUser() async {
    usermodel.User? userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            this.predictedUser = user;
          }
        }
        PersistentBottomSheetController bottomSheetController =
            Scaffold.of(context)
                .showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome back, ' + predictedUser!.user + '.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? AppTextField(
                        controller: _userTextEditingController,
                        labelText: "Your Name",
                      )
                    : Container(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser == null
                    ? Container()
                    : AppTextField(
                        controller: _passwordTextEditingController,
                        labelText: "Password",
                        isPassword: true,
                      ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          _signIn(context);
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : !widget.isLogin
                        ? AppButton(
                            text: 'SIGN UP',
                            onPressed: () async {
                              await _signUp(context);
                            },
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
