import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/constants/style_constants.dart';
import '../../utils/logger.dart';
import '../../routes_partner_admin.dart';

class PartnerLoginScreen extends StatefulWidget {
  const PartnerLoginScreen({super.key});

  @override
  State<PartnerLoginScreen> createState() => _PartnerLoginScreenState();
}

class _PartnerLoginScreenState extends State<PartnerLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // Pour afficher/masquer le mot de passe

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Vérifier que les champs sont remplis
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Tentative de connexion
      final response = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Vérifier si l'utilisateur est un partenaire
      final isPartner = await _authService.isPartner();

      if (isPartner) {
        // Rediriger vers le tableau de bord
        if (mounted) {
          context.go('/partner/dashboard');
        }
      } else {
        // Déconnecter l'utilisateur s'il n'est pas un partenaire
        await _authService.signOut();
        setState(() {
          _isLoading = false;
          _errorMessage = 'Accès réservé aux partenaires';
        });
      }
    } catch (e) {
      AppLogger.error('Erreur de connexion', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Email ou mot de passe incorrect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion Partenaire'),
        backgroundColor: Colors.white,
        foregroundColor: PartnerAdminStyles.accentColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(PartnerAdminRoutes.profileSelector),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Connexion en cours...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ou image
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(30), // Rayon des bords arrondis
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 30.0),
                      width: double
                          .infinity, // Pour prendre toute la largeur disponible
                      height: 220, // Hauteur légèrement ajustée
                      child: Image.network(
                        'https://wrdychfyhctekddzysen.supabase.co/storage/v1/object/public/typeimg//orangerie.jpeg',
                        fit: BoxFit
                            .cover, // Cover au lieu de contain pour remplir tout l'espace
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Titre et description
                  const Text(
                    'Bienvenue sur votre espace partenaire',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: PartnerAdminStyles.accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Connectez-vous pour gérer vos offres et réservations',
                    style: TextStyle(
                      fontSize: 16,
                      color: PartnerAdminStyles.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

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

                  // Champ email
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
                  const SizedBox(height: 16),

                  // Champ mot de passe
                  TextField(
                    controller: _passwordController,
                    decoration: PartnerAdminStyles.defaultInputDecoration(
                      'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),

                  // Lien mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/partner/reset-password');
                      },
                      child: const Text(
                        'Mot de passe oublié?',
                        style: TextStyle(color: PartnerAdminStyles.accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Bouton de connexion
                  ElevatedButton(
                    onPressed: _login,
                    style: PartnerAdminStyles.primaryButtonStyle,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'SE CONNECTER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Lien vers inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore partenaire?'),
                      TextButton(
                        onPressed: () {
                          context.push('/partner/register');
                        },
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: PartnerAdminStyles.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Ajoutez ce bouton de retour à l'accueil
                  TextButton(
                    onPressed: () {
                      context.go('/');
                    },
                    child: const Text(
                      'Retourner à l\'accueil',
                      style: TextStyle(
                        color: PartnerAdminStyles.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}