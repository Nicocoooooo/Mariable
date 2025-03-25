import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PrestaireCard extends StatelessWidget {
  final Map<String, dynamic> prestataire;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDetailPressed;
  final bool isFavorite;

  const PrestaireCard({
    Key? key,
    required this.prestataire,
    this.isSelected = false,
    required this.onTap,
    this.onFavoriteToggle,
    this.onDetailPressed,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer les données du prestataire
    final String nom = prestataire['nom_entreprise'] ?? 'Sans nom';
    final String description = prestataire['description'] ?? '';
    final double? prixBase = prestataire['prix_base'] != null
        ? (prestataire['prix_base'] as num).toDouble()
        : null;
    final double? noteAverage = prestataire['note_moyenne'] != null
        ? (prestataire['note_moyenne'] as num).toDouble()
        : null;
    final String? region = prestataire['region'];
    final String? photoUrl = prestataire['photo_url'] ?? prestataire['image_url'];
    
    // Formateur pour les prix
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    
    // Couleurs du thème
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    // Déterminer le type de prestataire pour l'icône
    IconData typeIcon = Icons.business;
    String typeText = '';
    
    if (prestataire.containsKey('type_lieu')) {
      typeIcon = Icons.villa;
      typeText = 'Lieu - ${prestataire['type_lieu'] ?? ''}';
    } else if (prestataire.containsKey('type_cuisine')) {
      typeIcon = Icons.restaurant;
      typeText = 'Traiteur';
      if (prestataire['type_cuisine'] != null) {
        if (prestataire['type_cuisine'] is List && prestataire['type_cuisine'].isNotEmpty) {
          typeText += ' - ${prestataire['type_cuisine'].join(', ')}';
        } else if (prestataire['type_cuisine'] is String) {
          typeText += ' - ${prestataire['type_cuisine']}';
        }
      }
    } else if (prestataire.containsKey('style')) {
      typeIcon = Icons.camera_alt;
      typeText = 'Photographe';
      if (prestataire['style'] != null) {
        if (prestataire['style'] is List && prestataire['style'].isNotEmpty) {
          typeText += ' - ${prestataire['style'].join(', ')}';
        } else if (prestataire['style'] is String) {
          typeText += ' - ${prestataire['style']}';
        }
      }
    }
    
    return Card(
      elevation: isSelected ? 6 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: accentColor, width: 3)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du prestataire
            Stack(
              children: [
                // Image avec gestion de l'erreur
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: accentColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildPlaceholderWidget(typeIcon),
                        )
                      : _buildPlaceholderWidget(typeIcon),
                ),
                
                // Badge "Sélectionné" si applicable
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Sélectionné',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Bouton favori si disponible
                if (onFavoriteToggle != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: onFavoriteToggle,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                      ),
                    ),
                  ),
                
                // Bouton "+" pour les détails
                if (onDetailPressed != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: onDetailPressed,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        tooltip: 'Voir plus de détails',
                      ),
                    ),
                  ),
                
                // Prix si disponible
                if (prixBase != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        'À partir de ${currencyFormatter.format(prixBase)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Contenu textuel
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (noteAverage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                noteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Type de prestataire
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: beige.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(typeIcon, size: 14, color: accentColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          typeText,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // Région si disponible
                  if (region != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: accentColor),
                          const SizedBox(width: 8),
                          Text(
                            region,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 10),
                  
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Widget de placeholder en cas d'échec de chargement de l'image
  Widget _buildPlaceholderWidget(IconData icon) {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Image non disponible',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Superposition légèrement assombrie pour améliorer la lisibilité
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}