import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/services/auth_service.dart';
import '../Partner/models/partner_model.dart';
import '../shared/widgets/custom_app_bar.dart';
import '../shared/widgets/loading_indicator.dart';
import '../utils/logger.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  PartnerModel? _currentPartner;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Test de connexion
  Future<void> _testSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Veuillez remplir tous les champs';
          _isLoading = false;
        });
        return;
      }

      final response = await _authService.signIn(email, password);

      setState(() {
        _successMessage = 'Connexion réussie! User ID: ${response.user?.id}';
        _isLoading = false;
      });

      // Essayons de récupérer les données du partenaire
      await _fetchPartnerData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
        _isLoading = false;
      });
      AppLogger.error('Erreur de connexion', e);
    }
  }

  // Test de déconnexion
  Future<void> _testSignOut() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.signOut();

      setState(() {
        _successMessage = 'Déconnexion réussie!';
        _currentPartner = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de déconnexion: ${e.toString()}';
        _isLoading = false;
      });
      AppLogger.error('Erreur de déconnexion', e);
    }
  }

  // Récupération des données du partenaire
  Future<void> _fetchPartnerData() async {
    if (!_authService.isLoggedIn) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isPartner = await _authService.isPartner();

      if (!isPartner) {
        setState(() {
          _errorMessage = 'L\'utilisateur n\'est pas un partenaire';
          _isLoading = false;
        });
        return;
      }

      // Récupérer les données du partenaire depuis Supabase
      final response = await Supabase.instance.client
          .from('presta')
          .select()
          .eq('id', _authService.currentUser!.id)
          .single();

      if (response != null) {
        setState(() {
          _currentPartner = PartnerModel.fromMap(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de récupération des données: ${e.toString()}';
        _isLoading = false;
      });
      AppLogger.error('Erreur de récupération des données partenaire', e);
    }
  }

  // Test de création d'un partenaire
  Future<void> _testCreatePartner() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Veuillez remplir tous les champs';
          _isLoading = false;
        });
        return;
      }

      // Créer un nouveau partenaire
      final response = await _authService.registerPartner(
          email, password, 'Test Partner', '0123456789');

      setState(() {
        _successMessage = 'Inscription réussie! User ID: ${response.user?.id}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur d\'inscription: ${e.toString()}';
        _isLoading = false;
      });
      AppLogger.error('Erreur d\'inscription partenaire', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Test des fonctionnalités',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const LoadingIndicator(message: 'Opération en cours...')
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Messages de succès/erreur
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),

                    if (_successMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green.shade800),
                        ),
                      ),

                    // Statut de connexion
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _authService.isLoggedIn
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Statut: ${_authService.isLoggedIn ? 'Connecté' : 'Déconnecté'}',
                        style: TextStyle(
                          color: _authService.isLoggedIn
                              ? Colors.blue.shade800
                              : Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Informations du partenaire actuel
                    if (_currentPartner != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Partenaire: ${_currentPartner!.nomEntreprise}',
                              style: TextStyle(
                                color: Colors.purple.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Email: ${_currentPartner!.email}'),
                            Text('Téléphone: ${_currentPartner!.telephone}'),
                            Text('Région: ${_currentPartner!.region}'),
                            Text(
                                'Type de budget: ${_currentPartner!.typeBudget}'),
                          ],
                        ),
                      ),

                    // Champs de formulaire
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),

                    // Boutons d'action
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _testSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF524B46),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Test Connexion'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _testCreatePartner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Test Inscription Partenaire'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _testSignOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Test Déconnexion'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
