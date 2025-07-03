import 'package:flutter/material.dart';
import 'register_physical_page.dart';

class RegisterPersonalPage extends StatefulWidget {
  const RegisterPersonalPage({Key? key}) : super(key: key);

  @override
  State<RegisterPersonalPage> createState() => _RegisterPersonalPageState();
}

class _RegisterPersonalPageState extends State<RegisterPersonalPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  final Color primaryColor = const Color(0xFF008080); // Teal
  final Color accentColor = const Color(0xFFFFD700);  // Gold

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon, {bool obscure = false}) {
    return InputDecoration(
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
    );
  }

  Widget _buildCircle(double size) {
    return Positioned(
      top: (size * 3) % 300,
      left: (size * 2.5) % 250,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterPhysicalPage(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          for (double size in [60, 90, 130]) _buildCircle(size),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Step 1: Personal Info",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameController,
                          maxLength: 30,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Enter Full Name";
                            if (val.length < 3) return "Minimum 3 characters";
                            return null;
                          },
                          decoration: _inputDecoration("Full Name", Icons.person),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Enter Email";
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return "Invalid Email";
                            return null;
                          },
                          decoration: _inputDecoration("Email", Icons.email),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          validator: (val) => val != null && val.length >= 6 ? null : "Minimum 6 characters",
                          decoration: _inputDecoration("Password", Icons.lock, obscure: true),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                          ),
                          child: const Text("Next"),
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
