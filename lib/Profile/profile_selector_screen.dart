import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes_partner_admin.dart';
import '../routes_user.dart';  // Ajout de l'import nécessaire

class ProfileSelectorScreen extends StatelessWidget {
  const ProfileSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la direction artistique
    const Color accentColor = Color(0xFF524B46);
    const Color backgroundColor = Color(0xFFFFF3E4);
    const Color textColor = Color(0xFF2B2B2B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: backgroundColor,
        ),
        child: Column(
          children: [
            // Section du haut (titre et options)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Choisissez votre espace',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Grille de sélection de profil
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Option Marié(e)
                        _buildProfileOption(
                          context: context,
                          title: 'Marié(e)',
                          icon: Icons.favorite,
                          color: Colors.red.shade400,
                          onTap: () {
                            // Page non implémentée pour les mariés
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PlaceholderUserLoginScreen(),
                              ),
                            );
                          },
                        ),
                  // Option Marié(e)
                  _buildProfileOption(
                    context: context,
                    title: 'Marié(e)',
                    icon: Icons.favorite,
                    color: Colors.red.shade400,
                    onTap: () {
                      // Redirection vers l'espace utilisateur via go_router
                      context.go(UserRoutes.userLogin);
                    },
                  ),

                        // Option Prestataire
                        _buildProfileOption(
                          context: context,
                          title: 'Prestataire',
                          icon: Icons.business,
                          color: Colors.blue.shade400,
                          onTap: () {
                            context.go(PartnerAdminRoutes.partnerLogin);
                          },
                        ),

                        // Option Administrateur
                        _buildProfileOption(
                          context: context,
                          title: 'Admin',
                          icon: Icons.admin_panel_settings,
                          color: Colors.purple.shade400,
                          onTap: () {
                            context.go(PartnerAdminRoutes.adminLogin);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Section du bas (bouton retour à l'accueil)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text(
                    'Retourner à l\'accueil',
                    style: TextStyle(
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ],
      ),
    );
  }
}

// Page d'espace utilisateur non implémentée
class PlaceholderUserLoginScreen extends StatelessWidget {
  const PlaceholderUserLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Utilisateur'),
        backgroundColor: const Color(0xFF524B46),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Futur page_login_utilisateur',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF2B2B2B),
          ),
        ),
      ),
    );
  }
}
// Note: La classe PlaceholderUserLoginScreen a été supprimée car elle n'est plus nécessaire
