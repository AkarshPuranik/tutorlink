import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TutorAcceptedRequestsScreen extends StatelessWidget {
  const TutorAcceptedRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tutorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Confirmed Booking Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('tutorId', isEqualTo: tutorId)
            .where('status', isEqualTo: 'Confirmed') // Only confirmed bookings
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return Center(child: Text("No confirmed bookings available."));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final studentId = booking['studentId'] ?? 'Unknown Student';
              final date = booking['date'] ?? 'Unknown Date';
              final time = booking['time'] ?? 'Unknown Time';
              final sessionMode = booking['sessionMode'] ?? 'Unknown Mode';
              final address = booking['address'] ?? 'No address provided';
              final contactNumber = booking['contactNumber'] ?? 'No contact number provided';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('students').doc(studentId).get(),
                builder: (context, studentSnapshot) {
                  if (!studentSnapshot.hasData) return SizedBox.shrink();

                  final studentData = studentSnapshot.data!.data() as Map<String, dynamic>?;

                  final studentName = studentData?['name'] ?? 'Student';
                  final studentEmail = studentData?['email'] ?? 'No email provided';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.lightBlue[50],
                    child: ListTile(
                      title: Text(
                        "Booking with $studentName",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: $date"),
                          Text("Time: $time"),
                          Text("Session Mode: $sessionMode"),
                          Text("Student Email: $studentEmail"),
                          Text("Location: $address"),
                          Text("Contact: $contactNumber"),
                        ],
                      ),
                      trailing: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
