import 'package:flutter/material.dart';

class FloatingActionBtn extends StatelessWidget {
  final bool isFormFilled;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const FloatingActionBtn({
    Key? key,
    required this.isFormFilled,
    required this.onPressed,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      shape: const CircleBorder(),
      child: Icon(
        isFormFilled ? Icons.schedule : Icons.assignment,
        color: Colors.white,
      ),
    );
  }
}
