import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/services/auth_service.dart';
import '../../utils/logger.dart';
import '../models/data/tarif_model.dart';
import '../services/tarif_service.dart';

class PartnerOfferFormScreen extends StatefulWidget {
  final String?
      offerId; // Null pour une nouvelle offre, non-null pour l'édition

  const PartnerOfferFormScreen({super.key, this.offerId});

  @override
  State<PartnerOfferFormScreen> createState() => _PartnerOfferFormScreenState();
}

class _PartnerOfferFormScreenState extends State<PartnerOfferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TarifService _tarifService = TarifService();

  // Contrôleurs pour les champs de formulaire
  late TextEditingController _nomFormuleController;
  late TextEditingController _prixBaseController;
  late TextEditingController _descriptionController;
  late TextEditingController _minInvitesController;
  late TextEditingController _maxInvitesController;
  late TextEditingController _coefWeekendController;
  late TextEditingController _coefHauteSaisonController;

  // État du formulaire
  String _typePrix = 'fixe'; // Par défaut
  bool _isVisible = true;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _offerId;
  String? _partnerId;
  bool _isNewOffer = true;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _offerId = widget.offerId;
    _isNewOffer = _offerId == null;
    _loadData();
  }

  void _initControllers() {
    _nomFormuleController = TextEditingController();
    _prixBaseController = TextEditingController();
    _descriptionController = TextEditingController();
    _minInvitesController = TextEditingController();
    _maxInvitesController = TextEditingController();
    _coefWeekendController = TextEditingController();
    _coefHauteSaisonController = TextEditingController();
  }

  @override
  void dispose() {
    _nomFormuleController.dispose();
    _prixBaseController.dispose();
    _descriptionController.dispose();
    _minInvitesController.dispose();
    _maxInvitesController.dispose();
    _coefWeekendController.dispose();
    _coefHauteSaisonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_authService.isLoggedIn) {
      context.go('/partner/login');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérifier si l'utilisateur est un partenaire
      final isPartner = await _authService.isPartner();
      if (!isPartner) {
        _authService.signOut();
        if (mounted) {
          context.go('/partner/login');
        }
        return;
      }

      _partnerId = _authService.currentUser!.id;

      // Si on modifie une offre existante
      if (_offerId != null) {
        final offer = await _tarifService.getTarifById(_offerId!);

        // Vérifier que le partenaire est bien le propriétaire de l'offre
        if (offer.prestaId != _partnerId) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Vous n\'êtes pas autorisé à modifier cette offre.';
          });
          return;
        }

        // Remplir le formulaire avec les données existantes
        setState(() {
          _nomFormuleController.text = offer.nomFormule;
          _prixBaseController.text = offer.prixBase.toString();
          _descriptionController.text = offer.description;
          _minInvitesController.text = offer.minInvites?.toString() ?? '';
          _maxInvitesController.text = offer.maxInvites?.toString() ?? '';
          _coefWeekendController.text = offer.coefWeekend?.toString() ?? '';
          _coefHauteSaisonController.text =
              offer.coefHauteSaison?.toString() ?? '';
          _typePrix = offer.typePrix;
          _isVisible = offer.isVisible;
          _isLoading = false;
          _isNewOffer = false;
        });
      } else {
        // Nouvelle offre
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des données de l\'offre', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger les données de l\'offre. Veuillez réessayer.';
      });
    }
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Convertir les valeurs numériques
      final double prixBase =
          double.parse(_prixBaseController.text.replaceAll(',', '.'));
      final int? minInvites = _minInvitesController.text.isNotEmpty
          ? int.parse(_minInvitesController.text)
          : null;
      final int? maxInvites = _maxInvitesController.text.isNotEmpty
          ? int.parse(_maxInvitesController.text)
          : null;
      final double? coefWeekend = _coefWeekendController.text.isNotEmpty
          ? double.parse(_coefWeekendController.text.replaceAll(',', '.'))
          : null;
      final double? coefHauteSaison = _coefHauteSaisonController.text.isNotEmpty
          ? double.parse(_coefHauteSaisonController.text.replaceAll(',', '.'))
          : null;

      TarifModel offer;

      if (_isNewOffer) {
        // Créer une nouvelle offre
        offer = TarifModel(
          id: '', // Sera généré par Supabase
          prestaId: _partnerId!,
          nomFormule: _nomFormuleController.text,
          prixBase: prixBase,
          typePrix: _typePrix,
          minInvites: minInvites,
          maxInvites: maxInvites,
          coefWeekend: coefWeekend,
          coefHauteSaison: coefHauteSaison,
          description: _descriptionController.text,
          createdAt: DateTime.now(),
          isVisible: _isVisible,
        );

        await _tarifService.createTarif(offer);
      } else {
        // Mettre à jour une offre existante
        offer = TarifModel(
          id: _offerId!,
          prestaId: _partnerId!,
          nomFormule: _nomFormuleController.text,
          prixBase: prixBase,
          typePrix: _typePrix,
          minInvites: minInvites,
          maxInvites: maxInvites,
          coefWeekend: coefWeekend,
          coefHauteSaison: coefHauteSaison,
          description: _descriptionController.text,
          createdAt: DateTime.now(), // Sera ignoré lors de la mise à jour
          updatedAt: DateTime.now(),
          isVisible: _isVisible,
        );

        await _tarifService.updateTarif(offer);
      }

      // Retourner à la liste des offres
      if (mounted) {
        context.go('/partner/offers');
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'enregistrement de l\'offre', e);
      setState(() {
        _isSaving = false;
        _errorMessage =
            'Une erreur est survenue lors de l\'enregistrement de l\'offre.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isNewOffer ? 'Ajouter une offre' : 'Modifier l\'offre',
        actions: [
          TextButton(
            onPressed: () => context.go('/partner/offers'),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement...')
          : _errorMessage != null && _isNewOffer
              ? ErrorView(
                  message: _errorMessage!,
                  actionLabel: 'Réessayer',
                  onAction: _loadData,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        // Nom de la formule
                        const Text(
                          'Nom de la formule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PartnerAdminStyles.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nomFormuleController,
                          decoration: PartnerAdminStyles.defaultInputDecoration(
                            'Nom de la formule',
                            hint: 'Ex: Formule Premium',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un nom pour votre formule';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Prix et type de prix
                        const Text(
                          'Prix et tarification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PartnerAdminStyles.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Prix de base
                            Expanded(
                              child: TextFormField(
                                controller: _prixBaseController,
                                decoration:
                                    PartnerAdminStyles.defaultInputDecoration(
                                  'Prix de base',
                                  hint: 'Ex: 1500',
                                ).copyWith(
                                  prefixText: '€ ',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]')),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer un prix';
                                  }
                                  try {
                                    double.parse(value.replaceAll(',', '.'));
                                  } catch (e) {
                                    return 'Veuillez entrer un nombre valide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Type de prix
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Type de tarification',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: PartnerAdminStyles.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _typePrix,
                                    decoration: PartnerAdminStyles
                                        .defaultInputDecoration(
                                      '',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'fixe',
                                        child: Text('Prix fixe'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'par_personne',
                                        child: Text('Par personne'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _typePrix = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Nombre d'invités
                        const Text(
                          'Nombre d\'invités (optionnel)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PartnerAdminStyles.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Minimum d'invités
                            Expanded(
                              child: TextFormField(
                                controller: _minInvitesController,
                                decoration:
                                    PartnerAdminStyles.defaultInputDecoration(
                                  'Minimum d\'invités',
                                  hint: 'Min.',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    try {
                                      int.parse(value);
                                    } catch (e) {
                                      return 'Nombre invalide';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Maximum d'invités
                            Expanded(
                              child: TextFormField(
                                controller: _maxInvitesController,
                                decoration:
                                    PartnerAdminStyles.defaultInputDecoration(
                                  'Maximum d\'invités',
                                  hint: 'Max.',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    try {
                                      int.parse(value);
                                    } catch (e) {
                                      return 'Nombre invalide';
                                    }

                                    // Vérifier que max >= min si les deux sont spécifiés
                                    if (_minInvitesController.text.isNotEmpty) {
                                      final min =
                                          int.parse(_minInvitesController.text);
                                      final max = int.parse(value);
                                      if (max < min) {
                                        return 'Max. doit être >= Min.';
                                      }
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Coefficients (weekend, haute saison)
                        const Text(
                          'Coefficients multiplicateurs (optionnel)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PartnerAdminStyles.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Coefficient weekend
                            Expanded(
                              child: TextFormField(
                                controller: _coefWeekendController,
                                decoration:
                                    PartnerAdminStyles.defaultInputDecoration(
                                  'Coef. weekend',
                                  hint: 'Ex: 1.2',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]')),
                                ],
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    try {
                                      final val = double.parse(
                                          value.replaceAll(',', '.'));
                                      if (val <= 0) {
                                        return 'Doit être > 0';
                                      }
                                    } catch (e) {
                                      return 'Nombre invalide';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Coefficient haute saison
                            Expanded(
                              child: TextFormField(
                                controller: _coefHauteSaisonController,
                                decoration:
                                    PartnerAdminStyles.defaultInputDecoration(
                                  'Coef. haute saison',
                                  hint: 'Ex: 1.5',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]')),
                                ],
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    try {
                                      final val = double.parse(
                                          value.replaceAll(',', '.'));
                                      if (val <= 0) {
                                        return 'Doit être > 0';
                                      }
                                    } catch (e) {
                                      return 'Nombre invalide';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        // Note explicative pour les coefficients
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Les coefficients sont des multiplicateurs appliqués au prix (ex: 1.2 = +20%).',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description de l\'offre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PartnerAdminStyles.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: PartnerAdminStyles.defaultInputDecoration(
                            'Description détaillée',
                            hint: 'Décrivez votre offre en détail...',
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une description';
                            }
                            if (value.length < 10) {
                              return 'La description doit contenir au moins 10 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Visibilité
                        Row(
                          children: [
                            Switch(
                              value: _isVisible,
                              activeColor: PartnerAdminStyles.accentColor,
                              onChanged: (value) {
                                setState(() {
                                  _isVisible = value;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Rendre cette offre visible aux clients',
                              style: TextStyle(
                                fontSize: 16,
                                color: PartnerAdminStyles.textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Bouton de sauvegarde
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveOffer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PartnerAdminStyles.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isNewOffer
                                        ? 'CRÉER L\'OFFRE'
                                        : 'ENREGISTRER LES MODIFICATIONS',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
