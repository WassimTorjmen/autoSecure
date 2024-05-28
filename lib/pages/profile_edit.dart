import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_services.dart';
import 'profile.dart';

class UserProfileCreationPage extends StatefulWidget {
  final String uid;
  final String phoneNumber;
  const UserProfileCreationPage(
      {super.key, required this.uid, required this.phoneNumber});

  @override
  _UserProfileCreationPageState createState() =>
      _UserProfileCreationPageState();
}

class _UserProfileCreationPageState extends State<UserProfileCreationPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  File? _image;
  bool _isLoading = false;

  Future pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  _createUserProfile() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool result = await _authService.createProfileWithPhone(
        userId: widget.uid,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: widget.phoneNumber, // Passer le numéro de téléphone
        imagePath: _image?.path);

    setState(() {
      _isLoading = false;
    });

    if (result) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => ProfilePage(uid: widget.uid)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create profile")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(Icons.add_a_photo, size: 55)
                            : null,
                      ),
                    ),
                    TextField(
                      controller: _firstNameController,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                    ),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    TextField(
                      controller:
                          TextEditingController(text: widget.phoneNumber),
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: _registerUser,
                        child: const Text('Create Profile'))
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    _createUserProfile();
  }
}
