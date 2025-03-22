import 'package:flutter/material.dart';

class ExportDataButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onExport;

  const ExportDataButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onExport,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
