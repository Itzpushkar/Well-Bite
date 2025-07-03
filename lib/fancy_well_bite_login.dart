import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:wellbite/home_page.dart';
import 'register_personal_page.dart';
import 'package:wellbite/pages/home/home_page.dart';

class FancyWellBiteLogin extends StatefulWidget {
  const FancyWellBiteLogin({Key? key}) : super(key: key);

  @override
  State<FancyWellBiteLogin> createState() => _FancyWellBiteLoginState();
}

class _FancyWellBiteLoginState extends State<FancyWellBiteLogin>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  final Color primaryColor = const Color(0xFF008080); // Teal
  final Color accentColor = const Color(0xFFFFD700);  // Gold

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Please try again")),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool obscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure ? _obscurePassword : false,
      validator: (val) {
        if (val == null || val.trim().isEmpty) return "Please enter $label";
        if (label == "Email" && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
          return "Enter a valid email";
        }
        if (label == "Password" && val.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: obscure
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: TextStyle(color: primaryColor),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Positioned(
      top: (size * 2) % 300,
      left: (size * 3) % 250,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          for (double size in [50, 80, 120, 150]) _buildCircle(size, Colors.white.withOpacity(0.1)),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 20),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text("WellBite",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            )),
                        const SizedBox(height: 10),
                        Text("Your Nutrition & Health Assistant",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 30),
                        _buildTextField(
                          label: "Email",
                          icon: Icons.email_outlined,
                          controller: emailController,
                          obscure: false,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: "Password",
                          icon: Icons.lock_outline,
                          controller: passwordController,
                          obscure: true,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (_) => const RegisterPersonalPage())),
                          child: Text("Don't have an account? Register", style: TextStyle(color: primaryColor)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
