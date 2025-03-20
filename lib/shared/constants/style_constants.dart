import 'package:flutter/material.dart';

/// Constantes de style pour les modules partenaires et admin
class PartnerAdminStyles {
  // Couleurs principales (reprises du thème existant)
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2B2B2B);
  static const Color beige = Color(0xFFFFF3E4);
  static const Color accentColor = Color(0xFF524B46);

  // Couleurs spécifiques aux modules
  static const Color successColor = Color(0xFF3CB371);
  static const Color warningColor = Color(0xFFFFA500);
  static const Color errorColor = Color(0xFFDC3545);

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  // InputDecoration par défaut
  static InputDecoration defaultInputDecoration(String label,
      {String? hint, Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
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
    );
  }

  // Style de bouton par défaut
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: accentColor,
    side: const BorderSide(color: accentColor),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
