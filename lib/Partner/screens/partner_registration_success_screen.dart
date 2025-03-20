import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/constants/style_constants.dart';

class PartnerRegistrationSuccessScreen extends StatelessWidget {
  const PartnerRegistrationSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône de succès
                const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),

                // Titre
                const Text(
                  'Inscription réussie!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: PartnerAdminStyles.accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message
                const Text(
                  'Votre compte partenaire a été créé avec succès. Un email de confirmation a été envoyé à votre adresse.',
                  style: TextStyle(
                    fontSize: 16,
                    color: PartnerAdminStyles.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Étapes suivantes
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PartnerAdminStyles.beige.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: PartnerAdminStyles.beige,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Prochaines étapes:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: PartnerAdminStyles.accentColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Complétez votre profil avec toutes les informations nécessaires\n'
                        '2. Ajoutez vos offres et services\n'
                        '3. Personnalisez votre page pour attirer plus de clients',
                        style: TextStyle(
                          height: 1.5,
                          color: PartnerAdminStyles.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton de connexion
                ElevatedButton(
                  onPressed: () {
                    context.go('/partner/login');
                  },
                  style: PartnerAdminStyles.primaryButtonStyle,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Text(
                      'SE CONNECTER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
