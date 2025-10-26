import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart'; // Import the router

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Define Seed Color and Text Theme
    const Color seedColor = Color(0xFF4A6572); // A nice slate blue

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.lato(fontSize: 16),
      bodyMedium: GoogleFonts.lato(fontSize: 14),
      bodySmall: GoogleFonts.lato(fontSize: 12),
      labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
      labelMedium: GoogleFonts.lato(fontSize: 12),
      labelSmall: GoogleFonts.lato(fontSize: 10),
    );

    // 2. Create the ThemeData
    final ThemeData theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        centerTitle: true,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: seedColor,
        unselectedItemColor: Colors.grey,
      ),
    );

    // 3. Apply the theme in MaterialApp.router
    return MaterialApp.router(
      title: 'Photo Manager Pro',
      theme: theme,
      routerConfig: router, // Use the router
      debugShowCheckedModeBanner: false,
    );
  }
}
