import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget de bouton personnalisé pour les connexions sociales (Google, Apple, etc.)
class CustomSocialButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double height;
  final double fontSize;
  final double iconSize;

  const CustomSocialButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 8.0,
    this.height = 50.0,
    this.fontSize = 16.0,
    this.iconSize = 18.0,
  });

  /// Bouton Google préconfiguré
  factory CustomSocialButton.google({
    required VoidCallback onPressed,
    String text = 'Continuer avec Google',
  }) {
    return CustomSocialButton(
      onPressed: onPressed,
      text: text,
      icon: FontAwesomeIcons.google,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      borderColor: Colors.grey.withOpacity(0.3),
    );
  }

  /// Bouton Apple préconfiguré
  factory CustomSocialButton.apple({
    required VoidCallback onPressed,
    String text = 'Continuer avec Apple',
  }) {
    return CustomSocialButton(
      onPressed: onPressed,
      text: text,
      icon: FontAwesomeIcons.apple,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  /// Bouton Facebook préconfiguré
  factory CustomSocialButton.facebook({
    required VoidCallback onPressed,
    String text = 'Continuer avec Facebook',
  }) {
    return CustomSocialButton(
      onPressed: onPressed,
      text: text,
      icon: FontAwesomeIcons.facebook,
      backgroundColor: const Color(0xFF1877F2),
      textColor: Colors.white,
    );
  }

  @override
  State<CustomSocialButton> createState() => _CustomSocialButtonState();
}

class _CustomSocialButtonState extends State<CustomSocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: widget.borderColor != null
              ? Border.all(
                  color: widget.borderColor!,
                  width: widget.borderWidth,
                )
              : null,
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              widget.icon,
              color: widget.textColor,
              size: widget.iconSize,
            ),
            const SizedBox(width: 12),
            Text(
              widget.text,
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}