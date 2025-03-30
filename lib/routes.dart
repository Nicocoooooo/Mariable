import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'Bouquet/bouquetHomeScreen.dart';
import 'Home/HomeScreen.dart';
import 'Acceuil/intro.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',  // Démarrer avec l'écran de splash
    routes: [
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      // Route pour l'écran Bouquet
      GoRoute(
        path: '/bouquet',
        builder: (BuildContext context, GoRouterState state) {
          return const BouquetHomeScreen();
        },
      ),
      // Ajoutez d'autres routes ici
    ],
  );
}