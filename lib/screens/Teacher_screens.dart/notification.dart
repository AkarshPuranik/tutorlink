import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorlink/screens/Teacher_screens.dart/booking_management.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tutorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('tutorId', isEqualTo: tutorId)
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text("Booking Request"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date: ${notification['date']}"),
                    Text("Time: ${notification['time']}"),
                    Text("Phone: ${notification['contactNumber']}"),
                    Text("Address: ${notification['address']}"),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailsScreen(
                        bookingId: notification['bookingId'],
                        notificationId: notifications[index].id,
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
