import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/logger.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../services/user_auth_service.dart';

class UserResetPasswordScreen extends StatefulWidget {
  const UserResetPasswordScreen({super.key});

  @override
  State<UserResetPasswordScreen> createState() => _UserResetPasswordScreenState();
}

class _UserResetPasswordScreenState extends State<UserResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = UserAuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  // Méthode pour envoyer le lien de réinitialisation
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _authService.resetPassword(_emailController.text.trim());
      
      setState(() {
        _resetSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
        _isLoading = false;
      });
      AppLogger.error('Erreur lors de la réinitialisation du mot de passe', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la DA
    const Color accentColor = Color(0xFF524B46);
    const Color grisTexte = Color(0xFF2B2B2B);
    const Color beige = Color(0xFFFFF3E4);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mot de passe oublié',
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Envoi en cours...')
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo et titre
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Réinitialiser votre mot de passe',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _resetSent
                                ? 'Un lien de réinitialisation a été envoyé à votre adresse email.'
                                : 'Entrez votre adresse email pour recevoir un lien de réinitialisation de mot de passe.',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: grisTexte,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Message d'erreur
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Message de succès
                    if (_resetSent)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Un email a été envoyé à ${_emailController.text}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Veuillez vérifier votre boîte de réception et suivre les instructions pour réinitialiser votre mot de passe.',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    
                    if (!_resetSent) ...[
                      // Formulaire de réinitialisation
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Adresse email',
                                hintText: 'exemple@email.com',
                                prefixIcon: const Icon(Icons.email, color: accentColor),
                                filled: true,
                                fillColor: beige.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: accentColor),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre adresse email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Veuillez entrer une adresse email valide';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Bouton d'envoi
                            ElevatedButton(
                              onPressed: _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'ENVOYER LE LIEN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Bouton de retour
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: accentColor,
                      ),
                      child: const Text('Retour à la page de connexion'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}