import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TutorFeedbackScreen extends StatelessWidget {
  const TutorFeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tutorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Student Feedback")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .where('tutorId', isEqualTo: tutorId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final feedbacks = snapshot.data!.docs;
          return ListView.builder(
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];
              return ListTile(
                title: Text("Rating: ${feedback['rating']}"),
                subtitle: Text(feedback['comment']),
              );
            },
          );
        },
      ),
    );
  }
}
