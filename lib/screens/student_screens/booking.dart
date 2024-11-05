import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorlink/screens/student_screens/booking_confirm.dart';

class BookingRequestScreen extends StatefulWidget {
  final String tutorId;

  const BookingRequestScreen({Key? key, required this.tutorId}) : super(key: key);

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _sessionMode = 'Offline';

  Future<void> _sendBookingRequest() async {
    final studentId = FirebaseAuth.instance.currentUser!.uid;

    // Add booking request in Firestore bookings collection
    final bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
      'tutorId': widget.tutorId,
      'studentId': studentId,
      'date': _dateController.text,
      'time': _timeController.text,
      'sessionMode': _sessionMode,
      'address': _addressController.text,
      'contactNumber': _contactController.text,
      'status': 'Pending',
    });

    // Add notification entry for tutor
    await FirebaseFirestore.instance.collection('notifications').add({
      'tutorId': widget.tutorId,
      'bookingId': bookingRef.id,
      'studentId': studentId,
      'date': _dateController.text,
      'time': _timeController.text,
      'sessionMode': _sessionMode,
      'address': _addressController.text,
      'contactNumber': _contactController.text,
      'status': 'Pending',
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking request sent!")));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingConfirmationScreen(bookingId: bookingRef.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Booking")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Select Date'),
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _dateController.text = date.toLocal().toString().split(' ')[0];
                }
              },
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Select Time'),
              onTap: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  _timeController.text = time.format(context);
                }
              },
            ),
            DropdownButton<String>(
              value: _sessionMode,
              items: ['Offline', 'Online', 'Hybrid'].map((mode) {
                return DropdownMenuItem(value: mode, child: Text(mode));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _sessionMode = value!;
                });
              },
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _sendBookingRequest, child: Text("Request Booking")),
          ],
        ),
      ),
    );
  }
}
