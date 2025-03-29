import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PrestaireCard extends StatelessWidget {
  final Map<String, dynamic> prestataire;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;
  final bool isProcessing; // Nouvel attribut pour l'état de traitement des favoris

  const PrestaireCard({
    super.key,
    required this.prestataire,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
    this.isProcessing = false, // Valeur par défaut
  });

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la palette définie
    final Color grisTexte = const Color(0xFF2B2B2B);
    final Color accentColor = const Color(0xFF524B46);
    final Color beige = const Color(0xFFFFF3E4);
    
    // Adapter les données du prestataire
    final String nom = prestataire['nom_entreprise'] ?? 'Sans nom';
    final String description = prestataire['description'] ?? 'Aucune description disponible';
    final String region = prestataire['region'] ?? 'Non spécifié';
    final double? rating = prestataire['note_moyenne'] != null 
        ? (prestataire['note_moyenne'] is double 
            ? prestataire['note_moyenne'] 
            : double.tryParse(prestataire['note_moyenne'].toString()))
        : null;
    final double? prix = prestataire['prix_base'] != null 
        ? (prestataire['prix_base'] is double 
            ? prestataire['prix_base'] 
            : double.tryParse(prestataire['prix_base'].toString()))
        : null;
    final String? photoUrl = prestataire['photo_url'];
    
    // Capacité (pour les lieux)
    final String? capacite = prestataire['capacite_max'] != null 
        ? '${prestataire['capacite_max']} invités' 
        : null;
    
    // Caractéristiques/équipements (peut être personnalisé selon le type de prestataire)
    List<String> caracteristiques = [];
    if (prestataire['hebergement'] == true) caracteristiques.add('Hébergement');
    if (prestataire['espace_exterieur'] == true) caracteristiques.add('Espace extérieur');
    if (prestataire['parking'] == true) caracteristiques.add('Parking');
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec bouton favori
            Stack(
              children: [
                // Image principale
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: _buildPrestaireImage(prestataire),
                  ),
                ),
                
                // Bouton favori - MODIFICATIONS ICI
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isProcessing ? null : onFavoriteToggle,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 40, // Légèrement plus grand
                        height: 40, // Légèrement plus grand
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isProcessing 
                            ? const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A4D2E)),
                                ),
                              )
                            : Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : grisTexte.withAlpha(179),
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Informations du prestataire
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 2, right: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Première ligne: Nom et notation
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2B2B2B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2B2B2B),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  // Deuxième ligne: Lieu
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: grisTexte.withAlpha(179),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          region,
                          style: TextStyle(
                            fontSize: 14,
                            color: grisTexte.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Troisième ligne: Caractéristiques
                  if (caracteristiques.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        caracteristiques.join(' • '),
                        style: TextStyle(
                          fontSize: 14,
                          color: grisTexte.withAlpha(179),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Quatrième ligne: Description
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: grisTexte.withAlpha(204),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Dernière ligne: Prix
                  if (prix != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: grisTexte,
                          ),
                          children: [
                            const TextSpan(
                              text: 'À partir de ',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: '${prix.toInt()} €',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Et ajoutez cette fonction dans la classe PrestaireCard
Widget _buildPrestaireImage(Map<String, dynamic> prestataire) {
  final Color beige = const Color(0xFFFFF3E4);
  final Color accentColor = const Color(0xFF524B46);
  
  // Déterminer le type de prestataire
  final int? prestaTypeId = prestataire['presta_type_id'];
  String? imageUrl;
  
  // Si c'est un lieu (type_id = 1), chercher l'image dans la table lieux
  if (prestaTypeId == 1 && prestataire.containsKey('lieux')) {
    var lieuxData = prestataire['lieux'];
    if (lieuxData is List && lieuxData.isNotEmpty) {
      imageUrl = lieuxData[0]['image_url'];
    } else if (lieuxData is Map<String, dynamic>) {
      imageUrl = lieuxData['image_url'];
    }
  } else {
    // Pour les autres types (traiteur, photographe), utiliser l'image de presta
    imageUrl = prestataire['image_url'] ?? prestataire['photo_url'];
  }
  
  return imageUrl != null
    ? CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: beige.withAlpha(77),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          return Container(
            color: beige.withAlpha(77),
            child: Icon(
              Icons.business,
              size: 40,
              color: accentColor.withAlpha(153),
            ),
          );
        },
      )
    : Container(
        color: beige.withAlpha(77),
        child: Icon(
          Icons.business,
          size: 40,
          color: accentColor.withAlpha(153),
        ),
      );
}
}