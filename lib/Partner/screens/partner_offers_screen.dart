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
import '../models/data/tarif_model.dart';
import '../widgets/partner_sidebar.dart';
import '../widgets/offers/offer_card.dart';
import '../services/tarif_service.dart';

class PartnerOffersScreen extends StatefulWidget {
  const PartnerOffersScreen({Key? key}) : super(key: key);

  @override
  State<PartnerOffersScreen> createState() => _PartnerOffersScreenState();
}

class _PartnerOffersScreenState extends State<PartnerOffersScreen> {
  final AuthService _authService = AuthService();
  final TarifService _tarifService = TarifService();

  PartnerModel? _partner;
  List<TarifModel> _offers = [];
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (!_authService.isLoggedIn) {
        context.go('/partner/login');
        return;
      }

      // Vérifier si l'utilisateur est un partenaire
      final isPartner = await _authService.isPartner();
      if (!isPartner) {
        _authService.signOut();
        if (mounted) {
          context.go('/partner/login');
        }
        return;
      }

      // Récupérer les données du partenaire
      final response = await Supabase.instance.client
          .from('presta')
          .select()
          .eq('id', _authService.currentUser!.id)
          .single();

      final partner = PartnerModel.fromMap(response);

      // Récupérer les tarifs du partenaire
      final offers = await _tarifService.getPartnerTarifs(partner.id);

      setState(() {
        _partner = partner;
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des données', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger vos offres. Veuillez réessayer.';
      });
    }
  }

  Future<void> _deleteOffer(String offerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette offre ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _tarifService.deleteTarif(offerId);

      setState(() {
        _offers.removeWhere((offer) => offer.id == offerId);
        _successMessage = 'Offre supprimée avec succès';
        _isDeleting = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression de l\'offre', e);
      setState(() {
        _errorMessage =
            'Une erreur est survenue lors de la suppression de l\'offre';
        _isDeleting = false;
      });
    }
  }

  Future<void> _toggleOfferVisibility(String offerId, bool isVisible) async {
    try {
      await _tarifService.toggleTarifVisibility(offerId, isVisible);

      setState(() {
        final index = _offers.indexWhere((offer) => offer.id == offerId);
        if (index != -1) {
          _offers[index] = _offers[index].copyWith(isVisible: isVisible);
          _successMessage =
              isVisible ? 'Offre rendue visible' : 'Offre masquée';
        }
      });
    } catch (e) {
      AppLogger.error('Erreur lors du changement de visibilité de l\'offre', e);
      setState(() {
        _errorMessage =
            'Une erreur est survenue lors du changement de visibilité de l\'offre';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes Offres',
      ),
      drawer: PartnerSidebar(
        selectedIndex: 1, // L'index correspondant à Offres dans le menu
        partner: _partner,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/partner/offers/add'),
        backgroundColor: PartnerAdminStyles.accentColor,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des offres...')
          : _errorMessage != null && _offers.isEmpty
              ? ErrorView(
                  message: _errorMessage!,
                  actionLabel: 'Réessayer',
                  onAction: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Messages d'état
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
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
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _successMessage!,
                              style: TextStyle(color: Colors.green.shade800),
                            ),
                          ),

                        // En-tête avec compteur et lien d'ajout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_offers.length} offre${_offers.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: PartnerAdminStyles.accentColor,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.push('/partner/offers/add'),
                              icon: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text('Ajouter une offre'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PartnerAdminStyles.accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Liste des offres
                        if (_offers.isEmpty)
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune offre trouvée',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Commencez par créer votre première offre',
                                    style: TextStyle(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        context.push('/partner/offers/add'),
                                    icon: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: const Text('Créer une offre'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          PartnerAdminStyles.accentColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _offers.length,
                            itemBuilder: (context, index) {
                              final offer = _offers[index];
                              return OfferCard(
                                offer: offer,
                                onEdit: () => context
                                    .push('/partner/offers/edit/${offer.id}'),
                                onDelete: () => _deleteOffer(offer.id),
                                onToggleVisibility: (isVisible) =>
                                    _toggleOfferVisibility(offer.id, isVisible),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
