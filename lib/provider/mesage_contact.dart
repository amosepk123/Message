import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../message.dart';
import 'Contact Provider.dart';


class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact>? contacts;
  List<Contact>? filteredContacts;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPhoneData();
    searchController.addListener(() {
      filterContacts();
    });
  }

  _callNumber(String number) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  Future<void> getPhoneData() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> fetchedContacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
      setState(() {
        contacts = fetchedContacts;
        filteredContacts = fetchedContacts;
      });
    } else {
      // Handle permission denied or restricted
    }
  }

  void filterContacts() {
    if (contacts != null) {
      String query = searchController.text.toLowerCase();
      setState(() {
        filteredContacts = contacts!.where((contact) {
          return contact.displayName.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Future<void> storeContactInFirebase(Contact contact) async {
    String contactId = contact.displayName;
    String number = contact.phones.isNotEmpty ? contact.phones.first.number : "---";
    Uint8List? image = contact.photo;

    // Upload photo to Firebase Storage
    String? photoUrl;
    if (image != null) {
      Reference storageRef = FirebaseStorage.instance.ref().child('contacts').child('$contactId.jpg');
      UploadTask uploadTask = storageRef.putData(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      photoUrl = await taskSnapshot.ref.getDownloadURL();
    }

    // Store contact data in Firestore
    await FirebaseFirestore.instance.collection('contacts').doc(contactId).set({
      'name': contact.displayName,
      'phone': number,
      'profile': photoUrl ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsProvider = Provider.of<ContactsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: (filteredContacts == null)
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredContacts!.length,
              itemBuilder: (BuildContext context, int index) {
                String number = (filteredContacts![index].phones.isNotEmpty)
                    ? filteredContacts![index].phones.first.number
                    : "---";
                Uint8List? image = filteredContacts![index].photo;
                return ListTile(
                  leading: (image == null)
                      ? const CircleAvatar(child: Icon(Icons.person))
                      : CircleAvatar(backgroundImage: MemoryImage(image)),
                  title: Text(filteredContacts![index].displayName),
                  subtitle: Text(number),
                  trailing: IconButton(
                    onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>const ChatPage()));
                    },
                    icon: const Icon(Icons.phone),
                  ),
                  onTap: () async {
                    //contactsProvider.addContact(filteredContacts![index]);
                    await storeContactInFirebase(filteredContacts![index]);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const ChatPage()));
                    //Navigator.pop(context);  // Navigate back to home page
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
