import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProfilePage extends StatefulWidget {
  final String userId;

  const UpdateProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  String goal = 'Maintain Weight';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      ageController.text = data['age'] ?? '';
      heightController.text = data['height'] ?? '';
      weightController.text = data['weight'] ?? '';
      goal = data['goal'] ?? goal;
    }
    setState(() => isLoading = false);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': nameController.text,
        'age': ageController.text,
        'height': heightController.text,
        'weight': weightController.text,
        'goal': goal,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) => val == null || val.isEmpty ? "Enter Name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
                validator: (val) => val == null || val.isEmpty ? "Enter Age" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: heightController,
                decoration: const InputDecoration(labelText: "Height (cm)"),
                validator: (val) => val == null || val.isEmpty ? "Enter Height" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
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
                decoration: const InputDecoration(labelText: "Goal"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
