import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorlink/screens/login_screens/user_screen.dart';
import 'package:tutorlink/screens/student_screens/booking_update.dart';
import 'package:tutorlink/screens/student_screens/profile_screen.dart';

class TutorSearchScreen extends StatefulWidget {
  const TutorSearchScreen({Key? key}) : super(key: key);

  @override
  State<TutorSearchScreen> createState() => _TutorSearchScreenState();
}

class _TutorSearchScreenState extends State<TutorSearchScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  List<DocumentSnapshot> _tutors = [];
  bool _hasSearched = false;

  Future<void> _searchTutors() async {
    final city = _cityController.text.trim().toLowerCase();
    final pincode = _pincodeController.text.trim();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tutors')
          .where('city', isEqualTo: city)
          .where('pincode', isEqualTo: pincode)
          .get();

      setState(() {
        _tutors = snapshot.docs;
        _hasSearched = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error searching for tutors")),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => UserSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Tutors")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: _logout,
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notifications"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StudentBookingUpdatesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("Other Option"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFA726), // Example orange color, adjust to match your gradient
              Color(0xFFFF7043), // Example deeper orange color, adjust to match your gradient
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pincodeController,
                decoration: InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _searchTutors,
                child: Text("Search"),
              ),
              if (_hasSearched && _tutors.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text("No tutors found for your search."),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _tutors.length,
                  itemBuilder: (context, index) {
                    final tutor = _tutors[index];
                    final tutorData = tutor.data() as Map<String, dynamic>?;

                    if (tutorData == null) {
                      return ListTile(
                        title: Text("Invalid data"),
                        subtitle: Text("This tutor's information is unavailable."),
                      );
                    }

                    final name = tutorData['name'] ?? 'No name provided';
                    final bio = tutorData['bio'] ?? 'No bio available';
                    final subjects = tutorData['subjects'] ?? [];
                    final rate = tutorData['rate'] ?? 'Not specified';
                    final email = tutorData['email'] ?? 'No email provided';
                    final phone = tutorData['phone'] ?? 'No phone number provided';
                    final profileImageUrl = tutorData['profileImageUrl'];

                    return ListTile(
                      leading: profileImageUrl != null
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(profileImageUrl),
                      )
                          : CircleAvatar(
                        child: Icon(Icons.account_circle),
                      ),
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Bio: $bio"),
                          Text("Subjects: ${subjects.join(", ")}"),
                          Text("Rate: $rate per hour"),
                          Text("Email: $email"),
                          Text("Mobile: $phone"),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TutorProfileScreen(tutorId: tutor.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
