import 'package:flutter/material.dart';

class Additionalinformation extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const Additionalinformation(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 40,
        ),
        const SizedBox(
          height: 8.00,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(
          height: 8.00,
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
