import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../BottomNavigation.dart';


class OtpScreen extends StatefulWidget {
  final String verificationid;
  OtpScreen({super.key, required this.verificationid});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  //final otpController = TextEditingController();
  final otpControllers = List.generate(6, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("OTP Verification"),
      ),
      body: Form(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => otpTextField(context, index)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  String otp = otpControllers.map((controller) => controller.text).join();
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationid,
                    smsCode:otp,
                  );
                  await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const bot()));
                  });
                } catch (ex) {
                  log(ex.toString());
                }
              },
              child: Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }

  Widget otpTextField(BuildContext context,int index) {
    return Form(
      child: SizedBox(
        height: 70,
        width: 60,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: otpControllers[index],
            onChanged: (value){
              if(value.length==1){
                FocusScope.of(context).nextFocus();
              }
            },
            //onSaved: (pin){},
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],

            decoration: InputDecoration(
                hintText: "0",
                border: OutlineInputBorder()
            ),
          ),
        ),
      ),
    );
  }
}



