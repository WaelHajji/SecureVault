import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import 'addcredentialscreen.dart'; // For Firestore

class PasswordListScreen extends StatefulWidget {
  @override
  PasswordListScreenState createState() =>PasswordListScreenState();
}

class PasswordListScreenState extends State<PasswordListScreen> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser!;

  String username = "";
  String feedback = "";
  List<String> passwords = [];
  String checkPasswordSecurity(String password) {
    // Initialize feedback and suggestions
    String feedback = '';
    String suggestions = '';
    // Check password length
    if (password.length < 8) {
      feedback += 'Password is too short. ';
      suggestions += 'Consider making it at least 8 characters long. ';
    }
    // Check for presence of uppercase letters
    if (!password.contains(RegExp(r'[A-Z]'))) {
      feedback += 'Password should contain at least one uppercase letter. ';
      suggestions += 'Consider adding uppercase letters. ';
    }
    // Check for presence of lowercase letters
    if (!password.contains(RegExp(r'[a-z]'))) {
      feedback += 'Password should contain at least one lowercase letter. ';
      suggestions += 'Consider adding lowercase letters. ';
    }
    // Check for presence of digits
    if (!password.contains(RegExp(r'[0-9]'))) {
      feedback += 'Password should contain at least one digit. ';
      suggestions += 'Consider adding digits. ';
    }
    // Check for presence of special characters
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      feedback +=
      'Password should contain at least one special character. ';
      suggestions += 'Consider adding special characters. ';
    }
    // Return feedback and suggestions
    if (feedback.isEmpty) {
      return 'Password is strong.';
    } else {
      return feedback + '\n' + suggestions;
    }
  }

  Future<String> getUserName(String uid) async {
    // Validate input
    if (uid.isEmpty) {
      throw ArgumentError('Uid cannot be empty.');
    }

    final usersCollection = FirebaseFirestore.instance.collection('users');
    final docSnapshot = await usersCollection.doc(uid).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['name'] != null) {

        return data['name'] as String;
      } else {
        print('User data or name field is missing for Uid: $uid');
        return ''; // Or return a default value if name is missing
      }
    } else {
      print('User with Uid: $uid does not exist.');
      return ''; // Or return a default value if user doesn't exist
    }
  }
  void submitPassword(){
    String password = passwordController.text;
    setState(() {
      feedback = checkPasswordSecurity(password);
    });

  }
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
  Future<List<String>> _storeUserInfo() async {
     // Consider hashing password before storing

    // Create a reference to the user's document in Firestore
    await checkAndCreateDocument("users",_currentUser.uid,{});
    final userRef = FirebaseFirestore.instance.collection('users').doc(_currentUser.uid);

    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the existing user data or create an empty list if it doesn't exist
      final userData = (await transaction.get(userRef)).data() ?? {};

      List<dynamic> existingElements = [];
      if(userData.containsKey('passwords'))existingElements = userData['passwords'];
      print(existingElements);
      return existingElements.cast<String>();
    });

  }
  void fetchData() async {
    // Code to fetch data from Firestore (replace with your actual logic)
    final name = await getUserName(_currentUser.uid);
    final passwordss = await _storeUserInfo();
    setState(() {
      username = name;
      passwords = passwordss;// Update the state with fetched data
    });
  }
  @override
  void initState() {
    super.initState();
      fetchData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double h = size.height, w = size.width;

    Widget feedbackWidget = SizedBox();
    if(feedback != ""){
      feedbackWidget = Text(
        feedback,
        style: TextStyle(
          color: Color(0xFFAE0505),
          fontSize: 16,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,
        ),
      );
    }
    List<Widget> passwordWidgets = [];

    for(int i = 0;i<passwords.length;i+=3){
      passwordWidgets.add(PasswordWidget(social: passwords[i], password: passwords[i+2], username: passwords[i+1]));
      passwordWidgets.add(SizedBox(height: 10,));
    }
    if(passwordWidgets.isEmpty){
      passwordWidgets.add(Center(child: Text("No passwords added Yet")));
    }
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xfff5f7ff)),
      backgroundColor: Color(0xfff5f7ff),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(child:
          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Hello',
              style: TextStyle(
                color: Color(0xFF0B1533),
                fontSize: 16,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w400,

              ),
            ),
            Text(
              username,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xFF0B1533),
                fontSize: 24,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w400,

              ),
            ),
            Image.asset('assets/contact.png'),
            SizedBox(height: 30,),
            Text(
              'Password Logs',
              style: TextStyle(
                color: Color(0xFF0B1533),
                fontSize: 16,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,

              ),
            ), SizedBox(height:10),] + passwordWidgets +

            [SizedBox(height:10),
              Center(child:TextButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserInfoScreen(f: (){
                  fetchData();
                })));

              }, child:Container(
                width: w * 0.5,
                height: h * 0.05,
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
                      'Add a new password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                        height: 0.07,
                      ),
                    ),
                  ],
                ),
              ))),
              SizedBox(height: 10,),
            Text(
              'Password Strength tester',
              style: TextStyle(
                color: Color(0xFF0B1533),
                fontSize: 16,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
            ),
          SizedBox(height: 10,),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              hintText: 'Enter a password',
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
                )
            ),
          ), SizedBox(height: 10),feedbackWidget, // Add some spacing between Textfield and button
          Center(child:TextButton(
            onPressed: submitPassword,
            child: Container(
              width: w * 0.5,
              height: h * 0.05,
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
                    'Test strength',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                      height: 0.07,
                    ),
                  ),
                ],
              ),
            ),
          )),

          ],)
          ),
      ),
    );
  }
}
class PasswordWidget extends StatelessWidget{
  final String social,password,username;

