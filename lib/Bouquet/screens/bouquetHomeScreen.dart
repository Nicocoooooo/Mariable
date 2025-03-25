import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bouquet_creation_screen.dart';

class BouquetHomeScreen extends StatelessWidget {
  const BouquetHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Couleurs de la charte graphique
    final Color grisTexte = const Color(0xFF2B2B2B);
    final Color accentColor = const Color(0xFF524B46);
    final Color beige = const Color(0xFFFFF3E4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bouquets',
          style: GoogleFonts.playfairDisplay(
            textStyle: TextStyle(
              color: grisTexte,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: grisTexte),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre explicatif
            Text(
              'Créez votre bouquet de prestataires',
              style: GoogleFonts.playfairDisplay(
                textStyle: TextStyle(
                  color: grisTexte,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Regroupez vos prestataires préférés et économisez sur votre mariage',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: grisTexte.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 50),
            
            // Option 1: Créer un bouquet
            _buildButton(
              context: context,
              icon: Icons.add_circle_outline,
              label: 'Créer un bouquet',
              color: accentColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BouquetCreationScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Option 2: Voir mes bouquets
            /*_buildButton(
              context: context,
              icon: Icons.collections_bookmark_outlined,
              label: 'Voir mes bouquets',
              color: accentColor,
              isOutlined: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BouquetScreen(initialTab: 0),
                  ),
                );
              },
            ),*/
            
            const SizedBox(height: 40),
            
            // Option 3: Démarrer l'expérience
            TextButton(
              onPressed: () {
                // Rediriger vers une page d'introduction ou de tutoriel
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tutoriel ou introduction à ajouter'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Démarrer l\'expérience',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : color,
        foregroundColor: isOutlined ? color : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: isOutlined ? 0 : 2,
        side: isOutlined ? BorderSide(color: color, width: 2) : null,
      ),
    );
  }
}