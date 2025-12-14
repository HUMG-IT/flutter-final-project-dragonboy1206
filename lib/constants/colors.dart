import 'package:flutter/material.dart';

class NoteColors {
  static const Map<String, Color> colors = {
    'blue': Color(0xFF90CAF9),
    'green': Color(0xFFA5D6A7),
    'yellow': Color(0xFFFFF59D),
    'orange': Color(0xFFFFCC80),
    'pink': Color(0xFFF48FB1),
    'purple': Color(0xFFCE93D8),
    'red': Color(0xFFEF9A9A),
    'teal': Color(0xFF80CBC4),
  };

  static Color getColor(String colorName) {
    return colors[colorName] ?? colors['blue']!;
  }

  static List<String> get colorNames => colors.keys.toList();
}
