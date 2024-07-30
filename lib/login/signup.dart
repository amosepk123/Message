import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  bool _hasError = false;
  bool _success = false;
  String _errorMessage = "";

  Future<void> createUser() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _success = false;
      _errorMessage = "";
    });

    try {
      var response = await http.post(
        Uri.parse("http://message.amoseraja.tech/api/create"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'name': _name.text,
          'phone': int.tryParse(_phone.text),
          'emailId': _email.text,
          'password': _password.text,

        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _success = true;
          EasyLoading.showSuccess('Account Created!');
          EasyLoading.dismiss();
        });
      } else {
        setState(() {
          _hasError = true;
          EasyLoading.dismiss();

          _errorMessage = "Failed to create user: ${response.body}";
          EasyLoading.showError('Error in creating Account');
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
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              "Signup",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 50),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Enter Name",
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Phone",
                hintText: "Enter Phone",
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _email,
              //keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "Enter Email",
              ),
            ),

            const SizedBox(height: 20),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                hintText: "Enter Password",
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: (){
                createUser();
                EasyLoading.showSuccess('Account Created!');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                EasyLoading.dismiss();
                },
              child: const Text("Signup"),
            ),
            const SizedBox(height: 30),
            if (_success) const Text("User added successfully!"),
            if (_hasError) Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                InkWell(
                  onTap: () => goToLogin(context),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
