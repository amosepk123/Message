import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'UserScreen.dart';
import 'chatterscreen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  Future<Map<String, dynamic>> authenticateUser(String phoneNo, String password) async {
    final apiUrl = 'http://208.109.34.247:8025/auth';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'phoneNo': phoneNo,
        'password': password,
      }),
    );

    print(response);

    if (response.statusCode == 200) {
      // Parse the response JSON
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to authenticate user. Status code: ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: 70,
                  width: 300,
                  child: TextFormField(
                    controller: phoneController,
                    cursorColor: Colors.black,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "PhoneNo",
                      filled: false,
                      fillColor: Colors.blueAccent,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 70,
                  width: 300,
                  child: TextFormField(

                    controller: passwordController,
                    cursorColor: Colors.black,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: false,
                      fillColor: Colors.blueAccent,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: ()
                  // async {
                  //   String phoneNo = phoneController.text;
                  //   String password = passwordController.text;
                  //
                  //   try {
                  //     Map<String, dynamic> authResponse = await authenticateUser(phoneNo, password);
                  //
                  //     // Check if 'error' key exists and is not null
                  //     if (authResponse.containsKey('error') && authResponse['error'] != null) {
                  //       // Check the response for authentication success
                  //       if (!authResponse['error']) {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => UserScreen(
                  //                 userId: authResponse['_id']
                  //             ),
                  //           ),
                  //         );
                  //       } else {
                  //         // Handle authentication failure
                  //         print("Authentication failed: ${authResponse['errorMessage']}");
                  //       }
                  //     } else {
                  //       // Handle missing or null 'error' key
                  //       print("Invalid authentication response: $authResponse");
                  //     }
                  //   } catch (e) {
                  //     // Handle network or server error
                  //     print("Error during authentication: $e");
                  //   }
                  // },


                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserScreen(
                          userId:"65616f7d59c326affb60550f"
                          //authResponse['_id']
                        ),
                      ),
                    );
                  },
                  child: Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
