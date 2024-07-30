
import 'package:flutter/material.dart';
import 'package:message/profile/profile%20duplicate.dart';
import 'package:message/profile/profile.dart';
import 'contact.dart';
import 'home.dart';
import 'message.dart';


class bot extends StatefulWidget {
  const bot({super.key});

  @override
  State<bot> createState() => _botState();
}

class _botState extends State<bot> {
  int _index=0;
  final screen=[
    Home(),
    ContactPage(),
    ChatPage(),
    Profile12(),


  ];

  void tap(index){
    setState(() {
      _index=index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[_index],
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.person),label: "Contact"),
        // BottomNavigationBarItem(icon: Icon(Icons.history),label: "Histroy"),
        BottomNavigationBarItem(icon: Icon(Icons.message),label: "Message"),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined),label: "Profile"),

      ],
        currentIndex: _index,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.cyan,
        onTap: tap,
      ),


    );
  }
}
