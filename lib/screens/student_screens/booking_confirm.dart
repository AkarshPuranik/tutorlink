import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;

  const BookingConfirmationScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking Confirmation")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('bookings').doc(bookingId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final booking = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tutor ID: ${booking['tutorId']}"),
                Text("Date: ${booking['date']}"),
                Text("Time: ${booking['time']}"),
                Text("Session Mode: ${booking['sessionMode']}"),
                Text("Status: ${booking['status']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
