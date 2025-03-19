import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PrestaireCard extends StatelessWidget {
  final Map<String, dynamic> prestataire;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const PrestaireCard({
    Key? key,
    required this.prestataire,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  }) : super(key: key);

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
                borderRadius: BorderRadius.circular(12), // Tous les côtés sont arrondis
                child: SizedBox(
                  width: double.infinity, // Largeur complète
                  height: 200, // Hauteur fixe, ajustez selon vos préférences
                  child: photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: beige.withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print("Error loading image: $url, error: $error");
                            return Container(
                              color: beige.withOpacity(0.3),
                              child: Icon(
                                Icons.business,
                                size: 40,
                                color: accentColor.withOpacity(0.6),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: beige.withOpacity(0.3),
                          child: Icon(
                            Icons.business,
                            size: 40,
                            color: accentColor.withOpacity(0.6),
                          ),
                        ),
                ),
              ),
                
                // Bouton favori
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : grisTexte.withOpacity(0.7),
                          size: 18,
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
                          color: grisTexte.withOpacity(0.7),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          region,
                          style: TextStyle(
                            fontSize: 14,
                            color: grisTexte.withOpacity(0.7),
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
                          color: grisTexte.withOpacity(0.7),
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
                        color: grisTexte.withOpacity(0.8),
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
}