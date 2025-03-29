import 'package:flutter/material.dart';
import '../Filtre/data/models/avis_model.dart';
import 'package:intl/intl.dart';

class AvisCard extends StatelessWidget {
  final AvisModel avis;

  const AvisCard({
    super.key,
    required this.avis,
  });

  @override
  Widget build(BuildContext context) {
    // Récupérer le nom de l'auteur depuis le profil ou utiliser "Anonyme"
    String authorName = "Anonyme";
    if (avis.profile != null) {
      final String? prenom = avis.profile!['prenom'];
      final String? nom = avis.profile!['nom'];
      
      if (prenom != null && nom != null) {
        authorName = "$prenom & $nom";
      } else if (prenom != null) {
        authorName = prenom;
      } else if (nom != null) {
        authorName = nom;
      }
    }
    
    // Formatter la date
    final dateFormat = DateFormat('MMMM yyyy', 'fr_FR');
    final String formattedDate = dateFormat.format(avis.createdAt);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Affichage des étoiles
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                Icon(
                  i <= avis.note ? Icons.star : 
                  (i - 0.5 <= avis.note ? Icons.star_half : Icons.star_border),
                  color: Colors.amber,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            avis.commentaire,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}