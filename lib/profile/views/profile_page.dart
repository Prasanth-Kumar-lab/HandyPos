import 'package:flutter/material.dart';
class ProfilePage extends StatelessWidget {
  final String name;
  final String username;
  final String mobileNumber;

  const ProfilePage({
    super.key,
    required this.name,
    required this.username,
    required this.mobileNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello', style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
    );
  }
}
