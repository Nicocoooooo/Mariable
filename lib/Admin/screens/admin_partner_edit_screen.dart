import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../services/admin_service.dart';
import '../../Partner/models/partner_model.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';

class AdminPartnerEditScreen extends StatefulWidget {
  final String partnerId;
  // Ajouter un booléen pour indiquer s'il s'agit d'un nouveau prestataire
  final bool isNewPartner;

  const AdminPartnerEditScreen({
    Key? key,
    required this.partnerId,
    // Par défaut, c'est false
    this.isNewPartner = false,
  }) : super(key: key);

  @override
  State<AdminPartnerEditScreen> createState() => _AdminPartnerEditScreenState();
}

class _AdminPartnerEditScreenState extends State<AdminPartnerEditScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  PartnerModel? _partner;

  // Contrôleurs pour les champs du formulaire
  final _nomEntrepriseController = TextEditingController();
  final _nomContactController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _telephoneSecondaireController = TextEditingController();
  final _adresseController = TextEditingController();
  final _regionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _typeBudget = 'abordable';
  bool _isVerified = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    // Ne pas charger le prestataire si on est en mode création
    if (!widget.isNewPartner) {
      _loadPartner();
    } else {
      // Initialiser avec des valeurs par défaut pour un nouveau prestataire
      _initializeNewPartner();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomEntrepriseController.dispose();
    _nomContactController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _telephoneSecondaireController.dispose();
    _adresseController.dispose();
    _regionController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Méthode pour initialiser les valeurs par défaut d'un nouveau prestataire
  void _initializeNewPartner() {
    // Pas besoin d'assigner _partner car nous allons travailler directement avec les contrôleurs
    _nomEntrepriseController.text = '';
    _nomContactController.text = '';
    _emailController.text = '';
    _telephoneController.text = '';
    _telephoneSecondaireController.text = '';
    _adresseController.text = '';
    _regionController.text = 'Paris'; // Valeur par défaut
    _descriptionController.text = '';
    _imageUrlController.text = '';
    _typeBudget = 'abordable'; // Valeur par défaut
    _isVerified = false;
    _isActive = true;
  }

  Future<void> _checkAuthentication() async {
    final bool isAdmin = await _authService.isAdmin();
    if (!isAdmin) {
      // Rediriger vers la page de connexion si l'utilisateur n'est pas administrateur
      // ignore: use_build_context_synchronously
      context.go(PartnerAdminRoutes.adminLogin);
      return;
    }
  }

  Future<void> _loadPartner() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final partner = await _adminService.getPartnerById(widget.partnerId);
      if (partner != null) {
        setState(() {
          _partner = partner;
          _isLoading = false;
          _populateFormFields(partner);
        });
      } else {
        setState(() {
          _errorMessage = 'Prestataire non trouvé';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du prestataire: $e';
        _isLoading = false;
      });
    }
  }

  void _populateFormFields(PartnerModel partner) {
    _nomEntrepriseController.text = partner.nomEntreprise;
    _nomContactController.text = partner.nomContact;
    _emailController.text = partner.email;
    _telephoneController.text = partner.telephone;
    _telephoneSecondaireController.text = partner.telephoneSecondaire ?? '';
    _adresseController.text = partner.adresse;
    _regionController.text = partner.region;
    _descriptionController.text = partner.description;
    _imageUrlController.text = partner.imageUrl ?? '';
    _typeBudget = partner.typeBudget;
    _isVerified = partner.isVerified;
    _isActive = partner.actif;
  }

  Future<void> _savePartner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.isNewPartner) {
        // Création d'un nouveau prestataire
        final success = await _adminService.createPartner(
          nomEntreprise: _nomEntrepriseController.text,
          nomContact: _nomContactController.text,
          email: _emailController.text,
          telephone: _telephoneController.text,
          telephoneSecondaire: _telephoneSecondaireController.text.isEmpty
              ? null
              : _telephoneSecondaireController.text,
          adresse: _adresseController.text,
          region: _regionController.text,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text.isEmpty
              ? null
              : _imageUrlController.text,
          typeBudget: _typeBudget,
          isVerified: _isVerified,
          actif: _isActive,
        );

        if (success) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Prestataire créé avec succès. Note: Ceci crée uniquement l\'entrée dans la base de données. '
                  'Pour que le prestataire puisse se connecter, vous devez créer un compte utilisateur dans Supabase avec le même ID.'),
              backgroundColor: PartnerAdminStyles.successColor,
              duration: Duration(seconds: 6),
            ),
          );
          // ignore: use_build_context_synchronously
          context.go(PartnerAdminRoutes.adminPartnersList);
        } else {
          setState(() {
            _errorMessage = 'Erreur lors de la création du prestataire';
            _isSaving = false;
          });
        }
      } else {
        // Mise à jour d'un prestataire existant
        final updatedPartner = _partner!.copyWith(
          nomEntreprise: _nomEntrepriseController.text,
          nomContact: _nomContactController.text,
          email: _emailController.text,
          telephone: _telephoneController.text,
          telephoneSecondaire: _telephoneSecondaireController.text.isEmpty
              ? null
              : _telephoneSecondaireController.text,
          adresse: _adresseController.text,
          region: _regionController.text,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text.isEmpty
              ? null
              : _imageUrlController.text,
          typeBudget: _typeBudget,
          isVerified: _isVerified,
          actif: _isActive,
        );

        final success = await _adminService.updatePartner(updatedPartner);

        if (success) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prestataire mis à jour avec succès'),
              backgroundColor: PartnerAdminStyles.successColor,
            ),
          );
          // ignore: use_build_context_synchronously
          context.go(PartnerAdminRoutes.adminPartnersList);
        } else {
          setState(() {
            _errorMessage = 'Erreur lors de la mise à jour du prestataire';
            _isSaving = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewPartner
            ? 'Ajouter un prestataire'
            : (_partner != null
                ? 'Modifier ${_partner!.nomEntreprise}'
                : 'Modifier prestataire')),
        backgroundColor: PartnerAdminStyles.accentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.go(PartnerAdminRoutes.adminPartnersList),
            tooltip: 'Retour à la liste',
          ),
        ],
      ),
      body: _isLoading && !widget.isNewPartner
          ? const LoadingIndicator(message: 'Chargement du prestataire...')
          : _errorMessage.isNotEmpty && !widget.isNewPartner
              ? ErrorView(
                  message: _errorMessage,
                  onAction: _loadPartner,
                  actionLabel: 'Réessayer',
                )
              : _buildEditForm(),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec image et statuts
            _buildPartnerHeader(),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Informations de base
            const Text(
              'Informations de base',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            Card(
              elevation: PartnerAdminStyles.elevationSmall,
              child: Padding(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomEntrepriseController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'entreprise',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir le nom de l\'entreprise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    TextFormField(
                      controller: _nomContactController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du contact',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir le nom du contact';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    TextFormField(
                      controller: _emailController,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Coordonnées
            const Text(
              'Coordonnées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            Card(
              elevation: PartnerAdminStyles.elevationSmall,
              child: Padding(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _telephoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir le téléphone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    TextFormField(
                      controller: _telephoneSecondaireController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone secondaire (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    TextFormField(
                      controller: _adresseController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir l\'adresse';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    TextFormField(
                      controller: _regionController,
                      decoration: const InputDecoration(
                        labelText: 'Région',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir la région';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Détails
            const Text(
              'Détails',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            Card(
              elevation: PartnerAdminStyles.elevationSmall,
              child: Padding(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type de budget',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingSmall),
                    _buildBudgetSelector(),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir une description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de l\'image (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Statuts
            const Text(
              'Statuts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            Card(
              elevation: PartnerAdminStyles.elevationSmall,
              child: Padding(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Vérifié'),
                      subtitle: const Text(
                          'Le prestataire est vérifié par l\'administration'),
                      value: _isVerified,
                      onChanged: (value) {
                        setState(() {
                          _isVerified = value;
                        });
                      },
                      activeColor: PartnerAdminStyles.successColor,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Actif'),
                      subtitle: const Text(
                          'Le prestataire est visible sur la plateforme'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: PartnerAdminStyles.infoColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.go(PartnerAdminRoutes.adminPartnersList),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                          color: PartnerAdminStyles.textColor.withOpacity(0.5)),
                      foregroundColor: PartnerAdminStyles.textColor,
                    ),
                  ),
                ),
                const SizedBox(width: PartnerAdminStyles.paddingMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _savePartner,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: PartnerAdminStyles.accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerHeader() {
    if (widget.isNewPartner) {
      return Card(
        elevation: PartnerAdminStyles.elevationSmall,
        child: Padding(
          padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PartnerAdminStyles.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_business,
                  color: PartnerAdminStyles.accentColor,
                  size: 40,
                ),
              ),
              const SizedBox(width: PartnerAdminStyles.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nouveau prestataire',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remplissez le formulaire pour créer un nouveau prestataire',
                      style: TextStyle(
                        fontSize: 12,
                        color: PartnerAdminStyles.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: PartnerAdminStyles.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Row(
          children: [
            // Image ou logo du prestataire
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PartnerAdminStyles.secondaryColor,
                borderRadius: BorderRadius.circular(8),
                image:
                    _partner?.imageUrl != null && _partner!.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_partner!.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: _partner?.imageUrl == null || _partner!.imageUrl!.isEmpty
                  ? const Icon(
                      Icons.business,
                      color: PartnerAdminStyles.accentColor,
                      size: 40,
                    )
                  : null,
            ),
            const SizedBox(width: PartnerAdminStyles.paddingMedium),

            // Informations principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _partner?.nomEntreprise ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.partnerId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: PartnerAdminStyles.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusBadge(
                        _partner?.isVerified ?? false,
                        trueText: 'Vérifié',
                        falseText: 'Non vérifié',
                        trueColor: PartnerAdminStyles.successColor,
                        falseColor: PartnerAdminStyles.warningColor,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(
                        _partner?.actif ?? true,
                        trueText: 'Actif',
                        falseText: 'Inactif',
                        trueColor: PartnerAdminStyles.infoColor,
                        falseColor: PartnerAdminStyles.errorColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    bool status, {
    required String trueText,
    required String falseText,
    required Color trueColor,
    required Color falseColor,
  }) {
    final text = status ? trueText : falseText;
    final color = status ? trueColor : falseColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PartnerAdminStyles.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius:
            BorderRadius.circular(PartnerAdminStyles.borderRadiusSmall),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius:
            BorderRadius.circular(PartnerAdminStyles.borderRadiusSmall),
      ),
      child: Column(
        children: [
          _buildBudgetOption('abordable', 'Abordable'),
          const Divider(height: 1),
          _buildBudgetOption('premium', 'Premium'),
          const Divider(height: 1),
          _buildBudgetOption('luxe', 'Luxe'),
        ],
      ),
    );
  }

  Widget _buildBudgetOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _typeBudget,
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _typeBudget = newValue;
          });
        }
      },
      activeColor: PartnerAdminStyles.accentColor,
      dense: true,
    );
  }
}
