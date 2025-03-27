import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs de la DA
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2B2B2B);
  static const Color beige = Color(0xFFFFF3E4);
  static const Color accentColor = Color(0xFF524B46);

  static ThemeData get lightTheme {
    return ThemeData(
      // Schéma de couleurs basé sur la DA
      colorScheme: const ColorScheme.light(
        primary: accentColor,
        secondary: beige,
        surface: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: textColor,
        onSurface: textColor,
      ),
      
      // Polices personnalisées
      textTheme: TextTheme(
        // Police principale Lato pour le corps de texte
        bodyLarge: GoogleFonts.lato(color: textColor, fontSize: 16),
        bodyMedium: GoogleFonts.lato(color: textColor, fontSize: 14),
        bodySmall: GoogleFonts.lato(color: textColor, fontSize: 12),
        
        // Police Playfair pour les titres
        displayLarge: GoogleFonts.playfairDisplay(color: textColor, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.playfairDisplay(color: textColor, fontWeight: FontWeight.bold, fontSize: 28),
        displaySmall: GoogleFonts.playfairDisplay(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
        
        headlineLarge: GoogleFonts.playfairDisplay(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
        headlineMedium: GoogleFonts.playfairDisplay(color: textColor, fontSize: 20),
        headlineSmall: GoogleFonts.playfairDisplay(color: textColor, fontSize: 18),
        
        titleLarge: GoogleFonts.playfairDisplay(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.lato(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.lato(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      
      // Utilisation de Material 3
      useMaterial3: true,
      
      // Thème de la barre d'application
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      
      // Thème des boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: accentColor,
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
      
      // Thème des cartes
      cardTheme: CardTheme(
        color: backgroundColor,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      
      // Thème des champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: beige.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 1),
        ),
        hintStyle: GoogleFonts.lato(color: textColor.withOpacity(0.5)),
      ),
      
      // Thème de la barre de navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textColor,
      ),
      
      // Thème des boîtes de dialogue
      dialogTheme: DialogTheme(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.lato(
          color: textColor,
          fontSize: 16,
        ),
      ),
    );
  }

  // Thème sombre - conservé mais adapté à la DA
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: beige,
        secondary: accentColor,
        surface: textColor,
        onPrimary: textColor,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      
      textTheme: TextTheme(
        // Police principale Lato pour le corps de texte
        bodyLarge: GoogleFonts.lato(color: Colors.white, fontSize: 16),
        bodyMedium: GoogleFonts.lato(color: Colors.white, fontSize: 14),
        bodySmall: GoogleFonts.lato(color: Colors.white, fontSize: 12),
        
        // Police Playfair pour les titres
        displayLarge: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        displaySmall: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        
        headlineLarge: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        headlineMedium: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20),
        headlineSmall: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18),
        
        titleLarge: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.lato(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.lato(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      
      useMaterial3: true,
      
      appBarTheme: AppBarTheme(
        backgroundColor: textColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: beige,
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );
  }
}