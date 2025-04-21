import 'package:flutter/material.dart';

class Page02 extends StatefulWidget {
  const Page02({super.key});

  @override
  State<Page02> createState() => _Page02State();
}

class _Page02State extends State<Page02> {
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
                padding: const EdgeInsets.all(8),
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
                  radius: 80,
                  backgroundImage: AssetImage('assets/landingLogo2.png'),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Level up through play',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Code, create, conquer—master the digital world with ease!',
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
