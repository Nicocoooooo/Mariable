import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/constants/style_constants.dart';
import '../../utils/logger.dart';

class PartnerRegisterScreen extends StatefulWidget {
  const PartnerRegisterScreen({super.key});

  @override
  State<PartnerRegisterScreen> createState() => _PartnerRegisterScreenState();
}

class _PartnerRegisterScreenState extends State<PartnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier l'acceptation des conditions
    if (!_acceptTerms) {
      setState(() {
        _errorMessage = 'Vous devez accepter les conditions générales';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Enregistrement du partenaire
      await _authService.registerPartner(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );

      // Redirection vers une page de confirmation
      if (mounted) {
        context.go('/partner/registration-success');
      }
    } catch (e) {
      AppLogger.error('Erreur d\'inscription', e);

      String errorMsg = 'Une erreur est survenue lors de l\'inscription';
      if (e.toString().contains('email already exists')) {
        errorMsg = 'Cette adresse email est déjà utilisée';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Inscription Partenaire',
        backgroundColor: Colors.white,
        foregroundColor: PartnerAdminStyles.accentColor,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Inscription en cours...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Titre et description
                    const Text(
                      'Devenir partenaire Mariable',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: PartnerAdminStyles.accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Créez votre compte partenaire pour promouvoir vos services auprès de milliers de clients',
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

                    // Nom de l'entreprise
                    TextFormField(
                      controller: _nameController,
                      decoration: PartnerAdminStyles.defaultInputDecoration(
                        'Nom de l\'entreprise',
                        prefixIcon: const Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom de votre entreprise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Téléphone
                    TextFormField(
                      controller: _phoneController,
                      decoration: PartnerAdminStyles.defaultInputDecoration(
                        'Téléphone',
                        hint: '06 XX XX XX XX',
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: PartnerAdminStyles.defaultInputDecoration(
                        'Email professionnel',
                        hint: 'contact@votre-entreprise.com',
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mot de passe
                    TextFormField(
                      controller: _passwordController,
                      decoration: PartnerAdminStyles.defaultInputDecoration(
                        'Mot de passe',
                        prefixIcon: const Icon(Icons.lock),
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
                    const SizedBox(height: 16),

                    // Confirmation mot de passe
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: PartnerAdminStyles.defaultInputDecoration(
                        'Confirmer le mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
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
                    const SizedBox(height: 24),

                    // Case à cocher pour les conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: PartnerAdminStyles.accentColor,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: 'J\'accepte les ',
                                style: TextStyle(
                                    color: PartnerAdminStyles.textColor),
                                children: [
                                  TextSpan(
                                    text: 'conditions générales d\'utilisation',
                                    style: TextStyle(
                                      color: PartnerAdminStyles.accentColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bouton d'inscription
                    ElevatedButton(
                      onPressed: _register,
                      style: PartnerAdminStyles.primaryButtonStyle,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'CRÉER MON COMPTE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lien vers connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Déjà partenaire?'),
                        TextButton(
                          onPressed: () {
                            context.go('/partner/login');
                          },
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: PartnerAdminStyles.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
