// lib/Partner/widgets/stats/stats_card_large.dart
import 'package:flutter/material.dart';
import '../../../shared/constants/style_constants.dart';

class StatsCardLarge extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color? color;
  final bool isLoading;

  const StatsCardLarge({
    Key? key,
    required this.title,
    required this.value,
    this.subValue,
    required this.icon,
    this.color,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? PartnerAdminStyles.accentColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et icône
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: cardColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: PartnerAdminStyles.textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Valeur principale
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),

            // Valeur secondaire (optionnelle)
            if (subValue != null && !isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  subValue!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
