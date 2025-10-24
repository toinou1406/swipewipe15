import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appThemeProvider = Provider((ref) => AppTheme());

class AppTheme {
  final lightTheme = ThemeData.light();
  final darkTheme = ThemeData.dark();
}