  const PasswordWidget({Key? key, required this.social,required this.password,required this.username}) : super(key: key);

  int checkPasswordSecurity(String password) {
    if (password.isEmpty) {
      return 0;
    }

    int length = password.length;
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*()_+-=[]{}|;:,./<>?~]'));

    int complexityScore = 0;
    complexityScore += length >= 8 ? 1 : 0;
    complexityScore += hasUpperCase ? 1 : 0;
    complexityScore += hasLowerCase ? 1 : 0;
    complexityScore += hasNumber ? 1 : 0;
    complexityScore += hasSpecialChar ? 1 : 0;

    return complexityScore;
  }

  double checkPasswordSecurity(String password) {
    if (password.isEmpty) {
      return 0.0;
    }

    int length = password.length;
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,./<>?~]'));

    const double lengthCoefficient = 2.0;
    const double upperCaseCoefficient = 3.0;
    const double lowerCaseCoefficient = 2.0;
    const double numberCoefficient = 3.0;
    const double specialCharCoefficient = 4.0;

    double complexityScore = 0.0;
    complexityScore += (length >= 8 ? 1 : 0) * lengthCoefficient * 12.0;
    complexityScore += (hasUpperCase ? 1 : 0) * upperCaseCoefficient * 14.0;
    complexityScore += (hasLowerCase ? 1 : 0) * lowerCaseCoefficient * 15.0;
    complexityScore += (hasNumber ? 1 : 0) * numberCoefficient * 11.0;
    complexityScore += (hasSpecialChar ? 1 : 0) * specialCharCoefficient * 13.0;

    const double upperLowerBonus = 2.0 * 16.0;
    const double numberSpecialBonus = 3.0 * 17.0;
    const double allFeaturesBonus = 5.0 * 18.0;

    if (hasUpperCase && hasLowerCase) {
      complexityScore += upperLowerBonus;
    }
    if (hasNumber && hasSpecialChar) {
      complexityScore += numberSpecialBonus;
    }
    if (length >= 12 && hasUpperCase && hasLowerCase
        && hasNumber && hasSpecialChar) {
      complexityScore += allFeaturesBonus;
    }
    return complexityScore;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double w = size.width;
    double h = size.height;
    int score = checkPasswordSecurity(password);
    List<Color> colors = [Colors.green,Colors.green,Colors.yellow,Colors.yellow,Colors.red,Colors.red];
    return Container(child: Stack(children: [
      Align(alignment: Alignment(-0.9,0),child:CircleAvatar(
        radius: w * 0.06,
        backgroundColor: Colors.grey[200], // Placeholder background color
        backgroundImage:  null,
        child: Icon(Icons.person, color: Colors.white),
      ) ,),

      Align(child:Text(
        social,
        style: TextStyle(
          color: Color(0xFF0B1533),
          fontSize: 16,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
        ),
      ), alignment: Alignment(-0.5,-0.5),)
      ,
      Align(child: Text(
        username,
        style: TextStyle(
          color: Color(0xFF0B1533),
          fontSize: 14,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,

        ),
      ), alignment: Alignment(-0.52 ,0.4),),
      Align(child: Text(
        password,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF0B1533),
          fontSize: 14,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
        ),
      ),alignment: Alignment(0.8  ,0),),
      Align(child: Container(
        width: 6,
        height: 20,
        decoration: ShapeDecoration(
          color: colors[score],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ), alignment: Alignment(0.92,0),)
    ],),
    width: w * 0.9,
      height: h * 0.08,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),);
  }
  
}
