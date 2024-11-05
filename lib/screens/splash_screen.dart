import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorlink/screens/login_screens/user_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasUser = prefs.getBool('hasUser') ?? false;

    // Navigate based on session presence
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hasUser ? UserSelectionScreen() : UserSelectionScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), _checkUserSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
