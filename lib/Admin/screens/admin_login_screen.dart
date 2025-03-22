import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/services/auth_service.dart';
import '../../routes_partner_admin.dart';
import '../../shared/constants/style_constants.dart';
import '../../Admin/services/admin_service.dart';
import '../../utils/logger.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ou titre
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: PartnerAdminStyles.accentColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Administration Mariable',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: PartnerAdminStyles.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connectez-vous à votre espace administrateur',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PartnerAdminStyles.textColor.withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Affichage d'erreur éventuelle
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PartnerAdminStyles.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: PartnerAdminStyles.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 24),

                  // Formulaire de connexion
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Champ email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'admin@mariable.fr',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Veuillez saisir un email valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Champ mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Bouton de connexion
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PartnerAdminStyles.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Se connecter'),
                        ),
                        const SizedBox(height: 16),

                        // Lien de retour à l'accueil
                        TextButton(
                          onPressed: () {
                            context.go('/');
                          },
                          child: const Text('Retourner à l\'accueil'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final authResponse = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (authResponse.user != null) {
        final isAdmin = await authService.isAdmin();

        if (isAdmin) {
          // Mettre à jour la date de dernière connexion
          final adminService = AdminService();
          await adminService.updateAdminLastLogin(authResponse.user!.id);
          // ignore: use_build_context_synchronously
          context.go(PartnerAdminRoutes.adminDashboard);
        } else {
          // L'utilisateur n'est pas un admin
          await authService.signOut();
          setState(() {
            _errorMessage = 'Vous n\'avez pas les droits d\'administration';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la connexion';
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      AppLogger.error('Erreur d\'authentification', e);
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors de la connexion', e);
      setState(() {
        _errorMessage = 'Une erreur s\'est produite. Veuillez réessayer.';
        _isLoading = false;
      });
    }
  }
}
