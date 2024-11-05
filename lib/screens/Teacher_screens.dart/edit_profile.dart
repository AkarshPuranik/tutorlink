import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TutorEditProfileScreen extends StatefulWidget {
  const TutorEditProfileScreen({Key? key}) : super(key: key);

  @override
  State<TutorEditProfileScreen> createState() => _TutorEditProfileScreenState();
}

class _TutorEditProfileScreenState extends State<TutorEditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  File? _profileImage;
  String _profileImageUrl = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance.collection('tutors').doc(user.uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _rateController.text = data['rate'] ?? '';
          _locationController.text = data['location'] ?? '';
          _cityController.text = data['city'] ?? '';
          _pincodeController.text = data['pincode'] ?? '';
          _subjectsController.text = (data['subjects'] as List<dynamic>).join(', ');
          _profileImageUrl = data['profileImageUrl'] ?? '';
        });
      }
    }
  }

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
      String profileImageUrl = _profileImageUrl;

      // Upload new profile image if selected
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
        await storageRef.putFile(_profileImage!);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('tutors').doc(user.uid).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'bio': _bioController.text,
        'rate': _rateController.text,
        'location': _locationController.text,
        'city': _cityController.text.trim().toLowerCase(),
        'pincode': _pincodeController.text.trim(),
        'subjects': _subjectsController.text.split(',').map((subject) => subject.trim()).toList(),
        'profileImageUrl': profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated!")),
      );

      Navigator.pop(context); // Return to previous screen after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: SingleChildScrollView(  // Added SingleChildScrollView for scrolling
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
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
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
            const SizedBox(height: 20),
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
