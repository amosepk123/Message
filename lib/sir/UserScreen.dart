import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'chatscreen2.dart';



class UserScreen extends StatefulWidget {
  final String userId;

  const UserScreen({required this.userId, Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}


class _UserScreenState extends State<UserScreen> {
  TextEditingController search = TextEditingController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    getUsers(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          "GT CHAT",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: search,
              onChanged: (value) {
                getUser(value);
              },
              decoration: InputDecoration(
                filled: true,
                labelText: "Search",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Chats",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,fontStyle: FontStyle.italic,color: Colors.blueAccent),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            fromId: widget.userId,
                            toId: searchResults[index]['_id'],
                            receiverName: searchResults[index]['name'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shadowColor: Colors.black,
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${searchResults[index]['name']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getUsers(String userId) async {
    try {
      final apiUrl = 'http://208.109.34.247:8025/users';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'id': userId,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData.containsKey('users')) {
          setState(() {
            users = List<Map<String, dynamic>>.from(responseData['users']);
            searchResults.addAll(users);
          });
        } else {
          print('Error: Response does not contain the expected user data.');
        }
      } else {
        print('Failed to get users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void getUser(String phone) {
    setState(() {
      searchResults.clear();
    });

    if (phone.isNotEmpty) {
      var matchedUsers = users.where((user) =>
      user['phoneNo'] != null &&
          user['phoneNo'].toString().startsWith(phone));

      setState(() {
        searchResults.addAll(matchedUsers);

        if (searchResults.isNotEmpty) {
          print('Details of users with phone number $phone:');
          for (var user in searchResults) {
            print('Name: ${user['name']}');
            print('Username: ${user['username']}');
            // Print other details as needed
          }
        } else {
          print('No users found for the provided phone number.');
        }
      });
    }
  }
}

