import 'package:flutter/material.dart';

/// AppBar personnalisée pour les écrans des modules utilisateur
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color backgroundColor;
  final Color foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor = const Color(0xFF524B46), // Couleur accent par défaut
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}