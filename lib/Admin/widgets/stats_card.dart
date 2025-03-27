import 'package:flutter/material.dart';
import '../../shared/constants/style_constants.dart';

class AdminStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AdminStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = PartnerAdminStyles.accentColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PartnerAdminStyles.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(PartnerAdminStyles.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(PartnerAdminStyles.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingSmall),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(
                      PartnerAdminStyles.borderRadiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: PartnerAdminStyles.paddingMedium),

              // Valeur
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PartnerAdminStyles.textColor,
                    ),
              ),
              const SizedBox(height: PartnerAdminStyles.paddingSmall / 2),

              // Titre
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: PartnerAdminStyles.textColor.withAlpha(179),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
