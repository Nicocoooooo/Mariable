import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes_partner_admin.dart';

/// Widget d'overlay pour accéder rapidement à la page de test
class TestButtonOverlay extends StatelessWidget {
  const TestButtonOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120, // Au-dessus de la navigation
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              context.go('/test'); // Accès à la page de test
            },
            backgroundColor: Colors.amber,
            child: const Icon(Icons.bug_report, color: Colors.black),
            tooltip: 'Page de test',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              context.go('/partner/login'); // Accès à l'espace partenaire
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.business, color: Colors.white),
            tooltip: 'Espace partenaire',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              context.go(PartnerAdminRoutes
                  .adminLogin); // Accès à l'espace administrateur
            },
            backgroundColor: Colors.purple,
            child: const Icon(Icons.admin_panel_settings, color: Colors.white),
            tooltip: 'Espace administrateur',
          ),
        ],
      ),
    );
  }
}
