import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/logger.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_indicator.dart';
import 'user_register_screen.dart';
import 'user_reset_password_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:mariable/routes_user.dart';
import 'package:go_router/go_router.dart';
import 'user_dashboard_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Vérification si l'utilisateur est déjà connecté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        AppLogger.info('Utilisateur déjà connecté, redirection automatique vers dashboard');
        context.go(UserRoutes.userDashboard);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Méthode pour se connecter avec email et mot de passe
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      AppLogger.info('Tentative de connexion avec email: ${_emailController.text}');
      
      // S'authentifier avec email et mot de passe
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      AppLogger.info('Connexion réussie: ${response.user?.id}');
      
      // Vérifier si le widget est toujours monté
      if (!mounted) return;
      
      // Redirection explicite vers le dashboard si l'utilisateur est connecté
      if (response.user != null) {
        // Navigation directe vers le dashboard
        AppLogger.info('Navigation vers le dashboard utilisateur');
        
        // Important: utiliser un délai pour éviter les conflits de navigation
        await Future.delayed(Duration.zero);
        
        if (mounted) {
          context.go(UserRoutes.userDashboard);
        }
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la tentative de connexion', e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Une erreur est survenue lors de la connexion. Veuillez réessayer.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Méthode pour se connecter avec Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      AppLogger.info('Tentative de connexion avec Google');
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.mariable://login-callback/',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la connexion avec Google';
          _isLoading = false;
        });
      }
      AppLogger.error('Erreur de connexion avec Google', e);
    }
  }
  
  // Méthode pour se connecter avec Apple
  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      AppLogger.info('Tentative de connexion avec Apple');
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.mariable://login-callback/',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la connexion avec Apple';
          _isLoading = false;
        });
      }
      AppLogger.error('Erreur de connexion avec Apple', e);
    }
  }

  // Méthode pour naviguer vers l'écran d'inscription
  void _navigateToRegister() {
    context.push(UserRoutes.userRegister);
  }

  // Méthode pour naviguer vers l'écran de réinitialisation de mot de passe
  void _navigateToResetPassword() {
    context.push(UserRoutes.userResetPassword);
  }
  
  // Méthode pour revenir à l'écran de sélection de profil
  void _navigateBack() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la DA
    const Color accentColor = Color(0xFF524B46);
    const Color grisTexte = Color(0xFF2B2B2B);
    const Color beige = Color(0xFFFFF3E4);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Connexion',
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Connexion en cours...')
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
                          const flutter.SizedBox(height: 20),
                          Text(
                            'Mariable',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          const flutter.SizedBox(height: 8),
                          Text(
                            'Votre espace mariage',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: grisTexte,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const flutter.SizedBox(height: 40),
                    
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
                    
                    // Formulaire de connexion
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          flutter.TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Adresse email',
                              hintText: 'exemple@email.com',
                              prefixIcon: const Icon(Icons.email, color: accentColor),
                              filled: true,
                              fillColor: beige.withOpacity(0.3),
                              border: flutter.OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: flutter.OutlineInputBorder(
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
                          
                          const flutter.SizedBox(height: 16),
                          
                          // Mot de passe
                          flutter.TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock, color: accentColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: beige.withOpacity(0.3),
                              border: flutter.OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: flutter.OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: accentColor),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              return null;
                            },
                          ),
                          
                          // Bouton Mot de passe oublié
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _navigateToResetPassword,
                              style: TextButton.styleFrom(
                                foregroundColor: accentColor,
                              ),
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ),
                          
                          const flutter.SizedBox(height: 24),
                          
                          // Bouton de connexion
                          ElevatedButton(
                            onPressed: _signInWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'SE CONNECTER',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const flutter.SizedBox(height: 32),
                    
                    // Séparateur "OU"
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              color: grisTexte.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    
                    const flutter.SizedBox(height: 32),
                    
                    // Boutons de connexion sociale améliorés
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: OutlinedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const FaIcon(FontAwesomeIcons.google, size: 20, color: Color(0xFF524B46)),
                        label: const Text(
                          'Continuer avec Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF524B46),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const flutter.SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: OutlinedButton.icon(
                        onPressed: _signInWithApple,
                        icon: const FaIcon(FontAwesomeIcons.apple, size: 22, color: Colors.white),
                        label: const Text(
                          'Continuer avec Apple',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    
                    const flutter.SizedBox(height: 40),
                    
                    // Bouton d'inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pas encore de compte ?'),
                        TextButton(
                          onPressed: _navigateToRegister,
                          style: TextButton.styleFrom(
                            foregroundColor: accentColor,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('S\'inscrire'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}