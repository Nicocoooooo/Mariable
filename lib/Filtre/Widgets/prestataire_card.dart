import 'package:flutter/material.dart';

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
    // Utiliser les couleurs du thème de l'application
    final Color accentColor = Theme.of(context).colorScheme.primary; // #524B46
    final Color grisTexte = Theme.of(context).colorScheme.onSurface; // #2B2B2B
    final Color beige = Theme.of(context).colorScheme.secondary; // #FFF3E4

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    prestataire['photo_url'] != null
                        ? Image.network(
                            prestataire['photo_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: beige.withOpacity(0.3),
                                child: Icon(
                                  Icons.business,
                                  size: 48,
                                  color: accentColor.withOpacity(0.5),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: beige.withOpacity(0.3),
                            child: Icon(
                              Icons.business,
                              size: 48,
                              color: accentColor.withOpacity(0.5),
                            ),
                          ),
                    // Bouton favori
                    if (onFavoriteToggle != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white.withOpacity(0.8),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onFavoriteToggle,
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : grisTexte.withOpacity(0.6),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Contenu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            prestataire['nom_entreprise'] ?? 'Sans nom',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: grisTexte,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (prestataire['note_moyenne'] != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${prestataire['note_moyenne'].toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: grisTexte,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Région
                    if (prestataire['region'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: grisTexte.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            prestataire['region'],
                            style: TextStyle(
                              fontSize: 14,
                              color: grisTexte.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    if (prestataire['description'] != null)
                      Text(
                        prestataire['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: grisTexte.withOpacity(0.7),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Indicateur de prix
                    if (prestataire['prix_base'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.euro,
                            size: 16,
                            color: grisTexte.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'À partir de ${prestataire['prix_base'].toStringAsFixed(0)} €',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: grisTexte.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Bouton
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Voir les détails',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}