import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorlink/screens/Teacher_screens.dart/notification.dart';

import 'package:tutorlink/screens/Teacher_screens.dart/edit_profile.dart';
import 'package:tutorlink/screens/student_screens/history.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  String username = '';
  String bio = '';
  String location = '';
  String _profileImageUrl = '';

  Future<void> _fetchTutorProfile() async {
    final userDocRef = FirebaseFirestore.instance
        .collection('tutors')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _profileImageUrl = userData['profileImageUrl'] ?? '';
        username = userData['name'] ?? 'Tutor';
        bio = userData['bio'] ?? 'Bio not available';
        location = userData['location'] ?? 'Location not set';
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void initState() {
    super.initState();
    _fetchTutorProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7292CF),
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              "assets/plain_bg.png",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, $username",
                              style: const TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              bio,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TutorEditProfileScreen(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: _profileImageUrl.isNotEmpty
                                ? NetworkImage(_profileImageUrl)
                                : null,
                            child: _profileImageUrl.isEmpty
                                ? Icon(Icons.account_circle, size: 40, color: Colors.white54)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20.0),
                        Wrap(
                          runAlignment: WrapAlignment.spaceBetween,
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 20.0,
                          spacing: 20.0,
                          children: [
                            BounceInDown(
                              child: ZoomTapAnimation(
                                child: HomeScreenSmallCard(
                                  tooltext: 'View notifications for booking requests',
                                  icon: Icons.notifications,
                                  buttonText: "Notifications",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NotificationsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            BounceInDown(
                              child: ZoomTapAnimation(
                                child: HomeScreenSmallCard(
                                  tooltext: 'Manage your bookings here',
                                  icon: Icons.calendar_today,
                                  buttonText: "Bookings",
                                  onTap: () {Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                      builder: (_) => TutorAcceptedRequestsScreen(),
                                    ),
                                  );

                                    // Add Booking Management Screen here
                                  },
                                ),
                              ),
                            ),
                            BounceInUp(
                              child: ZoomTapAnimation(
                                child: HomeScreenSmallCard(
                                  tooltext: 'Check your earnings and payment history',
                                  icon: Icons.account_balance_wallet,
                                  buttonText: "Earnings",
                                  onTap: () {
                                    // Add Earnings Screen here
                                  },
                                ),
                              ),
                            ),
                            BounceInUp(
                              child: ZoomTapAnimation(
                                child: HomeScreenSmallCard(
                                  tooltext: 'View student feedback',
                                  icon: Icons.feedback,
                                  buttonText: "Feedback",
                                  onTap: () {
                                    // Add Feedback Screen here
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class HomeScreenSmallCard extends StatelessWidget {
  final String tooltext;
  final IconData icon;
  final String buttonText;
  final VoidCallback onTap;

  const HomeScreenSmallCard({
    Key? key,
    required this.tooltext,
    required this.icon,
    required this.buttonText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 8),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tooltext,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}