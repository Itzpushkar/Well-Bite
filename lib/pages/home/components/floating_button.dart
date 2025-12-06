import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FloatingActionBtn extends StatefulWidget {
  final bool isFormFilled;
  final Color backgroundColor;

  const FloatingActionBtn({
    Key? key,
    required this.isFormFilled,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<FloatingActionBtn> createState() => _FloatingActionBtnState();
}

class _FloatingActionBtnState extends State<FloatingActionBtn> {
  bool isFormFilled = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFormStatus();
  }

  Future<void> _checkFormStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        isFormFilled = doc.data()?['isGoalSubmitted'] == true;
        isLoading = false;
      });
    }
  }

  void _handleFabPress() {
    if (isFormFilled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SchedulePage()),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => RegisterGoalDetailsModal(
          onFormSubmitted: () {
            setState(() {
              isFormFilled = true;
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: _handleFabPress,
      backgroundColor: widget.backgroundColor,
      shape: const CircleBorder(),
      child: Icon(
        isFormFilled ? Icons.schedule : Icons.assignment,
        color: Colors.white,
      ),
    );
  }
}



class RegisterGoalDetailsModal extends StatefulWidget {
  final VoidCallback onFormSubmitted;

  const RegisterGoalDetailsModal({Key? key, required this.onFormSubmitted})
      : super(key: key);

  @override
  State<RegisterGoalDetailsModal> createState() =>
      _RegisterGoalDetailsModalState();
}

class _RegisterGoalDetailsModalState extends State<RegisterGoalDetailsModal> {
  final _formKey = GlobalKey<FormState>();
  final primaryGoalController = TextEditingController();
  final targetWeightController = TextEditingController();
  final durationController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<String> dietOptions = ['Vegetarian', 'Vegan', 'Non-Vegetarian'];
  final List<String> allergiesOptions = ['None', 'Gluten', 'Lactose'];
  final List<String> avoidOptions = ['Sugar', 'Fried Food', 'Junk Food'];

  String? selectedDiet;
  String? selectedAllergy;
  String? selectedAvoid;
  String commitmentLevel = "Very Committed";

  final Color primaryColor = const Color(0xFF008080);
  final Color accentColor = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        primaryGoalController.text = data['primaryGoal'] ?? '';
        targetWeightController.text = data['targetWeight'] ?? '';
        durationController.text = data['duration'] ?? '';
        descriptionController.text = data['goalDescription'] ?? '';
        selectedDiet = data['diet'];
        selectedAllergy = data['allergy'];
        selectedAvoid = data['avoid'];
        commitmentLevel = data['commitment'] ?? 'Very Committed';
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) throw Exception("User not logged in.");

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'primaryGoal': primaryGoalController.text.trim(),
          'targetWeight': targetWeightController.text.trim(),
          'duration': durationController.text.trim(),
          'goalDescription': descriptionController.text.trim(),
          'diet': selectedDiet,
          'allergy': selectedAllergy,
          'avoid': selectedAvoid,
          'commitment': commitmentLevel,
          'isGoalSubmitted': true,
          'updatedAt': Timestamp.now(),
        });

        Navigator.pop(context); // loading
        Navigator.pop(context); // form
        widget.onFormSubmitted();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Goal Details Saved!")),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: label == "Primary Goal"
          ? "Lose 5kg"
          : label == "Target Weight (kg)"
          ? "65"
          : label == "Goal Duration"
          ? "2 Months"
          : label == "Goal Description"
          ? "Want to slim down before vacation."
          : "",
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: TextStyle(color: primaryColor),
    );
  }

  Widget _buildCommitmentSelector() {
    const options = ["Very Committed", "Moderately Committed", "Just Exploring"];
    const icons = ["💪", "👍", "😊"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(options.length, (index) {
        final selected = options[index] == commitmentLevel;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: selected ? Colors.purple.shade50 : null,
                side: BorderSide(color: selected ? Colors.purple : Colors.grey),
              ),
              onPressed: () => setState(() => commitmentLevel = options[index]),
              child: Text("${icons[index]} ${options[index]}",
                  textAlign: TextAlign.center),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
        ),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Step 3: Your Goal Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: primaryGoalController,
                      decoration: _buildInputDecoration("Primary Goal", Icons.flag),
                      validator: (val) =>
                      val == null || val.trim().isEmpty ? "Enter your goal" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: targetWeightController,
                      keyboardType: TextInputType.number,
                      decoration:
                      _buildInputDecoration("Target Weight (kg)", Icons.monitor_weight),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Enter target weight";
                        if (double.tryParse(val) == null) return "Enter a valid number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: durationController,
                      decoration: _buildInputDecoration("Goal Duration", Icons.access_time),
                      validator: (val) =>
                      val == null || val.trim().isEmpty ? "Enter duration" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration:
                      _buildInputDecoration("Goal Description", Icons.description),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedDiet,
                      items: dietOptions
                          .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedDiet = val),
                      decoration: _buildInputDecoration("Diet Preference", Icons.restaurant),
                      validator: (val) => val == null ? "Select diet preference" : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedAllergy,
                      items: allergiesOptions
                          .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedAllergy = val),
                      decoration: _buildInputDecoration("Allergies", Icons.healing),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedAvoid,
                      items: avoidOptions
                          .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedAvoid = val),
                      decoration: _buildInputDecoration("Foods to Avoid", Icons.no_food),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Commitment Level:",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    _buildCommitmentSelector(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child:
                        const Text("Save & Continue", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Schedule")),
      body: const Center(child: Text("Schedule content here")),
    );
  }
}
