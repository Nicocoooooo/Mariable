import 'package:flutter/material.dart' as flutter;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/logger.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_indicator.dart';
import 'user_registration_success_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserRegisterScreen extends flutter.StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  flutter.State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends flutter.State<UserRegisterScreen> {
  final _formKey = flutter.GlobalKey<flutter.FormState>();
  final _nameController = flutter.TextEditingController();
  final _emailController = flutter.TextEditingController();
  final _passwordController = flutter.TextEditingController();
  final _confirmPasswordController = flutter.TextEditingController();
  final _phoneController = flutter.TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  
  DateTime? _weddingDate;
  final flutter.TextEditingController _weddingDateController = flutter.TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _weddingDateController.dispose();
    super.dispose();
  }
  
  // Méthode pour s'inscrire avec email et mot de passe
  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 1. Créer le compte utilisateur avec Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (response.user != null) {
        // 2. Ajouter les informations de l'utilisateur dans la table 'users'

await Supabase.instance.client.from('profiles').insert({
  'id': response.user!.id,  // ID de l'utilisateur authentifié
  'email': _emailController.text.trim(),
  'prenom': _nameController.text.split(' ').first,
  'nom': _nameController.text.split(' ').length > 1 ? 
         _nameController.text.split(' ').sublist(1).join(' ') : '',
  // Laissez les champs du conjoint vides pour l'instant
  'prenom_conjoint': null,
  'nom_conjoint': null,
  'email_conjoint': null,
  'telephone_conjoint': _phoneController.text.trim(), // Utilisez cette ligne si le téléphone saisi est celui du conjoint
  // Sinon, ajoutez une colonne 'telephone' à votre table pour le téléphone principal
  'status': 'client',  
  'created_at': DateTime.now().toIso8601String(),
  'updated_at': DateTime.now().toIso8601String(),
});

        // 3. Rediriger vers la page de succès
        if (mounted) {
          flutter.Navigator.of(context).pushReplacement(flutter.MaterialPageRoute(
            builder: (context) => const UserRegistrationSuccessScreen(),
          ));
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      AppLogger.error('Erreur d\'inscription: ${e.message}', e);
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue lors de l\'inscription. Veuillez réessayer.';
      });
      AppLogger.error('Erreur d\'inscription', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Méthode pour s'inscrire avec Google
  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
       OAuthProvider.google,
        redirectTo: 'io.supabase.mariable://register-callback/',
      );
      // Note: La redirection se fera automatiquement grâce à la configuration de DeepLink
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de l\'inscription avec Google';
          _isLoading = false;
        });
      }
      AppLogger.error('Erreur d\'inscription avec Google', e);
    }
  }
  
  // Méthode pour s'inscrire avec Apple
  Future<void> _signUpWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.mariable://register-callback/',
      );
      // Note: La redirection se fera automatiquement grâce à la configuration de DeepLink
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de l\'inscription avec Apple';
          _isLoading = false;
        });
      }
      AppLogger.error('Erreur d\'inscription avec Apple', e);
    }
  }
  
  // Méthode pour sélectionner la date du mariage
  Future<void> _selectWeddingDate(flutter.BuildContext context) async {
    final DateTime? picked = await flutter.showDatePicker(
      context: context,
      initialDate: _weddingDate ?? DateTime.now().add(const Duration(days: 180)), // Par défaut, + 6 mois
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)), // 3 ans max
      builder: (context, child) {
        return flutter.Theme(
          data: flutter.Theme.of(context).copyWith(
            colorScheme: const flutter.ColorScheme.light(
              primary: flutter.Color(0xFF524B46),
              onPrimary: flutter.Colors.white,
              surface: flutter.Colors.white,
              onSurface: flutter.Color(0xFF2B2B2B),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _weddingDate = picked;
        _weddingDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    // Couleurs selon la DA
    const flutter.Color accentColor = flutter.Color(0xFF524B46);
    const flutter.Color grisTexte = flutter.Color(0xFF2B2B2B);
    const flutter.Color beige = flutter.Color(0xFFFFF3E4);
    
    return flutter.Scaffold(
      appBar: const CustomAppBar(
        title: 'Inscription',
        backgroundColor: accentColor,
        foregroundColor: flutter.Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Inscription en cours...')
          : flutter.SingleChildScrollView(
              child: flutter.Padding(
                padding: const flutter.EdgeInsets.all(24.0),
                child: flutter.Column(
                  crossAxisAlignment: flutter.CrossAxisAlignment.stretch,
                  children: [
                    // Logo et titre
                    flutter.Center(
                      child: flutter.Column(
                        children: [
                          const flutter.SizedBox(height: 10.0),
                          flutter.Text(
                            'Créer un compte',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: flutter.FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          const flutter.SizedBox(height: 8.0),
                          flutter.Text(
                            'Commencez à organiser votre mariage',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: grisTexte,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const flutter.SizedBox(height: 30.0),
                    
                    // Message d'erreur
                    if (_errorMessage != null)
                      flutter.Container(
                        padding: const flutter.EdgeInsets.all(12.0),
                        margin: const flutter.EdgeInsets.only(bottom: 20.0),
                        decoration: flutter.BoxDecoration(
                          color: flutter.Colors.red.withOpacity(0.1),
                          borderRadius: flutter.BorderRadius.circular(8.0),
                          border: flutter.Border.all(color: flutter.Colors.red.withOpacity(0.3)),
                        ),
                        child: flutter.Text(
                          _errorMessage!,
                          style: const flutter.TextStyle(
                            color: flutter.Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: flutter.TextAlign.center,
                        ),
                      ),
                    
                    // Formulaire d'inscription
                    flutter.Form(
                      key: _formKey,
                      child: flutter.Column(
                        crossAxisAlignment: flutter.CrossAxisAlignment.stretch,
                        children: [
                          // Nom complet
                          flutter.TextFormField(
                            controller: _nameController,
                            decoration: flutter.InputDecoration(
                              labelText: 'Nom complet',
                              hintText: 'Prénom et Nom',
                              prefixIcon: const flutter.Icon(flutter.Icons.person, color: accentColor),
                              filled: true,
                              fillColor: beige.withOpacity(0.3),
                              border: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: flutter.BorderSide.none,
                              ),
                              focusedBorder: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: const flutter.BorderSide(color: accentColor),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nom complet';
                              }
                              return null;
                            },
                          ),
                          
                          const flutter.SizedBox(height: 16.0),
                          
                          // Email
                          flutter.TextFormField(
                            controller: _emailController,
                            decoration: flutter.InputDecoration(
                              labelText: 'Adresse email',
                              hintText: 'exemple@email.com',
                              prefixIcon: const flutter.Icon(flutter.Icons.email, color: accentColor),
                              filled: true,
                              fillColor: beige.withOpacity(0.3),
                              border: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: flutter.BorderSide.none,
                              ),
                              focusedBorder: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: const flutter.BorderSide(color: accentColor),
                              ),
                            ),
                            keyboardType: flutter.TextInputType.emailAddress,
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
                          
                          const flutter.SizedBox(height: 16.0),
                          
                          // Téléphone
                          flutter.TextFormField(
                            controller: _phoneController,
                            decoration: flutter.InputDecoration(
                              labelText: 'Téléphone',
                              hintText: 'Ex: 06 12 34 56 78',
                              prefixIcon: const flutter.Icon(flutter.Icons.phone, color: accentColor),
                              filled: true,
                              fillColor: beige.withOpacity(0.3),
                              border: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: flutter.BorderSide.none,
                              ),
                              focusedBorder: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: const flutter.BorderSide(color: accentColor),
                              ),
                            ),
                            keyboardType: flutter.TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre numéro de téléphone';
                              }
                              return null;
                            },
                          ),
                          
                          const flutter.SizedBox(height: 16.0),
                          
                          // Date de mariage
                          flutter.GestureDetector(
                            onTap: () => _selectWeddingDate(context),
                            child: flutter.AbsorbPointer(
                              child: flutter.TextFormField(
                                controller: _weddingDateController,
                                decoration: flutter.InputDecoration(
                                  labelText: 'Date de mariage prévue (optionnel)',
                                  hintText: 'Sélectionner une date',
                                  prefixIcon: const flutter.Icon(flutter.Icons.calendar_today, color: accentColor),
                                  filled: true,
                                  fillColor: beige.withOpacity(0.3),
                                  border: flutter.OutlineInputBorder(
                                    borderRadius: flutter.BorderRadius.circular(8.0),
                                    borderSide: flutter.BorderSide.none,
                                  ),
                                  focusedBorder: flutter.OutlineInputBorder(
                                    borderRadius: flutter.BorderRadius.circular(8.0),
                                    borderSide: const flutter.BorderSide(color: accentColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const flutter.SizedBox(height: 16.0),
                          
                          // Mot de passe
                          flutter.TextFormField(
                            controller: _passwordController,
                            decoration: flutter.InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const flutter.Icon(flutter.Icons.lock, color: accentColor),
                              suffixIcon: flutter.IconButton(
                                icon: flutter.Icon(
                                  _obscurePassword ? flutter.Icons.visibility : flutter.Icons.visibility_off,
                                  color: flutter.Colors.grey,
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
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: flutter.BorderSide.none,
                              ),
                              focusedBorder: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: const flutter.BorderSide(color: accentColor),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          
                          const flutter.SizedBox(height: 16.0),
                          
                          // Confirmation du mot de passe
                          flutter.TextFormField(
                            controller: _confirmPasswordController,
                            decoration: flutter.InputDecoration(
                              labelText: 'Confirmer le mot de passe',
                              prefixIcon: const flutter.Icon(flutter.Icons.lock_outline, color: accentColor),
                              suffixIcon: flutter.IconButton(
                                icon: flutter.Icon(
                                  _obscureConfirmPassword ? flutter.Icons.visibility : flutter.Icons.visibility_off,
                                  color: flutter.Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: beige.withOpacity(0.3),
                              border: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: flutter.BorderSide.none,
                              ),
                              focusedBorder: flutter.OutlineInputBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                                borderSide: const flutter.BorderSide(color: accentColor),
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez confirmer votre mot de passe';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                          
                          const flutter.SizedBox(height: 24.0),
                          
                          // Conditions d'utilisation
                          flutter.Row(
                            children: [
                              flutter.Expanded(
                                child: flutter.Text(
                                  'En vous inscrivant, vous acceptez nos Conditions Générales d\'Utilisation et notre Politique de Confidentialité.',
                                  style: flutter.TextStyle(
                                    fontSize: 12,
                                    color: grisTexte.withOpacity(0.7),
                                  ),
                                  textAlign: flutter.TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          
                          const flutter.SizedBox(height: 24.0),
                          
                          // Bouton d'inscription
                          flutter.ElevatedButton(
                            onPressed: _signUpWithEmail,
                            style: flutter.ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: flutter.Colors.white,
                              padding: const flutter.EdgeInsets.symmetric(vertical: 16.0),
                              shape: flutter.RoundedRectangleBorder(
                                borderRadius: flutter.BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const flutter.Text(
                              'S\'INSCRIRE',
                              style: flutter.TextStyle(
                                fontWeight: flutter.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const flutter.SizedBox(height: 32.0),
                    
                    // Séparateur "OU"
                   flutter.Row(
  children: [
    flutter.Expanded(
      child: flutter.Container(
        height: 1,
        color: flutter.Colors.grey.withOpacity(0.3),
      ),
    ),
    flutter.Padding(
      padding: const flutter.EdgeInsets.symmetric(horizontal: 16.0),
      child: flutter.Text(
        'OU',
        style: flutter.TextStyle(
          color: grisTexte.withOpacity(0.6),
          fontWeight: flutter.FontWeight.w500,
        ),
      ),
    ),
    flutter.Expanded(
      child: flutter.Container(
        height: 1,
        color: flutter.Colors.grey.withOpacity(0.3),
      ),
    ),
  ],
),

const flutter.SizedBox(height: 32.0),

// Nouveaux boutons de connexion sociale améliorés
flutter.Container(
  width: double.infinity,
  margin: const flutter.EdgeInsets.symmetric(vertical: 8),
  child: flutter.OutlinedButton.icon(
    onPressed: _signUpWithGoogle,
    icon: const FaIcon(FontAwesomeIcons.google, size: 20, color: flutter.Color(0xFF524B46)),
    label: const flutter.Text(
      'Continuer avec Google',
      style: flutter.TextStyle(
        fontSize: 16,
        fontWeight: flutter.FontWeight.w500,
      ),
    ),
    style: flutter.OutlinedButton.styleFrom(
      foregroundColor: const flutter.Color(0xFF524B46),
      backgroundColor: flutter.Colors.white,
      side: flutter.BorderSide(color: flutter.Colors.grey.shade300),
      padding: const flutter.EdgeInsets.symmetric(vertical: 16),
      shape: flutter.RoundedRectangleBorder(
        borderRadius: flutter.BorderRadius.circular(8),
      ),
    ),
  ),
),

const flutter.SizedBox(height: 16),

flutter.Container(
  width: double.infinity,
  margin: const flutter.EdgeInsets.symmetric(vertical: 8),
  child: flutter.OutlinedButton.icon(
    onPressed: _signUpWithApple,
    icon: const FaIcon(FontAwesomeIcons.apple, size: 22, color: flutter.Colors.white),
    label: const flutter.Text(
      'Continuer avec Apple',
      style: flutter.TextStyle(
        fontSize: 16,
        fontWeight: flutter.FontWeight.w500,
        color: flutter.Colors.white,
      ),
    ),
    style: flutter.OutlinedButton.styleFrom(
      foregroundColor: flutter.Colors.white,
      backgroundColor: flutter.Colors.black,
      side: flutter.BorderSide.none,
      padding: const flutter.EdgeInsets.symmetric(vertical: 16),
      shape: flutter.RoundedRectangleBorder(
        borderRadius: flutter.BorderRadius.circular(8),
      ),
    ),
  ),
),
                    
                    const flutter.SizedBox(height: 40.0),
                    
                    // Lien vers la page de connexion
                    flutter.Row(
                      mainAxisAlignment: flutter.MainAxisAlignment.center,
                      children: [
                        const flutter.Text('Vous avez déjà un compte ?'),
                        flutter.TextButton(
                          onPressed: () {
                            flutter.Navigator.pop(context);
                          },
                          style: flutter.TextButton.styleFrom(
                            foregroundColor: accentColor,
                            textStyle: const flutter.TextStyle(
                              fontWeight: flutter.FontWeight.bold,
                            ),
                          ),
                          child: const flutter.Text('Se connecter'),
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