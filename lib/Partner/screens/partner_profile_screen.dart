import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/services/auth_service.dart';
import '../../utils/logger.dart';
import '../models/partner_model.dart';
import '../widgets/partner_sidebar.dart';

class PartnerProfileScreen extends StatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  State<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<PartnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Contrôleurs pour les champs de formulaire
  late TextEditingController _nomEntrepriseController;
  late TextEditingController _nomContactController;
  late TextEditingController _telephoneController;
  late TextEditingController _telephoneSecondaireController;
  late TextEditingController _adresseController;
  late TextEditingController _regionController;
  late TextEditingController _descriptionController;

  PartnerModel? _partner;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadPartnerData();
  }

  void _initControllers() {
    _nomEntrepriseController = TextEditingController();
    _nomContactController = TextEditingController();
    _telephoneController = TextEditingController();
    _telephoneSecondaireController = TextEditingController();
    _adresseController = TextEditingController();
    _regionController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nomEntrepriseController.dispose();
    _nomContactController.dispose();
    _telephoneController.dispose();
    _telephoneSecondaireController.dispose();
    _adresseController.dispose();
    _regionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPartnerData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!_authService.isLoggedIn) {
        context.go('/partner/login');
        return;
      }

      // Récupérer les données du partenaire
      final response = await Supabase.instance.client
          .from('presta')
          .select()
          .eq('id', _authService.currentUser!.id)
          .single();

      final partner = PartnerModel.fromMap(response);

      // Remplir les contrôleurs avec les données
      _nomEntrepriseController.text = partner.nomEntreprise;
      _nomContactController.text = partner.nomContact;
      _telephoneController.text = partner.telephone;
      _telephoneSecondaireController.text = partner.telephoneSecondaire ?? '';
      _adresseController.text = partner.adresse;
      _regionController.text = partner.region;
      _descriptionController.text = partner.description;

      setState(() {
        _partner = partner;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des données du partenaire', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger vos données. Veuillez réessayer.';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Mettre à jour les données du partenaire
      await Supabase.instance.client.from('presta').update({
        'nom_entreprise': _nomEntrepriseController.text.trim(),
        'nom_contact': _nomContactController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'telephone_secondaire': _telephoneSecondaireController.text.trim(),
        'adresse': _adresseController.text.trim(),
        'region': _regionController.text.trim(),
        'description': _descriptionController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _authService.currentUser!.id);

      // Recharger les données pour avoir les valeurs à jour
      await _loadPartnerData();

      setState(() {
        _isSaving = false;
        _successMessage = 'Profil mis à jour avec succès';
      });
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du profil', e);
      setState(() {
        _isSaving = false;
        _errorMessage =
            'Une erreur est survenue lors de la mise à jour du profil';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mon Profil',
      ),
      drawer: PartnerSidebar(
        selectedIndex: 6,
        partner: _partner,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des données...')
          : _errorMessage != null && _partner == null
              ? ErrorView(
                  message: _errorMessage!,
                  actionLabel: 'Réessayer',
                  onAction: _loadPartnerData,
                )
              : _buildProfileForm(),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Text(
              'Informations du profil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complétez ou modifiez vos informations pour que vos clients puissent mieux vous connaître',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Messages d'erreur ou de succès
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
                ),
              ),

            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: Colors.green.shade800),
                ),
              ),

            // Section Informations générales
            const SectionTitle(title: 'Informations générales'),

            // Nom de l'entreprise
            TextFormField(
              controller: _nomEntrepriseController,
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

            // Nom du contact
            TextFormField(
              controller: _nomContactController,
              decoration: PartnerAdminStyles.defaultInputDecoration(
                'Nom du contact principal',
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du contact principal';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Téléphone
            TextFormField(
              controller: _telephoneController,
              decoration: PartnerAdminStyles.defaultInputDecoration(
                'Téléphone principal',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un numéro de téléphone';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Téléphone secondaire
            TextFormField(
              controller: _telephoneSecondaireController,
              decoration: PartnerAdminStyles.defaultInputDecoration(
                'Téléphone secondaire (optionnel)',
                prefixIcon: const Icon(Icons.phone_forwarded),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // Section Localisation
            const SectionTitle(title: 'Localisation'),

            // Adresse
            TextFormField(
              controller: _adresseController,
              decoration: PartnerAdminStyles.defaultInputDecoration(
                'Adresse complète',
                prefixIcon: const Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une adresse';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Région
            TextFormField(
              controller: _regionController,
              decoration: PartnerAdminStyles.defaultInputDecoration(
                'Région',
                prefixIcon: const Icon(Icons.map),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une région';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Section Description
            const SectionTitle(title: 'Description de votre entreprise'),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: PartnerAdminStyles.defaultInputDecoration(
                'Description détaillée',
                hint:
                    'Décrivez votre entreprise, vos services, votre expérience...',
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                if (value.length < 50) {
                  return 'La description doit contenir au moins 50 caractères';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Bouton de sauvegarde
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: PartnerAdminStyles.primaryButtonStyle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'ENREGISTRER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour les titres de section
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: PartnerAdminStyles.accentColor,
        ),
      ),
    );
  }
}
