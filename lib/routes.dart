import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bouquet/bouquetHomeScreen.dart'; // Notez le nom du fichier avec des underscores
// Importez vos écrans ici
// import 'features/auth/presentation/screens/login_screen.dart';
// import 'features/prestataires/presentation/screens/recherche_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      // Route pour l'écran Bouquet
      GoRoute(
        path: '/bouquet',
        builder: (BuildContext context, GoRouterState state) {
          return const BouquetHomeScreen(); // Modifié ici
        },
      ),
      // Ajoutez d'autres routes ici
    ],
    // Redirection basée sur l'état d'authentification
    // redirect: (BuildContext context, GoRouterState state) {
    //   // Logique de redirection
    // },
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond beige au lieu d'une image
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5EFE6), // Beige clair
            ),
          ),
          
          // Contenu principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espace en haut
                const SizedBox(height: 20),
                
                // Titre et sous-titre
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Le grand jour approche...',
                        style: TextStyle(
                          color: Color(0xFF1A4D2E), // Vert foncé
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'À quoi ressemble le mariage de vos rêves?',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Espace avant la barre de recherche
                const SizedBox(height: 20),
                
                // Barre de recherche avec les filtres
                _buildSearchBar(),
                
                // Espace flexible
                Expanded(child: Container()),
                
                // Barre de navigation du bas
                _buildBottomNavigationBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Barre de recherche avec les filtres
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Champ Prestataire
            _buildSearchField(
              icon: Icons.business,
              hintText: 'Prestataire',
            ),
            
            // Ligne de séparation
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            
            // Champ Lieu
            _buildSearchField(
              icon: Icons.location_on,
              hintText: 'Lieu',
            ),
            
            // Ligne de séparation
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            
            // Champ Date (avec double entrée et flèche)
            Row(
              children: [
                Expanded(
                  child: _buildSearchField(
                    icon: Icons.calendar_today,
                    hintText: 'Date',
                    showDivider: false,
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    child: Text(
                      'Date',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Bouton Rechercher
            Container(
              width: double.infinity,
              color: const Color(0xFF1A4D2E), // Vert foncé du thème
              child: TextButton(
                onPressed: () {
                  // Action de recherche
                },
                child: const Text(
                  'Rechercher',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour construire les champs de recherche
  Widget _buildSearchField({
    required IconData icon,
    required String hintText,
    bool showDivider = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            hintText,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour construire la barre de navigation du bas
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.list_alt, 'Prestataire', onTap: () {
            // Navigation vers l'écran des prestataires
          }),
          _buildNavItem(Icons.favorite_border, 'Favoris', onTap: () {
            // Navigation vers les favoris
          }),
          _buildNavItem(Icons.home, 'Home', isSelected: true, onTap: () {
            // Déjà sur la page d'accueil
          }),
          _buildNavItem(Icons.shopping_bag_outlined, 'Bouquet', onTap: () {
            // Navigation vers l'écran Bouquet
            context.go('/bouquet');
          }),
          _buildNavItem(Icons.person_outline, 'Profil', onTap: () {
            // Navigation vers le profil
          }),
        ],
      ),
    );
  }

  // Fonction pour construire un élément de la barre de navigation
  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1A4D2E) : Colors.grey,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1A4D2E) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}