// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class CallAndWhatsApp extends StatefulWidget {
//   const CallAndWhatsApp({Key? key}) : super(key: key);
//
//   @override
//   State<CallAndWhatsApp> createState() => _CallAndWhatsAppState();
// }
//
// class _CallAndWhatsAppState extends State<CallAndWhatsApp> {
//   final TextEditingController _messageController = TextEditingController();
//
//   _callNumber() async {
//     const number = '+91 7708289054'; // Set the number here
//     bool? res = await FlutterPhoneDirectCaller.callNumber(number);
//   }
//
//   _byWhatsApp() async {
//     const phoneNumber = '+91 7708289054';
//     final message = _messageController.text.trim();
//
//     final whatsappUrl = _getWhatsAppUrl(phoneNumber, message);
//
//     try {
//       if (await canLaunch(whatsappUrl)) {
//         await launch(whatsappUrl);
//       } else {
//         throw 'Could not launch $whatsappUrl';
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not open WhatsApp: $e')),
//       );
//     }
//   }
//
//   String _getWhatsAppUrl(String phone, String message) {
//     if (Platform.isAndroid) {
//       return "https://wa.me/$phone?text=${Uri.encodeFull(message)}";
//     } else {
//       return "https://api.whatsapp.com/send?phone=$phone&text=${Uri.encodeFull(message)}";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Call and WhatsApp"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _messageController,
//               decoration: InputDecoration(
//                 labelText: 'Enter your message',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _callNumber,
//               child: const Text("Call"),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _byWhatsApp,
//               child: const Text("Send WhatsApp Message"),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: _callNumber,
//             child: const Icon(Icons.call),
//           ),
//           const SizedBox(height: 16),
//           FloatingActionButton(
//             onPressed: _byWhatsApp,
//             child: const Icon(Icons.message),
//           ),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
//     );
//   }
// }
//
//
