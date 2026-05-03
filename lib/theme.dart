import 'package:flutter/material.dart';

class AppTheme {
  static Color bg(bool dark) => dark ? const Color(0xFF111111) : Colors.white;
  static Color surface(bool dark) => dark ? const Color(0xFF1C1C1C) : const Color(0xFFF5F5F5);
  static Color primary(bool dark) => dark ? Colors.white : Colors.black;
  static Color secondary(bool dark) => dark ? const Color(0xFF777777) : const Color(0xFFAAAAAA);
  static Color tertiary(bool dark) => dark ? const Color(0xFF444444) : const Color(0xFFCCCCCC);
  static Color divider(bool dark) => dark ? const Color(0xFF222222) : const Color(0xFFF0F0F0);
  static Color quranPage(bool dark) => dark ? const Color(0xFF151310) : const Color(0xFFF9F7F2);
  static Color quranText(bool dark) => dark ? const Color(0xFFDDDAD2) : const Color(0xFF1A1A1A);
  static Color selected(bool dark) => dark ? const Color(0xFF3A3A3A) : const Color(0xFFCCCCCC);
}
