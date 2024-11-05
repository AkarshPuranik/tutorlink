import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  final String notificationId;

  const BookingDetailsScreen({Key? key, required this.bookingId, required this.notificationId})
      : super(key: key);

  Future<void> _updateBookingStatus(String status) async {
    // Update booking status
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': status,
    });

    // Update notification status
    await FirebaseFirestore.instance.collection('notifications').doc(notificationId).update({
      'status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('bookings').doc(bookingId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final booking = snapshot.data!.data() as Map<String, dynamic>;
          final studentAddress = booking['address'] ?? 'No address provided';
          final studentPhone = booking['contactNumber'] ?? 'No phone provided';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date: ${booking['date']}"),
                Text("Time: ${booking['time']}"),
                Text("Session Mode: ${booking['sessionMode']}"),
                const SizedBox(height: 20),
                Text("Student Address: $studentAddress"),
                Text("Student Phone: $studentPhone"),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _updateBookingStatus('Confirmed');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Confirmed!")));
                        Navigator.pop(context);
                      },
                      child: Text("Confirm"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _updateBookingStatus('Rejected');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Rejected")));
                        Navigator.pop(context);
                      },
                      child: Text("Reject"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
