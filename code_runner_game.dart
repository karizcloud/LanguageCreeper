import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../activity page/main_page.dart';

void main() => runApp(MaterialApp(home: CodeRunnerGame()));

class CodeRunnerGame extends StatefulWidget {
  @override
  _CodeRunnerGameState createState() => _CodeRunnerGameState();
}

class _CodeRunnerGameState extends State<CodeRunnerGame> {
  double dinoY = 0.0;
  double dinoVelocity = 0.0;
  double obstacleX = 1.5;
  bool isPlaying = false;
  int score = 0;
  int currentQuestionIndex = 0;
  List<QuestionResult> results = [];
  bool isObstacleActive = true;
  List<GameQuestion> questions = [];
  final _auth = FirebaseAuth.instance;
  bool showTapToStart = true;

  final double gravity = 0.6;
  final double jumpForce = -15.0;
  final double gameSpeed = 0.035;
  late Timer gameTimer;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection("gamesQB").get();
    final List<DocumentSnapshot> docs = querySnapshot.docs;
    docs.shuffle();
    setState(() {
      questions = docs.take(5).map((doc) {
        return GameQuestion(
          doc["question"],
          [doc["correct"], doc["incorrect"]]..shuffle(),
          0,
        );
      }).toList();
    });
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      showTapToStart = false;
    });
    gameTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    setState(() {
      // Apply gravity
      dinoVelocity += gravity;
      dinoY += dinoVelocity;

      // Prevent falling below ground
      if (dinoY > 0) {
        dinoY = 0;
        dinoVelocity = 0;
      }

      // Move obstacle
      obstacleX -= gameSpeed;
      if (obstacleX < -1.5) {
        resetObstacle();
      }

      // Check for collisions
      if (isObstacleActive && isColliding()) {
        handleCollision();
      }
    });
  }

  bool isColliding() {
    // Only consider collision when the dino is on the ground.
    if (dinoY != 0) return false;
    final dinoRight = 80.0;
    final obstacleLeft = obstacleX * MediaQuery.of(context).size.width;
    return (obstacleLeft < dinoRight && obstacleLeft + 50 > 50);
  }

  void handleCollision() {
    // Only handle collision if the dino is on the ground.
    if (dinoY == 0) {
      gameTimer.cancel();
      isObstacleActive = false;
      showQuestionDialog();
    }
  }

  void showQuestionDialog() {
    if (currentQuestionIndex >= questions.length) {
      showResults();
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuestionDialog(
        question: questions[currentQuestionIndex],
        questionNumber: currentQuestionIndex + 1,
        onAnswered: (selectedIndex) {
          handleAnswer(selectedIndex);
          Navigator.pop(context);
          if (currentQuestionIndex < questions.length) {
            restartGame();
          } else {
            showResults();
          }
        },
      ),
    );
  }

  void handleAnswer(int selectedIndex) {
    final isCorrect = selectedIndex == 0;
    results.add(
        QuestionResult(questions[currentQuestionIndex], selectedIndex, isCorrect));
    if (isCorrect) score += 20;
    currentQuestionIndex++;
  }

  void restartGame() {
    resetObstacle();
    isObstacleActive = true;
    startGame();
  }

  void resetObstacle() {
    obstacleX = 1.5;
  }

  void resetGame() {
    setState(() {
      dinoY = 0.0;
      dinoVelocity = 0.0;
      obstacleX = 1.5;
      isPlaying = false;
      score = 0;
      currentQuestionIndex = 0;
      results.clear();
      isObstacleActive = true;
      showTapToStart = true;
    });
  }

  void showResults() async {
    await updateScoreInDatabase();
    showDialog(
      context: context,
      builder: (context) => ResultsDialog(
        score: score,
        onExit: () {
          Navigator.pop(context); // Close Dialog
          resetGame();
        },
      ),
    );
  }

  Future<void> updateScoreInDatabase() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final userRef =
    FirebaseFirestore.instance.collection("names").doc(user.uid);
    final doc = await userRef.get();
    if (doc.exists) {
      int currentScore = doc.data()?['score'] ?? 0;
      await userRef.update({"score": currentScore + score});
    } else {
      await userRef.set({"score": score});
    }
  }

  void jump() {
    if (dinoY == 0) {
      setState(() {
        dinoVelocity = jumpForce;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (isPlaying) {
            jump();
          } else {
            startGame();
          }
        },
        child: Container(
          color: Colors.blue[200],
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child:
                Container(height: 40, color: Colors.green[700]),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 50),
                bottom: 100 + dinoY,
                left: 20,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi), // Flips it horizontally
                  child: Text("🦖", style: TextStyle(fontSize: 60)),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 30),
                bottom: 100,
                left: obstacleX * MediaQuery.of(context).size.width,
                child: Text("🌵", style: TextStyle(fontSize: 50)),
              ),
              if (showTapToStart)
                Center(
                  child: Text(
                    "Tap to Start the Game!",
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              Positioned(
                top: 50,
                left: 20,
                child: Text("Score: $score",
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  GameQuestion(this.question, this.options, this.correctIndex);
}

class QuestionResult {
  final GameQuestion question;
  final int selectedIndex;
  final bool isCorrect;
  QuestionResult(this.question, this.selectedIndex, this.isCorrect);
}

class ResultsDialog extends StatelessWidget {
  final int score;
  final VoidCallback onExit;

  ResultsDialog({required this.score, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Game Over!"),
      content: Text("Score: $score"),
      actions: [
        TextButton(
          onPressed: onExit,
          child: Text("Restart"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(selectedLanguage: ''),
              ),
            );
          },
          child: Text("Exit"),
        ),
      ],
    );
  }
}

class QuestionDialog extends StatelessWidget {
  final GameQuestion question;
  final int questionNumber;
  final Function(int) onAnswered;

  QuestionDialog({
    required this.question,
    required this.questionNumber,
    required this.onAnswered,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Question $questionNumber"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(question.question),
          SizedBox(height: 10), // Space between question and options
          ...List.generate(question.options.length, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 5), // Space between buttons
              child: ElevatedButton(
                onPressed: () => onAnswered(index),
                child: Text(question.options[index]),
              ),
            );
          }),
        ],
      ),
    );
  }
}