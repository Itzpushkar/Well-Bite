import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fancy_well_bite_login.dart';

class RegisterPhysicalPage extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const RegisterPhysicalPage({
    Key? key,
    required this.name,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<RegisterPhysicalPage> createState() => _RegisterPhysicalPageState();
}

class _RegisterPhysicalPageState extends State<RegisterPhysicalPage> {
  final _formKey = GlobalKey<FormState>();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  String goal = 'Maintain Weight';

  final Color primaryColor = const Color(0xFF008080); // Teal
  final Color accentColor = const Color(0xFFFFD700);  // Gold

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: widget.email, password: widget.password);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': widget.name,
          'email': widget.email,
          'password': widget.password,
          'age': ageController.text,
          'height': heightController.text,
          'weight': weightController.text,
          'goal': goal,
          'createdAt': Timestamp.now(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FancyWellBiteLogin()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e")),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
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
      top: (size * 2.7) % 300,
      left: (size * 3.1) % 250,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          for (double size in [50, 80, 130]) _buildCircle(size),
          Center(
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
                        "Step 2: Physical Info",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ageController,
                        decoration: _inputDecoration("Age", Icons.cake),
                        validator: (val) => val == null || val.isEmpty ? "Enter Age" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: heightController,
                        decoration: _inputDecoration("Height (cm)", Icons.height),
                        validator: (val) => val == null || val.isEmpty ? "Enter Height" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: weightController,
                        decoration: _inputDecoration("Weight (kg)", Icons.monitor_weight),
                        validator: (val) => val == null || val.isEmpty ? "Enter Weight" : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: goal,
                        items: [
                          "Lose Weight",
                          "Gain Muscle",
                          "Maintain Weight",
                          "Improve Health"
                        ]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => goal = val!),
                        decoration: _inputDecoration("Health Goal", Icons.flag),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: BorderSide(color: primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text("Back"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text("Get Started"),
                            ),
                          ),
                        ],
                      )
                    ],
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
