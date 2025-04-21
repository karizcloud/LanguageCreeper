import 'package:flutter/material.dart';
import 'signin.dart';
import 'language.dart';
import 'forgotpass.dart';
import '../auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  bool _showContainer = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9.%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

  String _emailError = '';
  String _passwordError = '';
  String _userName = '';

  final AuthService _authService = AuthService();

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

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() => _showContainer = true);
      _animationController.forward();
    });

    _fetchUserName();
    _emailFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_passwordFocusNode.hasFocus) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 5000),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => _userName = user.displayName ?? 'User');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() => _emailError = emailRegex.hasMatch(_emailController.text) ? '' : 'Enter a valid email');
  }

  void _validatePassword() {
    setState(() => _passwordError = _passwordRegex.hasMatch(_passwordController.text)
        ? ''
        : 'At least 8 characters with a letter and a number');
  }

  bool _isFormValid() {
    return _emailError.isEmpty &&
        _passwordError.isEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    if (_isFormValid()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signIn(_emailController.text, _passwordController.text);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String message = e.code == 'user-not-found'
            ? 'No user found for that email.'
            : e.code == 'wrong-password'
            ? 'Wrong password provided.'
            : 'Login failed. Try again.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF1A4D2E),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            // Background Gradient
            Container(
              height: double.infinity,
              width: double.infinity,
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
                  // Glowing Logo
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 2000),
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
                      child: Image.asset(
                        'assets/faviconfinal.png', // Replace with your logo path
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Interactive Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 2000),
                    child: Text(
                      'Resume Your Adventure!',
                      key: const ValueKey('Resume Your Adventure!'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Animated Login Container
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: _showContainer ? (viewInsets.bottom > 0 ? 20 : screenHeight * 0.15) : screenHeight * 0.5,
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_userName.isNotEmpty)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text('Welcome, $_userName!',
                                        key: ValueKey(_userName),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  ),
                                const SizedBox(height: 20),

                                // Email Field
                                Focus(
                                  onFocusChange: (hasFocus) => setState(() {}),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()..scale(_emailFocusNode.hasFocus ? 1.02 : 1.0),
                                    child: TextField(
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      decoration: InputDecoration(
                                        labelText: 'Email Address',
                                        labelStyle: TextStyle(
                                          color: _emailFocusNode.hasFocus ? Colors.green : Colors.grey,
                                        ),
                                        errorText: _emailError.isEmpty ? null : _emailError,
                                        border: _buildOutlineInputBorder(),
                                        focusedBorder: _buildOutlineInputBorder(color: Colors.green),
                                      ),
                                      onChanged: (_) => _validateEmail(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),

                                // Password Field
                                Focus(
                                  onFocusChange: (hasFocus) => setState(() {}),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()..scale(_passwordFocusNode.hasFocus ? 1.02 : 1.0),
                                    child: TextField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: TextStyle(
                                          color: _passwordFocusNode.hasFocus ? Colors.green : Colors.grey,
                                        ),
                                        errorText: _passwordError.isEmpty ? null : _passwordError,
                                        border: _buildOutlineInputBorder(),
                                        focusedBorder: _buildOutlineInputBorder(color: Colors.green),
                                        suffixIcon: IconButton(
                                          icon: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child: Icon(
                                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                              key: ValueKey(_obscurePassword),
                                              color: Colors.grey,
                                            ),
                                          ),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      onChanged: (_) => _validatePassword(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.push(
                                        context, MaterialPageRoute(builder: (_) => Forgotpass())),
                                    child: const Text('Forgot Password?',
                                        style: TextStyle(color: Colors.green)),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Login Button
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: _isFormValid()
                                        ? [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
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
                                    onPressed: _isFormValid() && !_isLoading ? _handleLogin : null,
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                        : const Text('LOGIN',
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(height: 25),

                                // Sign Up
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context, MaterialPageRoute(builder: (_) => SignIn())),
                                  child: const Text.rich(
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(color: Colors.grey),
                                      children: [
                                        TextSpan(
                                          text: 'Sign up',
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