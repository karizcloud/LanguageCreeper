import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'code_runner_game.dart';

class CodexLevels extends StatefulWidget {
  const CodexLevels({Key? key}) : super(key: key);

  @override
  _CodexLevelsState createState() => _CodexLevelsState();
}

class _CodexLevelsState extends State<CodexLevels> {
  int? selectedLevel;
  ui.Image? backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  Future<void> _loadBackgroundImage() async {
    final image = await _loadImage('assets/levelsBG.jpg'); // Replace with your background asset path
    setState(() {
      backgroundImage = image;
    });
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final data = await DefaultAssetBundle.of(context).load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A4D2E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A4D2E),
        title: const Text('Select Codex Level'),
      ),
      body: backgroundImage == null
          ? const Center(child: CircularProgressIndicator())
          : CustomPaint(
        painter: BackgroundPainter(backgroundImage!),
        child: SingleChildScrollView(
          child: SizedBox(
            height: 1200,
            child: Stack(
              children: [
                // Draw the root path
                CustomPaint(
                  size: const Size(double.infinity, 1200),
                  painter: RootPathPainter(),
                ),

                // Leaf-shaped level buttons
                Center(
                  child: Stack(
                    children: [
                      for (int i = 1; i <= 10; i++)
                        Positioned(
                          top: _getNodePosition(i).dy,
                          left: MediaQuery.of(context).size.width / 2 + _getNodePosition(i).dx,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLevel = i;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: selectedLevel == i ? 80 : 70,
                              height: selectedLevel == i ? 80 : 70,
                              decoration: BoxDecoration(
                                color: selectedLevel == i ? Colors.green : Colors.blue.shade400,
                                border: Border.all(
                                  color: Colors.brown,
                                  width: 4,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(40),
                                ), // Creates a leaf shape
                                boxShadow: [
                                  if (selectedLevel == i)
                                    const BoxShadow(
                                      color: Colors.yellow,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$i',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Next button
                Positioned(
                  bottom: 20,
                  left: MediaQuery.of(context).size.width * 0.5 - 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: selectedLevel == null
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CodeRunnerGame(),
                        ),
                      );
                    },
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset _getNodePosition(int level) {
    switch (level) {
      case 1:
        return Offset(0, 900);
      case 2:
        return Offset(-100, 800);
      case 3:
        return Offset(100, 700);
      case 4:
        return Offset(-150, 600);
      case 5:
        return Offset(150, 500);
      case 6:
        return Offset(-100, 400);
      case 7:
        return Offset(100, 300);
      case 8:
        return Offset(-50, 200);
      case 9:
        return Offset(50, 100);
      case 10:
        return Offset(0, 0);
      default:
        return Offset(0, 0);
    }
  }
}

class BackgroundPainter extends CustomPainter {
  final ui.Image backgroundImage;

  BackgroundPainter(this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImageRect(
      backgroundImage,
      Rect.fromLTWH(0, 0, backgroundImage.width.toDouble(), backgroundImage.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RootPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final path = Path();
    final positions = [
      Offset(0, 900),
      Offset(-100, 800),
      Offset(100, 700),
      Offset(-150, 600),
      Offset(150, 500),
      Offset(-100, 400),
      Offset(100, 300),
      Offset(-50, 200),
      Offset(50, 100),
      Offset(0, 0),
    ];

    path.moveTo(size.width / 2 + positions[0].dx, positions[0].dy);
    for (int i = 1; i < positions.length; i++) {
      final controlPoint = Offset(
        (positions[i - 1].dx + positions[i].dx) / 2 + size.width / 2,
        (positions[i - 1].dy + positions[i].dy) / 2,
      );
      path.quadraticBezierTo(
        size.width / 2 + positions[i - 1].dx,
        positions[i - 1].dy,
        controlPoint.dx,
        controlPoint.dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}