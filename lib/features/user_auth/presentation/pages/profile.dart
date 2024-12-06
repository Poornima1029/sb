import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';  // Import Firebase Storage
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? profileImageUrl;
  String? name;
  String? phoneNumber;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();  // Ensure profile is loaded when the page starts
  }

  // Load user profile data from Firestore
  void _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            name = doc['name'];
            phoneNumber = doc['phone'];
            profileImageUrl = doc['profileImageUrl'];
          });
        }
      } catch (e) {
        print("Error loading user profile: $e");
        Fluttertoast.showToast(msg: "Error loading profile");
      }
    }
  }

  // Update profile data in Firestore
  void _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'profileImageUrl': profileImageUrl,
      });

      // Fetch the updated name from Firestore
      _loadUserProfile();  // Refresh the UI with updated name
      Fluttertoast.showToast(msg: 'Profile updated successfully');
    }
  }

  // Pick an image for the profile and upload it to Firebase Storage
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Upload image to Firebase Storage
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          // Define storage reference with a unique file name (e.g., using user ID)
          String fileName = "${user.uid}_profileImage";
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('profileImages')
              .child(fileName);

          // Upload the file to Firebase Storage
          UploadTask uploadTask = storageRef.putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;

          // Get the download URL of the uploaded file
          String downloadUrl = await snapshot.ref.getDownloadURL();

          // Store the download URL in Firestore
          setState(() {
            profileImageUrl = downloadUrl;
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'profileImageUrl': downloadUrl,
          });

          Fluttertoast.showToast(msg: 'Profile image updated successfully!');
        }
      } catch (e) {
        print("Error uploading image: $e");
        Fluttertoast.showToast(msg: 'Error updating profile image');
      }
    }
  }

  // Submit feedback and store it in Firestore
  void _submitFeedback(String feedback) async {
    if (feedback.isNotEmpty) {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('feedback').add({
            'userId': user.uid,
            'feedback': feedback,
            'timestamp': FieldValue.serverTimestamp(),
          });

          Fluttertoast.showToast(msg: 'Thank you for your feedback!');
          _feedbackController.clear();
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error submitting feedback: $e');
      }
    } else {
      Fluttertoast.showToast(msg: 'Please enter feedback before submitting.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFFB2DFDB),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display greeting with the user's name
            name != null
                ? Text(
              'Hello, $name',  // The name is displayed here if it's not null
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            )
                : Container(),  // If name is null, show nothing

            SizedBox(height: 15),

            // Profile Section
            Text('Profile Management',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)  // Use the network image if the URL exists
                      : AssetImage('assets/default_profile.png') as ImageProvider,  // Fallback to default image if no profile image
                  child: profileImageUrl == null  // Show the edit icon only if no image is selected
                      ? Icon(Icons.edit, color: Colors.white)
                      : Container(),  // No icon if there's a profile image
                ),
              ),
            ),

            SizedBox(height: 15),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Profile'),
            ),

            SizedBox(height: 30),

            // Feedback and Support Section
            Text('Feedback and Support',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            TextField(
              controller: _feedbackController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Submit your feedback',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                _submitFeedback(_feedbackController.text);
              },
              child: Text('Submit Feedback'),
            ),
            SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "Redirecting to website...");
                },
                child: Text('Visit Support Website',
                    style: GoogleFonts.poppins()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
