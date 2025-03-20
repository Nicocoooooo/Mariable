import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes_partner_admin.dart';

/// Widget d'overlay pour accéder rapidement à la page de test
class TestButtonOverlay extends StatelessWidget {
  const TestButtonOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120, // Au-dessus de la navigation
      right: 20,
      child: FloatingActionButton(
        onPressed: () {
          context.go('/test'); // Assurez-vous que la route '/test' est définie
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.bug_report, color: Colors.black),
        tooltip: 'Page de test',
      ),
    );
  }
}
