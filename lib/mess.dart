import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ChatPage1 extends StatefulWidget {
  const ChatPage1({super.key});

  @override
  State<ChatPage1> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage1> {
  Color purple = Color(0xFF6c5ce7);
  Color black = Color(0xFF191919);
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  final _from = TextEditingController();
  final _to = TextEditingController();
  final _chat = TextEditingController();

  bool _isLoading = false;
  bool _hasError = false;
  bool _success = false;

  Future<void> createUser() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _success = false;
    });

    try {
      var response = await http.post(
        Uri.parse("http://localhost:8080/api/create"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          // "From": _from.text,
          // "To": _to.text,
          "chat": _chat.text,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _success = true;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    _chat.text = message.text;
    createUser();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Chat(
      messages: _messages,
      showUserAvatars: true,
      showUserNames: true,
      user: _user,
      onSendPressed: _handleSendPressed,
    ),
  );
}

