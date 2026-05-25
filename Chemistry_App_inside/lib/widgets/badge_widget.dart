import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BadgeWidget extends StatelessWidget {
  final bool isMastered;

  const BadgeWidget({super.key, required this.isMastered});

  @override
  Widget build(BuildContext context) {
    if (!isMastered)
      return const SizedBox.shrink(); // මාස්ටර් වෙලා නැත්නම් පෙන්වන්න එපා

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(
          alpha: 0.2,
        ), // Deprecated warning එකට withValues පාවිච්චි කළා
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.emoji_events, color: Colors.amber, size: 30),
          SizedBox(width: 10),
          Text(
            "Master Badge Unlocked!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
