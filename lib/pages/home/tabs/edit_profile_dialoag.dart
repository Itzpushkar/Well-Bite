import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileDialog extends StatefulWidget {
  final String userId;

  const EditProfileDialog({Key? key, required this.userId}) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final emailController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String goal = "Maintain Weight";
  bool showPasswordFields = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final data = doc.data()!;
    setState(() {
      nameController.text = data['name'] ?? '';
      ageController.text = data['age'] ?? '';
      heightController.text = data['height'] ?? '';
      weightController.text = data['weight'] ?? '';
      goal = data['goal'] ?? '';
      emailController.text = data['email'] ?? '';
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isSaving = true);
      final user = FirebaseAuth.instance.currentUser!;

      if (currentPasswordController.text.isNotEmpty) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(cred);

        if (newPasswordController.text.isNotEmpty) {
          await user.updatePassword(newPasswordController.text);
        }
      }

      if (emailController.text != user.email) {
        await user.updateEmail(emailController.text);
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': nameController.text,
        'age': ageController.text,
        'height': heightController.text,
        'weight': weightController.text,
        'goal': goal,
        'email': emailController.text,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.black87),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: const TextStyle(color: Colors.teal),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8), // Transparent feel
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white30, // fully transparent
      insetPadding: const EdgeInsets.all(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // blur dialog background
        child: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // glass look
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Edit Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  TextFormField(controller: nameController, decoration: _inputDecoration("Name", Icons.person)),
                  const SizedBox(height: 12),
                  TextFormField(controller: ageController, keyboardType: TextInputType.number, decoration: _inputDecoration("Age", Icons.cake)),
                  const SizedBox(height: 12),
                  TextFormField(controller: heightController, keyboardType: TextInputType.number, decoration: _inputDecoration("Height (cm)", Icons.height)),
                  const SizedBox(height: 12),
                  TextFormField(controller: weightController, keyboardType: TextInputType.number, decoration: _inputDecoration("Weight (kg)", Icons.monitor_weight)),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: goal,
                    items: ["Maintain Weight", "Lose Weight", "Gain Muscle", "Improve Health"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => goal = val!),
                    decoration: _inputDecoration("Goal", Icons.flag),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(controller: emailController, decoration: _inputDecoration("Email", Icons.email)),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Current Password", Icons.lock),
                    onTap: () {
                      setState(() => showPasswordFields = true);
                    },
                  ),

                  // Animated password fields
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: showPasswordFields
                        ? Column(
                      children: [
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: _inputDecoration("New Password", Icons.lock_open),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: _inputDecoration("Confirm New Password", Icons.lock_outline),
                          validator: (val) {
                            if (newPasswordController.text != val) return "Passwords do not match";
                            return null;
                          },
                        ),
                      ],
                    )
                        : const SizedBox(),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            side: const BorderSide(color: Colors.teal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isSaving
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text("Save Changes"),
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
    );
  }
}
