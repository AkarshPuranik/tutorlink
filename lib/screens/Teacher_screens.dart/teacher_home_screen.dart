import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tutorlink/screens/Teacher_screens.dart/tutor_dashboard.dart';

class TutorProfileSetupScreen extends StatefulWidget {
  const TutorProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<TutorProfileSetupScreen> createState() => _TutorProfileSetupScreenState();
}

class _TutorProfileSetupScreenState extends State<TutorProfileSetupScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  File? _profileImage;
  String _profileImageUrl = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Upload profile image if selected
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.jpg');
        await storageRef.putFile(_profileImage!);
        _profileImageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('tutors').doc(user.uid).set({
        'bio': _bioController.text,
        'rate': _rateController.text,
        'location': _locationController.text,
        'city': _cityController.text.trim().toLowerCase(),
        'pincode': _pincodeController.text.trim(),
        'subjects': _subjectsController.text.split(',').map((subject) => subject.trim()).toList(),
        'profileImageUrl': _profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TutorDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setup Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null,
                child: _profileImage == null && _profileImageUrl.isEmpty
                    ? Icon(Icons.add_a_photo, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Bio'),
            ),
            TextField(
              controller: _rateController,
              decoration: InputDecoration(labelText: 'Rate per hour'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: _pincodeController,
              decoration: InputDecoration(labelText: 'Pincode'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _subjectsController,
              decoration: InputDecoration(labelText: 'Subjects (comma-separated)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
