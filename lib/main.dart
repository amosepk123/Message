import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:message/provider/Contact%20Provider.dart';
import 'package:message/provider/theme_provider.dart';
import 'package:message/sir/loginscreen.dart';
import 'package:provider/provider.dart';

import 'login/login.dart';
import 'login/signup.dart';
import 'mess.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey:  "AIzaSyALdemxVd2tx5Z-SEMrmj6y4wYgBVAIdSk",
        appId: "1:951284686984:web:c25cc0054a49da389a3f3d",
        messagingSenderId: "951284686984",
        projectId:  "combine-f71e0",
    )
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ContactsProvider()),
        // ChangeNotifierProvider(create: (context)=>NameProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home:  ChatPage1(),
      builder: EasyLoading.init(),
    );
  }
}


