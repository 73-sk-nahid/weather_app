import 'package:flutter/material.dart';

class HourlyForeCastWidgets extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temperature;
  const HourlyForeCastWidgets(
      {super.key, required this.time, required this.icon, required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Icon(
              icon,
              size: 23,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              temperature,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
