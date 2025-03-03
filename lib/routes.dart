import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importez vos écrans ici
// import 'features/auth/presentation/screens/login_screen.dart';
// import 'features/prestataires/presentation/screens/recherche_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const Center(child: Text('Page d\'accueil - à implémenter'));
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
