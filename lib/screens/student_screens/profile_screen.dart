import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorlink/screens/student_screens/booking.dart';
import 'package:tutorlink/screens/student_screens/payment.dart';


class TutorProfileScreen extends StatelessWidget {
  final String tutorId;

  const TutorProfileScreen({Key? key, required this.tutorId}) : super(key: key);

  // Check if the student has an active subscription
  Future<bool> _checkSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final studentData = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
      final expiryDate = studentData['subscriptionExpiry']?.toDate();
      if (expiryDate != null && expiryDate.isAfter(DateTime.now())) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tutor Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('tutors').doc(tutorId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final tutor = snapshot.data!.data() as Map<String, dynamic>;
          return FutureBuilder<bool>(
            future: _checkSubscriptionStatus(),
            builder: (context, subSnapshot) {
              final hasSubscription = subSnapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tutor's Profile Image
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: tutor['profileImageUrl'] != null
                            ? NetworkImage(tutor['profileImageUrl'])
                            : AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tutor's Name
                    Text(
                      tutor['name'] ?? "Tutor",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Tutor's Bio
                    Text(
                      tutor['bio'] ?? "Bio not available",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),

                    // Subjects and Rate
                    Text(
                      "Subjects: ${tutor['subjects'] != null ? tutor['subjects'].join(", ") : "N/A"}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Rate: ${tutor['rate'] ?? "N/A"} per hour",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Conditional Contact Details
                    if (hasSubscription)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email: ${tutor['email'] ?? "Not provided"}",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Phone: ${tutor['phone'] ?? "Not provided"}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PaymentSubscriptionScreen()),
                          );
                        },
                        child: Text("Unlock Contact Details"),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingRequestScreen(tutorId: tutorId),
                          ),
                        );
                      },
                      child: Text("Book Now"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
