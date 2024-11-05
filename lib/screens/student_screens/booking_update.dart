import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentBookingUpdatesScreen extends StatelessWidget {
  const StudentBookingUpdatesScreen({Key? key}) : super(key: key);

  Future<String> _fetchTutorName(String tutorId) async {
    final tutorSnapshot = await FirebaseFirestore.instance.collection('tutors').doc(tutorId).get();
    return tutorSnapshot.data()?['name'] ?? 'Unknown Tutor';
  }

  @override
  Widget build(BuildContext context) {
    final studentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Booking Updates")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('studentId', isEqualTo: studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return Center(child: Text("No booking updates available."));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final tutorId = booking['tutorId'] ?? 'Unknown Tutor';
              final date = booking['date'] ?? 'Unknown Date';
              final time = booking['time'] ?? 'Unknown Time';
              final sessionMode = booking['sessionMode'] ?? 'Unknown Mode';
              final status = booking['status'] ?? 'Pending';
              final address = booking['address'] ?? 'No address provided';
              final contactNumber = booking['contactNumber'] ?? 'No contact number provided';

              return FutureBuilder<String>(
                future: _fetchTutorName(tutorId),
                builder: (context, tutorSnapshot) {
                  final tutorName = tutorSnapshot.data ?? 'Fetching...';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: status == 'Confirmed' ? Colors.lightGreen[50] : Colors.white,
                    child: ListTile(
                      title: Text(
                        "Booking with $tutorName",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == 'Confirmed' ? Colors.green : Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: $date"),
                          Text("Time: $time"),
                          Text("Session Mode: $sessionMode"),
                          Text("Status: ${status == 'Confirmed' ? 'Demo Confirmed' : status}"),
                          Text("Location: $address"),
                          Text("Contact: $contactNumber"),
                        ],
                      ),
                      trailing: Icon(
                        status == 'Confirmed'
                            ? Icons.check_circle
                            : status == 'Rejected'
                            ? Icons.cancel
                            : Icons.hourglass_empty,
                        color: status == 'Confirmed'
                            ? Colors.green
                            : status == 'Rejected'
                            ? Colors.red
                            : Colors.orange,
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
