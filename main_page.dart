import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // For file imports
import 'package:image_picker/image_picker.dart'; // For image picking
import '../codexpuzzles/codexlevels.dart';
import '../guides/guides_python.dart';
import '../guides/guides_java.dart';
import '../guides/guides_javascript.dart';
import '../guides/guides_html.dart';
import '../guides/guides_c.dart';
import '../guides/guides_cpp.dart';
import '../quiz/quiz_python.dart';
import '../quiz/quiz_java.dart';
import '../quiz/quiz_javascript.dart';
import '../quiz/quiz_html.dart';
import '../quiz/quiz_c.dart';
import '../quiz/quiz_cpp.dart';
import '../flashcards/flashcardspythonmain.dart';
import '../flashcards/flashcardsjavamain.dart';
import '../flashcards/flashcardsjavascriptmain.dart';
import '../flashcards/flashcardshtmlmain.dart';
import '../flashcards/flashcardscmain.dart';
import '../flashcards/flashcardscppmain.dart';
import '../compiler/compiler.dart';
import '../character stuff/leadership.dart';
import 'more_activities.dart';
import '../scramble/scrambleLevelss.dart';
import '../codingcombat/CodingBattleGame.dart';

class MainPage extends StatefulWidget {
  final String selectedLanguage;
  const MainPage({Key? key, required this.selectedLanguage}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? _profileImage; // To store the selected profile image
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  String playerName = "Loading...";

  int userXP = 0;
  int userLevel = 1;

  @override
  void initState() {
    super.initState();
    fetchPlayerData();
  }

  // Fetch XP & Level from Firebase
  Future<void> fetchPlayerData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (uid.isNotEmpty) {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('names').doc(uid).get();
        if (userDoc.exists) {
          int xp = userDoc['score'] ?? 0;
          int calculatedLevel = (xp ~/ 100) + 1;
          setState(() {
            playerName = userDoc['name'] ?? "Unknown Player";
            userXP = xp;
            userLevel = calculatedLevel;
          });
          await updateLevel(calculatedLevel);
        }
      }
    } catch (e) {
      print("Error fetching player data: $e");
    }
  }

  // Function to update Level in Firebase
  Future<void> updateLevel(int newLevel) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user signed in!");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('names')
          .doc(user.uid)
          .set({'level': newLevel}, SetOptions(merge: true));
      print("Level updated to $newLevel successfully!");
    } catch (error) {
      print("Error updating level: $error");
    }
  }

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Helper functions to navigate to respective pages
  Widget getGuidesPage() {
    switch (widget.selectedLanguage) {
      case 'Python':
        return GuidesPagePython();
      case 'Java':
        return const GuidesPageJava();
      case 'JavaScript':
        return const GuidesPageJavaScript();
      case 'HTML':
        return const GuidesPageHtml();
      case 'C':
        return const GuidesPageC();
      case 'C++':
        return const GuidesPageCpp();
      default:
        return GuidesPagePython();
    }
  }

  Widget getQuizPage() {
    switch (widget.selectedLanguage) {
      case 'Python':
        return QuizPagePython();
      case 'Java':
        return QuizPageJava();
      case 'JavaScript':
        return QuizPageJavascript();
      case 'HTML':
        return QuizPageHTML();
      case 'C':
        return QuizPageC();
      case 'C++':
        return QuizPageCPP();
      default:
        return QuizPagePython();
    }
  }

  Widget getFlashcardsPage() {
    switch (widget.selectedLanguage) {
      case 'Python':
        return flashcardspythontrial();
      case 'Java':
        return flashcardsjavatrial();
      case 'JavaScript':
        return flashcardsjavascripttrial();
      case 'HTML':
        return flashcardshtmltrial();
      case 'C':
        return FlashcardsCTrial();
      case 'C++':
        return flashcardscpptrial();
      default:
        return flashcardspythontrial();
    }
  }

  Widget getCompilerPage() {
    switch (widget.selectedLanguage) {
      case 'Python':
        return MultiLanguageCompiler();
      case 'Java':
        return MultiLanguageCompiler();
      case 'JavaScript':
        return MultiLanguageCompiler();
      case 'HTML':
        return MultiLanguageCompiler();
      case 'C':
        return MultiLanguageCompiler();
      case 'C++':
        return MultiLanguageCompiler();
      default:
        return MultiLanguageCompiler();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFADA),
      appBar: AppBar(
        title: const Text('Main Page'),
        backgroundColor: const Color(0xFF1A4D2E),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFA7D397),
              Color(0xFFF5EEC8),
              Color(0xFFDCFFB7),
              Color(0xFFA7D397),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Profile Section with option to upload image
                AnimatedContainer(
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A4D2E),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage, // Trigger image selection on tap
                        child: CircleAvatar(
                          radius: 50, // Avatar size
                          backgroundImage: _profileImage == null
                              ? const NetworkImage(
                              'https://www.example.com/avatar.jpg') // Default image
                              : FileImage(_profileImage!) as ImageProvider,
                          child: _profileImage == null
                              ? const Icon(Icons.camera_alt,
                              color: Colors.white, size: 40) // Camera icon when there's no image
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        playerName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level: $userLevel',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'XP: $userXP',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (userXP % 100) / 100, // XP progress within the current level
                        backgroundColor: Colors.white30,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Displaying the selected language
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(seconds: 1),
                  child: Text(
                    'Selected Language: ${widget.selectedLanguage}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Buttons for different actions
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 20, // Horizontal spacing between buttons
                    runSpacing: 20, // Vertical spacing between lines
                    alignment: WrapAlignment.spaceEvenly, // Evenly distribute buttons
                    children: [
                      _buildAnimatedButton('Guides', Icons.menu_book, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => getGuidesPage()),
                        );
                      }),
                      _buildAnimatedButton('Quizzes', Icons.quiz, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => getQuizPage()),
                        );
                      }),
                      _buildAnimatedButton('Combat', Icons.sports_martial_arts, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CharacterSelectionScreen()),
                        );
                      }),
                      _buildAnimatedButton('Leadership', Icons.leaderboard, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LeadershipBoard()),
                        );
                      }),
                      _buildAnimatedButton('Flashcards', Icons.flash_on, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => getFlashcardsPage()),
                        );
                      }),
                      _buildAnimatedButton('Code Runner', Icons.flash_on, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CodexLevels()),
                        );
                      }),
                      _buildAnimatedButton('Compiler', Icons.code, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => getCompilerPage()),
                        );
                      }),
                      _buildAnimatedButton('Scramble On',Icons.person, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ScrambleLevels()),
                        );
                      }),
                      _buildAnimatedButton('More Activities', Icons.more_horiz , () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MoreActivities()),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(String text, IconData icon, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 100, // Fixed width for buttons
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFFA6BB8D),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}