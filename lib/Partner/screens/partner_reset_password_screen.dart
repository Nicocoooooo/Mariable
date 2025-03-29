import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/constants/style_constants.dart';
import '../../utils/logger.dart';

class PartnerResetPasswordScreen extends StatefulWidget {
  const PartnerResetPasswordScreen({super.key});

  @override
  State<PartnerResetPasswordScreen> createState() =>
      _PartnerResetPasswordScreenState();
}

class _PartnerResetPasswordScreenState
    extends State<PartnerResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre adresse email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resetPassword(_emailController.text.trim());
      setState(() {
        _isLoading = false;
        _resetSent = true;
      });
    } catch (e) {
      AppLogger.error('Erreur lors de la réinitialisation du mot de passe', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Réinitialiser le mot de passe',
        backgroundColor: Colors.white,
        foregroundColor: PartnerAdminStyles.accentColor,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Envoi en cours...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Icône
                  const Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: PartnerAdminStyles.accentColor,
                  ),
                  const SizedBox(height: 20),

                  // Titre
                  const Text(
                    'Mot de passe oublié?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: PartnerAdminStyles.accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  const Text(
                    'Entrez votre adresse email pour recevoir un lien de réinitialisation',
                    style: TextStyle(
                      fontSize: 16,
                      color: PartnerAdminStyles.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Message d'erreur
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Message de succès
                  if (_resetSent)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Un email de réinitialisation a été envoyé à ${_emailController.text}',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.',
                            style:
                                TextStyle(color: PartnerAdminStyles.textColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  // Champ email (affiché seulement si le lien n'a pas été envoyé)
                  if (!_resetSent) ...[
                    TextField(
                      controller: _emailController,
                      decoration: PartnerAdminStyles.defaultInputDecoration(
                        'Adresse email',
                        hint: 'exemple@domaine.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 24),

                    // Bouton d'envoi
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: PartnerAdminStyles.primaryButtonStyle,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'ENVOYER LE LIEN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Lien de retour à la connexion
                  TextButton(
                    onPressed: () {
                      context.go('/partner/login');
                    },
                    child: const Text(
                      'Retour à la connexion',
                      style: TextStyle(color: PartnerAdminStyles.accentColor),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
