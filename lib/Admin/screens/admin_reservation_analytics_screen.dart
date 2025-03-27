import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/pie_chart_widget.dart';
import '../models/analytics/analytics_models.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';

class AdminReservationAnalyticsScreen extends StatefulWidget {
  const AdminReservationAnalyticsScreen({super.key});

  @override
  State<AdminReservationAnalyticsScreen> createState() =>
      _AdminReservationAnalyticsScreenState();
}

class _AdminReservationAnalyticsScreenState
    extends State<AdminReservationAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  ReservationAnalytics? _reservationAnalytics;
  String _adminName = '';
  String _adminEmail = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkAuthentication();
    _loadFakeData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    final bool isAdmin = await _authService.isAdmin();
    if (!isAdmin) {
      // Rediriger vers la page de connexion si l'utilisateur n'est pas administrateur
      // ignore: use_build_context_synchronously
      context.go(PartnerAdminRoutes.adminLogin);
      return;
    }

    if (_authService.currentUser != null) {
      // Charger les informations de l'administrateur
      final admin =
          await _adminService.getAdminById(_authService.currentUser!.id);
      if (admin != null) {
        setState(() {
          _adminName = admin.nom;
          _adminEmail = admin.email;
        });
      }
    }
  }

  Future<void> _loadFakeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Simuler un chargement
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Données codées en dur pour les réservations
      final Map<String, dynamic> reservationsByMonth = {
        '2024-10': 42,
        '2024-11': 48,
        '2024-12': 35,
        '2025-01': 52,
        '2025-02': 68,
        '2025-03': 75,
      };

      final Map<String, dynamic> revenueByMonth = {
        '2024-10': 84000.0,
        '2024-11': 96000.0,
        '2024-12': 70000.0,
        '2025-01': 104000.0,
        '2025-02': 136000.0,
        '2025-03': 150000.0,
      };

      final Map<String, int> reservationsByStatus = {
        'Confirmée': 121,
        'En attente': 56,
        'Terminée': 85,
        'Annulée': 8,
      };

      final Map<String, int> reservationsByPartnerType = {
        'Lieux': 96,
        'Traiteurs': 78,
        'Photographes': 42,
        'DJ': 32,
        'Wedding Planners': 22,
      };

      final Map<String, int> topPartners = {
        'Château des Roses': 18,
        'Traiteur Deluxe': 15,
        'Studio Photo Elite': 12,
        'Domaine des Cèdres': 10,
        'Wedding Planners Paris': 8,
      };

      final fakeAnalytics = {
        'total': reservationsByStatus.values.fold(0, (a, b) => a + b),
        'byMonth': reservationsByMonth,
        'revenueByMonth': revenueByMonth,
        'byStatus': reservationsByStatus,
        'byPartnerType': reservationsByPartnerType,
        'topPartners': topPartners,
      };

      setState(() {
        _reservationAnalytics = ReservationAnalytics.fromMap(fakeAnalytics);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erreur lors du chargement des statistiques réservations: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse des Réservations'),
        backgroundColor: PartnerAdminStyles.accentColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(PartnerAdminRoutes.adminReports),
        ),
      ),
      drawer: AdminSidebar(
        currentIndex: 3,
        adminName: _adminName,
        adminEmail: _adminEmail,
      ),
      body: _isLoading
          ? const LoadingIndicator(
              message: 'Chargement des statistiques réservations...')
          : _errorMessage.isNotEmpty
              ? ErrorView(
                  message: _errorMessage,
                  onAction: _loadFakeData,
                  actionLabel: 'Réessayer',
                )
              : _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    if (_reservationAnalytics == null) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFakeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            FadeTransition(
              opacity:
                  _animationController.drive(CurveTween(curve: Curves.easeIn)),
              child: Text(
                'Analyse des Réservations',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PartnerAdminStyles.textColor,
                    ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingSmall),
            FadeTransition(
              opacity:
                  _animationController.drive(CurveTween(curve: Curves.easeIn)),
              child: Text(
                'Statistiques détaillées sur les réservations de la plateforme',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: PartnerAdminStyles.textColor.withAlpha(179),
                    ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Carte récapitulative
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: Card(
                elevation: PartnerAdminStyles.elevationMedium,
                child: Padding(
                  padding:
                      const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: PartnerAdminStyles.warningColor,
                            size: 24,
                          ),
                          const SizedBox(
                              width: PartnerAdminStyles.paddingSmall),
                          Text(
                            'Résumé des Réservations',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingMedium),
                      Text(
                        'Nombre total de réservations: ${_reservationAnalytics!.total}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingSmall),
                      const Text(
                        'Répartition par statut:',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingSmall),
                      Wrap(
                        spacing: PartnerAdminStyles.paddingSmall,
                        runSpacing: PartnerAdminStyles.paddingSmall,
                        children: _reservationAnalytics!.byStatus.entries
                            .map((entry) {
                          return Chip(
                            label: Text(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: PartnerAdminStyles.warningColor,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Réservations par mois
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: AdminBarChartWidget(
                title: 'Réservations par Mois',
                subtitle: 'Derniers 6 mois',
                data: _reservationAnalytics!.byMonth,
                maxY: 100,
                gradientColors: const [
                  PartnerAdminStyles.warningColor,
                  Color(0xFFFFD580),
                ],
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Revenus par mois
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: AdminLineChartWidget(
                title: 'Revenus par Mois (€)',
                subtitle: 'Derniers 6 mois',
                data: _reservationAnalytics!.revenueByMonth,
                maxY: 200000,
                gradientColors: const [
                  PartnerAdminStyles.successColor,
                  Color(0xFF8FECC0),
                ],
                filled: true,
                curved: true,
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Top 5 des prestataires
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: _buildTopPartnersCard(),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Distribution par statut
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: AdminPieChartWidget(
                title: 'Distribution par Statut',
                subtitle: 'Répartition des réservations selon leur statut',
                data: _reservationAnalytics!.byStatus,
                colors: const [
                  PartnerAdminStyles.successColor,
                  PartnerAdminStyles.warningColor,
                  PartnerAdminStyles.infoColor,
                  PartnerAdminStyles.errorColor,
                ],
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Bouton de retour
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.go(PartnerAdminRoutes.adminReports),
                label: const Text('Retour aux rapports'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PartnerAdminStyles.accentColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPartnersCard() {
    return Card(
      elevation: PartnerAdminStyles.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 des Prestataires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Les prestataires avec le plus de réservations',
              style: TextStyle(
                fontSize: 14,
                color: PartnerAdminStyles.textColor.withAlpha(179),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reservationAnalytics!.topPartners.length,
              itemBuilder: (context, index) {
                final entry =
                    _reservationAnalytics!.topPartners.entries.elementAt(index);
                final partnerName = entry.key;
                final reservationCount = entry.value;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index == 0
                        ? Colors.amber
                        : index == 1
                            ? Colors.grey.shade300
                            : index == 2
                                ? Colors.brown.shade300
                                : PartnerAdminStyles.accentColor,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index <= 2 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    partnerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Chip(
                    label: Text(
                      '$reservationCount réservations',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: PartnerAdminStyles.warningColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
