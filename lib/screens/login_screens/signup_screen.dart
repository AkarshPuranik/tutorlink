import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorlink/screens/Teacher_screens.dart/teacher_home_screen.dart';
import 'package:tutorlink/screens/student_screens/home_screen.dart';
import 'package:tutorlink/screens/student_screens/booking.dart';

class SignupScreen extends StatefulWidget {
  final bool isStudent;

  const SignupScreen({Key? key, required this.isStudent}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to create a user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user data in Firestore under the correct collection (students or teachers)
      String collection = widget.isStudent ? 'students' : 'teachers';
      String userId = userCredential.user!.uid;

      await _firestore.collection(collection).doc(userId).set({
        'email': _emailController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // Navigate to the appropriate page based on user role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.isStudent ?  TutorSearchScreen() : TutorProfileSetupScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Specific FirebaseAuth exceptions
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use by another account.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak. Please choose a stronger password.';
      } else {
        message = 'Signup failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Generic exception handler for any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isStudent ? "Student Signup" : "Teacher Signup"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _signup,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
