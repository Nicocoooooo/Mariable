import 'package:flutter/material.dart';
import '../../../shared/constants/style_constants.dart';
import '../../models/data/tarif_model.dart';
import 'package:intl/intl.dart';

class OfferCard extends StatelessWidget {
  final TarifModel offer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggleVisibility;

  const OfferCard({
    super.key,
    required this.offer,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    // Formatteur de prix en euros
    final priceFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: 2,
    );

    // Formattage du prix selon le type
    final String formattedPrice = priceFormat.format(offer.prixBase);
    final String priceDisplay = offer.typePrix == 'par_personne'
        ? '$formattedPrice / pers.'
        : formattedPrice;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: offer.isVisible
              ? PartnerAdminStyles.accentColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et badge de statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    offer.nomFormule,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PartnerAdminStyles.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge de visibilité
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: offer.isVisible
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    offer.isVisible ? 'Visible' : 'Masquée',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: offer.isVisible
                          ? Colors.green.shade800
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Prix et type de tarification
            Row(
              children: [
                const Icon(
                  Icons.euro,
                  size: 20,
                  color: PartnerAdminStyles.accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  priceDisplay,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PartnerAdminStyles.textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Nombre d'invités
            if (offer.minInvites != null || offer.maxInvites != null)
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getInvitesText(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: PartnerAdminStyles.textColor,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            // Coefficients
            if (offer.coefWeekend != null || offer.coefHauteSaison != null)
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getCoefficientsText(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: PartnerAdminStyles.textColor,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Description (limitée)
            Text(
              offer.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Bouton de visibilité
                IconButton(
                  onPressed: () => onToggleVisibility(!offer.isVisible),
                  icon: Icon(
                    offer.isVisible ? Icons.visibility : Icons.visibility_off,
                    color: offer.isVisible ? Colors.green : Colors.grey,
                  ),
                  tooltip: offer.isVisible
                      ? 'Masquer cette offre'
                      : 'Rendre visible',
                ),
                // Bouton d'édition
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit,
                    color: PartnerAdminStyles.accentColor,
                  ),
                  tooltip: 'Modifier',
                ),
                // Bouton de suppression
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher le texte du nombre d'invités
  String _getInvitesText() {
    if (offer.minInvites != null && offer.maxInvites != null) {
      return 'Pour ${offer.minInvites} à ${offer.maxInvites} invités';
    } else if (offer.minInvites != null) {
      return 'Min. ${offer.minInvites} invités';
    } else if (offer.maxInvites != null) {
      return 'Max. ${offer.maxInvites} invités';
    } else {
      return 'Nombre d\'invités non spécifié';
    }
  }

  // Méthode pour afficher le texte des coefficients
  String _getCoefficientsText() {
    List<String> coefficients = [];

    if (offer.coefWeekend != null) {
      coefficients.add('x${offer.coefWeekend!.toStringAsFixed(2)} le weekend');
    }

    if (offer.coefHauteSaison != null) {
      coefficients
          .add('x${offer.coefHauteSaison!.toStringAsFixed(2)} en haute saison');
    }

    return coefficients.join(', ');
  }
}
