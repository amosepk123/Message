import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsProvider with ChangeNotifier {
  List<Contact> _selectedContacts = [];

  List<Contact> get selectedContacts => _selectedContacts;

  void addContact(Contact contact) {
    _selectedContacts.add(contact);
    notifyListeners();
  }

  void removeContact(Contact contact) {
    _selectedContacts.remove(contact);
    notifyListeners();
  }
}
