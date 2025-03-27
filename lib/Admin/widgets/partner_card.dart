import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Partner/models/partner_model.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';

class PartnerCard extends StatelessWidget {
  final PartnerModel partner;
  final VoidCallback? onVerifyToggle;
  final VoidCallback? onActiveToggle;

  const PartnerCard({
    Key? key,
    required this.partner,
    this.onVerifyToggle,
    this.onActiveToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PartnerAdminStyles.elevationSmall,
      margin: const EdgeInsets.only(bottom: PartnerAdminStyles.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(PartnerAdminStyles.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et badges
            Row(
              children: [
                // Image du prestataire (ou avatar par défaut)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: PartnerAdminStyles.secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                    image:
                        partner.imageUrl != null && partner.imageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(partner.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: partner.imageUrl == null || partner.imageUrl!.isEmpty
                      ? const Icon(
                          Icons.business,
                          color: PartnerAdminStyles.accentColor,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: PartnerAdminStyles.paddingMedium),

                // Nom et type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.nomEntreprise,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Contact: ${partner.nomContact}',
                        style: TextStyle(
                          color: PartnerAdminStyles.textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badges de statut
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(
                      partner.isVerified,
                      trueText: 'Vérifié',
                      falseText: 'Non vérifié',
                      trueColor: PartnerAdminStyles.successColor,
                      falseColor: PartnerAdminStyles.warningColor,
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(
                      partner.actif,
                      trueText: 'Actif',
                      falseText: 'Inactif',
                      trueColor: PartnerAdminStyles.infoColor,
                      falseColor: PartnerAdminStyles.errorColor,
                    ),
                  ],
                ),
              ],
            ),

            // Information sur la région
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: PartnerAdminStyles.paddingSmall),
              child: Text(
                'Région: ${partner.region}',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            // Information sur le budget
            Text(
              'Budget: ${_formatBudgetType(partner.typeBudget)}',
              style: const TextStyle(fontSize: 14),
            ),

            const Divider(height: 24),

            // Boutons d'action
            Wrap(
              spacing: 8, // espace horizontal entre les éléments
              runSpacing: 8, // espace vertical entre les lignes
              alignment: WrapAlignment.spaceBetween,
              children: [
                // Bouton pour voir les détails
                OutlinedButton.icon(
                  onPressed: () {
                    context.go(
                        '${PartnerAdminRoutes.adminPartnerEdit.replaceAll(':id', '')}${partner.id}');
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Détails'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PartnerAdminStyles.accentColor,
                    side:
                        const BorderSide(color: PartnerAdminStyles.accentColor),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),

                // Bouton pour basculer la vérification - avec taille réduite
                OutlinedButton.icon(
                  onPressed: onVerifyToggle,
                  icon: Icon(
                    partner.isVerified ? Icons.cancel : Icons.verified_user,
                    size: 16,
                  ),
                  label: Text(
                    partner.isVerified ? 'Annuler' : 'Vérifier',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: partner.isVerified
                        ? PartnerAdminStyles.warningColor
                        : PartnerAdminStyles.successColor,
                    side: BorderSide(
                      color: partner.isVerified
                          ? PartnerAdminStyles.warningColor
                          : PartnerAdminStyles.successColor,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),

                // Bouton pour basculer l'activation - avec taille réduite
                OutlinedButton.icon(
                  onPressed: onActiveToggle,
                  icon: Icon(
                    partner.actif ? Icons.block : Icons.check_circle,
                    size: 16,
                  ),
                  label: Text(
                    partner.actif ? 'Désactiver' : 'Activer',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: partner.actif
                        ? PartnerAdminStyles.errorColor
                        : PartnerAdminStyles.infoColor,
                    side: BorderSide(
                      color: partner.actif
                          ? PartnerAdminStyles.errorColor
                          : PartnerAdminStyles.infoColor,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    bool status, {
    required String trueText,
    required String falseText,
    required Color trueColor,
    required Color falseColor,
  }) {
    final text = status ? trueText : falseText;
    final color = status ? trueColor : falseColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PartnerAdminStyles.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius:
            BorderRadius.circular(PartnerAdminStyles.borderRadiusSmall),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatBudgetType(String typeBudget) {
    switch (typeBudget) {
      case 'abordable':
        return 'Abordable';
      case 'premium':
        return 'Premium';
      case 'luxe':
        return 'Luxe';
      default:
        return typeBudget;
    }
  }
}
