import 'package:flutter/material.dart';
import 'package:tutorlink/components/plain_background.dart';
import 'login_screen.dart';
import 'signup_screen.dart';


class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({Key? key}) : super(key: key);

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  bool isStudent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          const PlainBackground(),
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Tell us about you?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Row for Teacher and Student Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Teacher Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isStudent = false;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60, // Circle size
                              backgroundImage: AssetImage('assets/tutor.png'), // Replace with teacher image asset
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "I am a teacher",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isStudent ? Colors.white : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Student Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isStudent = true;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60, // Circle size
                              backgroundImage: AssetImage('assets/student.png'), // Replace with student image asset
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "I am a student",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isStudent ? Colors.blue : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(isStudent: isStudent),
                        ),
                      );
                    },
                    child: const Text("Login"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignupScreen(isStudent: isStudent),
                        ),
                      );
                    },
                    child: Text(
                      isStudent
                          ? "Register for student account?"
                          : "Register for teacher account?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
