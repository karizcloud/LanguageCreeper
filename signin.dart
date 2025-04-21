import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../welcome/language.dart';
import '../welcome/login.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _showContainer = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _showContainer = true);
      _animationController.forward();
    });

    // Add focus listeners
    _emailFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_passwordFocusNode.hasFocus) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('names').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'uid': user.uid,
          'score': 0,
          'level': 1,
          'gamesPlayed': 0,
        });

        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => LanguageSelectionScreen()));
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth Errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 67, 104, 80),
        elevation: 0,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA7D397), Color(0xFFF5EEC8), Color(0xFFDCFFB7), Color(0xFFA7D397)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Logo and Text
            Positioned(
              top: screenHeight * 0.1,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Glowing Logo (Same as Login)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset('assets/faviconfinal.png', width: 100, height: 100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Let's Adventure Together!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black54,
                          offset: Offset(2, 2),)
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Animated Container (Now Smaller)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: _showContainer
                  ? (viewInsets.bottom > 0 ? 20 : screenHeight * 0.15)
                  : screenHeight * 0.5,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.6,
                            minHeight: 400,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white.withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                              left: 20,
                              right: 20,
                              top: 20,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Name Field with Focus Animation
                                  Focus(
                                    onFocusChange: (_) => setState(() {}),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      transform: Matrix4.identity()
                                        ..scale(_nameFocusNode.hasFocus ? 1.02 : 1.0),
                                      child: TextFormField(
                                        controller: _nameController,
                                        focusNode: _nameFocusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                          labelStyle: TextStyle(
                                            color: _nameFocusNode.hasFocus
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          border: _buildOutlineInputBorder(),
                                          focusedBorder: _buildOutlineInputBorder(color: Colors.green),
                                        ),
                                        validator: (v) => v!.isEmpty ? 'Enter name' : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  // Email Field (Same Focus Animation)
                                  Focus(
                                    onFocusChange: (_) => setState(() {}),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      transform: Matrix4.identity()
                                        ..scale(_emailFocusNode.hasFocus ? 1.02 : 1.0),
                                      child: TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: TextStyle(
                                            color: _emailFocusNode.hasFocus
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          border: _buildOutlineInputBorder(),
                                          focusedBorder: _buildOutlineInputBorder(color: Colors.green),
                                        ),
                                        validator: (v) => !RegExp(r'^[a-zA-Z0-9.%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v!)
                                            ? 'Invalid email'
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  // Password Field
                                  Focus(
                                    onFocusChange: (_) => setState(() {}),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      transform: Matrix4.identity()
                                        ..scale(_passwordFocusNode.hasFocus ? 1.02 : 1.0),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          labelStyle: TextStyle(
                                            color: _passwordFocusNode.hasFocus
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          border: _buildOutlineInputBorder(),
                                          focusedBorder: _buildOutlineInputBorder(color: Colors.green),
                                        ),
                                        validator: (v) => !RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(v!)
                                            ? 'At least 8 characters with a letter and a number'
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  // Animated Button
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: _formKey.currentState?.validate() ?? false
                                          ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                          : null,
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 100, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30)),
                                      ),
                                      onPressed: _isLoading ? null : _signUpUser,
                                      child: _isLoading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                          : const Text(
                                        'SIGN UP',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  // Login Link
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                        context, MaterialPageRoute(builder: (_) => Login())),
                                    child: const Text.rich(
                                      TextSpan(
                                        text: 'Already have an account? ',
                                        style: TextStyle(color: Colors.grey),
                                        children: [
                                          TextSpan(
                                            text: 'Login',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder({Color color = Colors.grey}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color.withOpacity(0.5), width: 1.5),
    );
  }
}