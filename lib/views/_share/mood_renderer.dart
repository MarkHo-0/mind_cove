import 'package:flutter/material.dart';
import 'package:mind_cove/diary/model.dart';

class MoodRenderer extends StatelessWidget {
  final Mood mood;
  final double size;

  const MoodRenderer({super.key, required this.mood, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Text(mood.emoji, style: TextStyle(fontSize: size));
  }
}
