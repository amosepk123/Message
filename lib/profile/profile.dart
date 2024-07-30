import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';


import '../login/auth_service.dart';
import '../provider/theme_provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DateTime lastTimeBackbuttonWasClicked =DateTime.now();
  final auth = AuthService();
  Uint8List? _image;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;
  final String defaultImageUrl =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcToiRnzzyrDtkmRzlAvPPbh77E-Mvsk3brlxQ&s";

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadFormData();
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select image from:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text('Camera'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Delete'),
                  content: Text('Are you sure you want to delete the profile image?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Yes'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                setState(() {
                  _image = null;
                });
                _saveImage(Uint8List(0));
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (pickedImage != null) {
      final pickedFile = await picker.pickImage(source: pickedImage);
      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          _image = bytes;
        });
        _saveImage(bytes);
      }
    }
  }

  Future<void> _saveImage(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = base64Encode(bytes);
    await prefs.setString('profile_image', base64String);
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = prefs.getString('profile_image');
    if (base64String != null && base64String.isNotEmpty) {
      setState(() {
        _image = base64Decode(base64String);
      });
    }
  }

  Future<void> _saveFormData(Map<String, dynamic> formData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('profile_data', jsonEncode(formData));
  }

  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final formDataString = prefs.getString('profile_data');
    if (formDataString != null) {
      final formData = jsonDecode(formDataString) as Map<String, dynamic>;
      _formKey.currentState?.patchValue(formData);
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  // Custom Validators
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    } else if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null;
  }

  String? _validateDate(DateTime? value) {
    if (value == null) {
      return 'Date of Birth is required';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    } else if (value.length != 10) {
      return 'Phone number must be exactly 10 digits';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must be numeric';
    }
    return null;
  }


  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await auth.signout();
      _showToast("Signed out successfully!");
      // goToLogin(context); // Uncomment this line if you have the goToLogin function
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeText = MediaQuery.of(context).platformBrightness == Brightness.dark
        ? "DarkTheme"
        : "LightTheme";

    return WillPopScope(
        onWillPop: () async {
          if (DateTime.now().difference(lastTimeBackbuttonWasClicked) >=
              Duration(seconds: 1)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Press the back button again to go back"),
                duration: Duration(seconds: 2),
              ),
            );
            lastTimeBackbuttonWasClicked = DateTime.now();
            return false;
          } else {
            return true;
          }
        },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text("PROFILE"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (_isEditing) {
                    _loadFormData();
                  }
                });
              },
              icon: const Icon(Icons.edit),
            ),
            ChangeThemeButtonWidget(),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                          backgroundColor: Theme.of(context).iconTheme.color,
                          radius: 80,
                          backgroundImage: MemoryImage(_image!),
                        )
                            : Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).iconTheme.color,
                            radius: 80,
                            backgroundImage: NetworkImage(defaultImageUrl),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: -10,
                          child: IconButton(
                            onPressed: _selectImage,
                            icon: Icon(
                              Icons.add_a_photo,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_isEditing) ...[
                    FormBuilderTextField(
                      name: 'name',
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                      initialValue: _formKey.currentState?.value['name'],
                    ),
                    SizedBox(height: 10),
                    FormBuilderDateTimePicker(
                      name: 'dob',
                      inputType: InputType.date,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                      ),
                      format: DateFormat('dd-MM-yyyy'),
                      validator: _validateDate,
                      initialValue: _formKey.currentState?.value['dob'] != null
                          ? DateTime.parse(_formKey.currentState!.value['dob'].toString())
                          : null,
                    ),
                    SizedBox(height: 10),
                    FormBuilderTextField(
                      name: 'phone',
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validatePhone,
                      initialValue: _formKey.currentState?.value['phone'],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          _showToast("Profile updated successfully!");
                          _saveFormData(_formKey.currentState?.value ?? {});
                          setState(() {
                            _isEditing = false;
                          });
                        } else {
                          _showToast("Please fill out all fields correctly.");
                        }
                      },
                      child: const Text("Update Profile"),
                    ),
                  ],
                  if (!_isEditing) ...[
                    Center(
                      child: Align(
                        alignment: Alignment.center,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      "Name:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900, fontSize: 20),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _formKey.currentState?.value['name'] ?? 'N/A',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      "Date of Birth:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900, fontSize: 20),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _formKey.currentState?.value['dob'] != null
                                          ? DateFormat('dd-MM-yyyy').format(DateTime.parse(_formKey.currentState!.value['dob'].toString()))
                                          : 'N/A',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      "Phone Number:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900, fontSize: 20),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _formKey.currentState?.value['phone'] ?? 'N/A',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text("Sign Out"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch(
      value: themeProvider.isDakMode,
      onChanged: (value) {
        final provider = Provider.of<ThemeProvider>(context, listen: false);
        provider.toggleTheme(value);
      },
    );
  }
}
