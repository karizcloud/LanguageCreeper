import 'package:flutter/material.dart';

class Page01 extends StatefulWidget {
  const Page01({super.key});

  @override
  State<Page01> createState() => _Page01State();
}

class _Page01State extends State<Page01> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 173, 188, 159),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Space for the gradient border
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.limeAccent[700] ?? Colors.limeAccent,
                      Colors.greenAccent[700] ?? Colors.greenAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 80, // Adjust the size of the image
                  backgroundImage: const AssetImage('assets/landingLogo.png'),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Learn to code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Master the skills to read and write code, build apps and games and advance your career \n',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
