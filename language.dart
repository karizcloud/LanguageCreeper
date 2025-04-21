import 'package:flutter/material.dart';
import '../activity page/main_page.dart';
import 'dart:math';

class LanguageSelectionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> languages = [
    {'name': 'Java', 'image': 'assets/java img 1.png'},
    {'name': 'Python', 'image': 'assets/python img 1.png'},
    {'name': 'C++', 'image': 'assets/cpp img 1.png'},
    {'name': 'HTML', 'image': 'assets/html img.png'},
    {'name': 'C', 'image': 'assets/c img 1.png'},
    {'name': 'JavaScript', 'image': 'assets/js img 1.png'},
  ];

  LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Create staggered animations
    for (int i = 0; i < widget.languages.length; i++) {
      _animations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(i * 0.15, 1, curve: Curves.easeOutBack),
          ),
        ),
      );
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Language',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A4D2E),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFA7D397),
              Color(0xFFF5EEC8),
              Color(0xFFDCFFB7),
              Color(0xFFA7D397),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              childAspectRatio: 0.9,
            ),
            itemCount: widget.languages.length,
            itemBuilder: (context, index) {
              final language = widget.languages[index];
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..translate(
                          0.0, (1 - _animations[index].value) * 100)
                      ..scale(_animations[index].value),
                    child: Opacity(
                      opacity: _animations[index].value,
                      child: child,
                    ),
                  );
                },
                child: _LanguageCard(
                  language: language,
                  onTap: () => _navigateToMainPage(context, language['name']),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToMainPage(BuildContext context, String language) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => MainPage(selectedLanguage: language),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

class _LanguageCard extends StatefulWidget {
  final Map<String, dynamic> language;
  final VoidCallback onTap;

  const _LanguageCard({required this.language, required this.onTap});

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.95 : 1.0,
        child: Card(
          elevation: _isPressed ? 4 : 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white.withOpacity(0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLanguageImage(),
                const SizedBox(height: 15),
                Text(
                  widget.language['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageImage() {
    return Hero(
      tag: widget.language['name'],
      child: Material(
        color: Colors.transparent,
        child: Image.asset(
          widget.language['image'],
          height: 80,
          width: 80,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame == null) {
              return Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            }
            return child;
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red, size: 40);
          },
        ),
      ),
    );
  }
}