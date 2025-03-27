import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/services/auth_service.dart';
import '../../utils/logger.dart';
import '../models/partner_model.dart';
import '../models/data/data_point_model.dart';
import '../widgets/partner_sidebar.dart';
import '../services/stats_service.dart';
import '../widgets/stats_card.dart';
import '../widgets/stats/chart_card.dart';
import '../widgets/stats/period_selector.dart';

class PartnerStatsScreen extends StatefulWidget {
  const PartnerStatsScreen({super.key});

  @override
  State<PartnerStatsScreen> createState() => _PartnerStatsScreenState();
}

class _PartnerStatsScreenState extends State<PartnerStatsScreen> {
  final AuthService _authService = AuthService();
  final StatsService _statsService = StatsService();

  PartnerModel? _partner;
  bool _isLoading = true;
  String? _errorMessage;

  // Statistiques
  int _reservationsCount = 0;
  int _profileViews = 0;
  double _averageRating = 0.0;
  int _totalMessagesCount = 0;

  // Données pour les graphiques
  List<DataPointModel> _reservationsByMonth = [];
  List<DataPointModel> _viewsByDay = [];

  // Filtres
  String _selectedPeriod = '30j';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

      // Récupérer les statistiques
      final reservationsCount =
          await _statsService.getReservationsCount(partner.id);
      final profileViews = await _statsService.getProfileViews(partner.id);
      final averageRating = await _statsService.getAverageRating(partner.id);
      final totalMessagesCount =
          await _statsService.getTotalMessagesCount(partner.id);

      // Récupérer les données pour les graphiques
      final reservationsByMonth =
          await _statsService.getReservationsByMonth(partner.id);
      final viewsByDay = await _statsService.getViewsByDay(partner.id);

      setState(() {
        _partner = partner;
        _reservationsCount = reservationsCount;
        _profileViews = profileViews;
        _averageRating = averageRating;
        _totalMessagesCount = totalMessagesCount;
        _reservationsByMonth = reservationsByMonth;
        _viewsByDay = viewsByDay;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des données', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger vos statistiques. Veuillez réessayer.';
      });
    }
  }

  // Mettre à jour les données selon la période sélectionnée
  Future<void> _updatePeriod(String period) async {
    setState(() {
      _selectedPeriod = period;
      // Dans une version réelle, on chargerait de nouvelles données selon la période
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Statistiques',
      ),
      drawer: PartnerSidebar(
        selectedIndex: 5, // L'index correspondant à Statistiques dans le menu
        partner: _partner,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des statistiques...')
          : _errorMessage != null
              ? ErrorView(
                  message: _errorMessage!,
                  actionLabel: 'Réessayer',
                  onAction: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sélecteur de période
                        PeriodSelector(
                          selectedPeriod: _selectedPeriod,
                          onPeriodChanged: _updatePeriod,
                        ),

                        const SizedBox(height: 16),

                        // Cartes de statistiques
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Réservations
                            StatsCard(
                              title: 'Réservations',
                              value: '8',
                              icon: Icons.event_available,
                              color: Colors.green,
                              subtitle: 'Total de réservations',
                            ),

                            // Vues du profil
                            StatsCard(
                              title: 'Vues du profil',
                              value: _profileViews.toString(),
                              icon: Icons.visibility,
                              color: Colors.blue,
                              subtitle: 'Visiteurs uniques',
                            ),

                            // Note moyenne
                            StatsCard(
                              title: 'Note moyenne',
                              value: '4.9',
                              icon: Icons.star,
                              color: Colors.orange,
                              subtitle: 'Sur 5 étoiles',
                            ),

                            // Messages
                            StatsCard(
                              title: 'Messages',
                              value: '2',
                              icon: Icons.message,
                              color: Colors.purple,
                              subtitle: 'Total des conversations',
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Graphique des réservations par mois
                        ChartCard(
                          title: 'Réservations mensuelles',
                          subtitle:
                              'Évolution des réservations sur les 6 derniers mois',
                          data: _reservationsByMonth,
                          chartType: 'bar',
                        ),

                        const SizedBox(height: 16),

                        // Graphique des vues quotidiennes
                        ChartCard(
                          title: 'Vues quotidiennes',
                          subtitle:
                              'Évolution des vues sur les 14 derniers jours',
                          data: _viewsByDay,
                          chartType: 'line',
                        ),

                        const SizedBox(height: 32),

                        // Note de bas de page
                        Center(
                          child: Text(
                            'Données mises à jour le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} à ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
