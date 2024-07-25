import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, String?> user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40), // Margin from the top
            Center(
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user["profile_img"] == null
                      ? const AssetImage('assets/default_profile.jpeg')
                      : NetworkImage(user["profile_img"]!)),
            ),
            const SizedBox(height: 20),
            Text(
              user["name"]!, // Replace with actual name
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              user["phone"]!, // Replace with actual phone number
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              user["email"]!, // Replace with actual email
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40), // Additional space at the bottom
          ],
        ),
      ),
    );
  }
}
