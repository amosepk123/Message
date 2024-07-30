import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../BottomNavigation.dart';
import '../provider/Name provider.dart';
import 'Phone_Number.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;
import 'signup.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();

  bool _isLoading = false;
  bool _hasError = false;
  bool _success = false;
  String _errorMessage = "";

  Future<void> LoginUser() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _success = false;
      _errorMessage = "";
    });

    try {
      var response = await http.post(
        Uri.parse("http://message.amoseraja.tech/api/login"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          "phone":_phone.text,
          "password":_password.text,

        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          EasyLoading.showSuccess('Great Success!');

          Navigator.push(context, MaterialPageRoute(builder: (context)=>bot()));
          EasyLoading.dismiss();

          _success = true;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = "Failed to create user: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Spacer(),
            Text(
              "Login",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            // SizedBox(height: 50),
            // TextFormField(
            //   controller: _name,
            //   decoration: const InputDecoration(
            //     labelText: "Name",
            //     hintText: "Enter Name",
            //   ),
            // ),
            SizedBox(height: 50),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: "phone",
                hintText: "Enter Phone Number",
              ),
            ),
            SizedBox(height: 20),
            // TextFormField(
            //   controller: _email,
            //   decoration: const InputDecoration(
            //     labelText: "Email",
            //     hintText: "Enter Email",
            //   ),
            // ),
            SizedBox(height: 20),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration:  InputDecoration(
                labelText: "Password",
                hintText: "Enter Password",
              ),
            ),
            SizedBox(height: 30),

            _isLoading
                ? CircularProgressIndicator()
                :ElevatedButton(
              onPressed:() {
                //_login();
                LoginUser();
                EasyLoading.show();
              },
              child: Text("Login"),
            ),
            const SizedBox(height: 20),
            if (_success)  Text("User added successfully!"),
            if (_hasError) Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 5),

            ElevatedButton(onPressed: () async {
              await _auth.loginWithGoogle();
              EasyLoading.show();
              // final googleUser = await GoogleSignIn(clientId:"789013470799-h6c9u4clbubakbi3bl7idh2k67q2f6od.apps.googleusercontent.com" ).signIn();
              // context.read<NameProvider>().changeName(newName: googleUser!.displayName.toString());
              Navigator.push(context, MaterialPageRoute(builder: (context)=> bot()));
            }, child: Text("sign in Google")),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const PhoneNumber()));
            }
                , child: Text("login by OTP")),

            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                InkWell(
                  onTap: () => goToSignup(context),
                  child: const Text("Signup", style: TextStyle(color: Colors.red),),
                ),
              ],
            ),
            Spacer(),


          ],
        ),
      ),
    );
  }

  void goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  // void goToHome(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const HomeScreen()),
  //   );
  // }

  Future<void> _login() async {
    await _auth.loginUserWithEmailAndPassword(
      _email.text,
      _password.text,
    );

    // if (user != null) {
    //   log("User Logged In");
    //   goToHome(context);
    // }
  }
}
