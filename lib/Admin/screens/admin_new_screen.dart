import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/admin_service.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';
import '../../utils/logger.dart';

class AdminNewScreen extends StatefulWidget {
  const AdminNewScreen({Key? key}) : super(key: key);

  @override
  State<AdminNewScreen> createState() => _AdminNewScreenState();
}

class _AdminNewScreenState extends State<AdminNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un administrateur'),
        backgroundColor: PartnerAdminStyles.accentColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  padding:
                      const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                  margin: const EdgeInsets.only(
                      bottom: PartnerAdminStyles.paddingMedium),
                  decoration: BoxDecoration(
                    color: PartnerAdminStyles.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        PartnerAdminStyles.borderRadiusMedium),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: PartnerAdminStyles.errorColor,
                    ),
                  ),
                ),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations de l\'administrateur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingMedium),
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom complet',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir le nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingMedium),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir l\'email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Veuillez saisir un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingMedium),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingMedium),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer le mot de passe';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: PartnerAdminStyles.paddingLarge),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.go(PartnerAdminRoutes.adminDashboard);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: PartnerAdminStyles.paddingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createAdmin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PartnerAdminStyles.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                          : const Text('Créer'),
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

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Afficher un dialogue explicatif
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Création d\'un administrateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Pour créer un nouvel administrateur, suivez ces étapes dans Supabase :'),
            const SizedBox(height: 12),
            _buildStep('1', 'Allez dans Authentication > Users'),
            _buildStep('2', 'Cliquez sur "Add User"'),
            _buildStep('3', 'Saisissez cet email : ${_emailController.text}'),
            _buildStep(
                '4', 'Saisissez un mot de passe et activez "Email Confirmed"'),
            _buildStep('5', 'Notez l\'ID généré pour l\'utilisateur'),
            _buildStep('6',
                'Insérez cet ID avec l\'email et le nom dans la table "admins"'),
            const SizedBox(height: 12),
            const Text(
                'Cette limitation est due à la contrainte de clé étrangère sur la table "admins".'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(PartnerAdminRoutes.adminDashboard);
            },
            child: const Text('Compris'),
          ),
        ],
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: PartnerAdminStyles.accentColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(instruction),
          ),
        ],
      ),
    );
  }
}
