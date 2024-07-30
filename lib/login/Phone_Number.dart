import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'otp_screen.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final phoneController = TextEditingController();
  String selectedCountryCode = '+1'; // Default country code

  // List of country codes
  final List<String> countryCodes = ['+1', '+91', '+44', '+61', '+81'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter the Phone Number",
                  prefixIcon: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCountryCode,
                        items: countryCodes.map((String code) {
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(code),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                          });
                        },
                        // dropdownColor: Colors.white,
                      ),
                    ),
                  ),
                  suffixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                String phoneNumber = '$selectedCountryCode${phoneController.text}';
                await FirebaseAuth.instance.verifyPhoneNumber(
                  verificationCompleted: (PhoneAuthCredential credential) {},
                  verificationFailed: (FirebaseAuthException ex) {
                    print('Verification failed: $ex');
                  },
                  codeSent: (String verificationId, int? resendToken) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpScreen(verificationid: verificationId),
                      ),
                    );
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {},
                  phoneNumber: phoneNumber,
                );
              },
              child: Text("Verify Phone Number"),
            ),
          ],
        ),
      ),
    );
  }
}
