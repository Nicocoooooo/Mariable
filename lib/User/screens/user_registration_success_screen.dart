import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';
import 'user_login_screen.dart';
import 'user_dashboard_screen.dart';

class UserRegistrationSuccessScreen extends StatelessWidget {
  const UserRegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la DA
    const Color accentColor = Color(0xFF524B46);
    const Color grisTexte = Color(0xFF2B2B2B);
    const Color beige = Color(0xFFFFF3E4);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Inscription réussie',
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: beige.withOpacity(0.3),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icône de succès
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Titre
                  Text(
                    'Félicitations !',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Message
                  Text(
                    'Votre compte a été créé avec succès.',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: grisTexte,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Un email de confirmation a été envoyé à votre adresse email. Veuillez cliquer sur le lien de vérification pour activer votre compte.',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: grisTexte,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline, color: accentColor, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Vérifiez également votre dossier spam si vous ne recevez pas l\'email.',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: grisTexte.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Bouton tableau de bord
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const UserDashboardScreen(),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'COMMENCER MAINTENANT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Retour à la connexion
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const UserLoginScreen(),
                          ));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentColor,
                          side: const BorderSide(color: accentColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'RETOUR À LA CONNEXION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}