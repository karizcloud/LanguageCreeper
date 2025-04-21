import 'package:flutter/material.dart';

class MoreActivities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFADA),
      appBar: AppBar(
        title: const Text('More Activities'),
      ),
      body: Center(
        child: const Text(
          'More Activities Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
