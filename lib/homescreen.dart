import 'package:flutter/material.dart';
import 'package:hackathon_wael/loginscreen.dart';
import 'package:hackathon_wael/pages/sign-in.dart';
import 'package:hackathon_wael/pages/sign-up.dart';
import 'package:hackathon_wael/services/camera.service.dart';
import 'package:hackathon_wael/services/face_detector_service.dart';
import 'package:hackathon_wael/services/ml_service.dart';
import 'package:hackathon_wael/signupscreen.dart';

import 'locator.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  MLService _mlService = locator<MLService>();
  FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  CameraService _cameraService = locator<CameraService>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  _initializeServices() async {
    setState(() => loading = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _mlKitService.initialize();
    setState(() => loading = false);
  }

  void signUpEmail(){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpPage()));
  }
  void signUpFace(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUp()));
  }
  void loginEmail(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
  }
  void loginFace(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignIn()));
  }
  @override
  Widget build(BuildContext context) {

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;


    return Scaffold(
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Secure Vault',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0B1533),
                fontSize: 45,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Your secure password wallet',
              style: TextStyle(
                color: Color(0xFF0B1533),
                fontSize: 18.50,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w400,
                height: 0.04,
              ),
            ),
            SizedBox(height: h * 0.1,),

            TextButton(onPressed: (){signUpEmail();}, child: Container(
              width: w * 0.7,
              height: h * 0.08,
              decoration: ShapeDecoration(
                color: Color(0xFF00305F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(69),
                ),
              ),
              child: const Center(child:Text(
                'Sign up with Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Play',
                  fontWeight: FontWeight.w400,
                ),
              )),
            )) ,
          SizedBox(height: h * 0.02,)
          ,
            TextButton(onPressed:  (){signUpFace();}, child: Container(
              width: 273,
              height: 62,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFF00147A)),
                  borderRadius: BorderRadius.circular(69),
                ),
              ),

              child: Center(child:
              Text(
                'Sign up with Facial Recognition',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.54),
                  fontSize: 15,
                  fontFamily: 'Play',
                  fontWeight: FontWeight.w400,
                ),
              )),
            )),
            SizedBox(height: h * 0.02,)
            ,
            TextButton(onPressed: (){loginEmail();}, child: Container(
              width: w * 0.7,
              height: h * 0.08,
              decoration: ShapeDecoration(
                color: Color(0xFF00305F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(69),
                ),
              ),
              child: const Center(child:Text(
                'Sign in with Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Play',
                  fontWeight: FontWeight.w400,
                ),
              )),
            )),
            SizedBox(height: h * 0.02,)
            ,
            TextButton(onPressed:  (){loginFace();}, child: Container(
              width: 273,
              height: 62,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFF00147A)),
                  borderRadius: BorderRadius.circular(69),
                ),
              ),

              child: Center(child:
              Text(
                'Login with Facial Recognition',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.54),
                  fontSize: 15,
                  fontFamily: 'Play',
                  fontWeight: FontWeight.w400,
                ),
              )),
            ))
          ],
        ),
      ),
    );
  }
}
