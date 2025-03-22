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
  const AdminReservationAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReservationAnalyticsScreen> createState() =>
      _AdminReservationAnalyticsScreenState();
}

class _AdminReservationAnalyticsScreenState
    extends State<AdminReservationAnalyticsScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  ReservationAnalytics? _reservationAnalytics;
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadReservationAnalytics();
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

  Future<void> _loadReservationAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final analytics = await _adminService.getReservationsAnalytics();
      setState(() {
        _reservationAnalytics = ReservationAnalytics.fromMap(analytics);
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
      ),
      drawer: AdminSidebar(
        currentIndex:
            3, // 3 pour Statistiques (à adapter selon votre navigation)
        adminName: _adminName,
        adminEmail: _adminEmail,
      ),
      body: _isLoading
          ? const LoadingIndicator(
              message: 'Chargement des statistiques réservations...')
          : _errorMessage.isNotEmpty
              ? ErrorView(
                  message: _errorMessage,
                  onAction: _loadReservationAnalytics,
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
      onRefresh: _loadReservationAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Text(
              'Analyse des Réservations',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PartnerAdminStyles.textColor,
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingSmall),
            Text(
              'Statistiques détaillées sur les réservations de la plateforme',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PartnerAdminStyles.textColor.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Carte récapitulative
            Card(
              elevation: PartnerAdminStyles.elevationMedium,
              child: Padding(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
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
                        const SizedBox(width: PartnerAdminStyles.paddingSmall),
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
                      children:
                          _reservationAnalytics!.byStatus.entries.map((entry) {
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
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Réservations par mois
            if (_reservationAnalytics!.byMonth.isNotEmpty)
              AdminBarChartWidget(
                title: 'Réservations par Mois',
                subtitle: 'Derniers 12 mois',
                data: _reservationAnalytics!.byMonth,
                maxY: (_reservationAnalytics!.byMonth.values.fold<int>(
                            0,
                            (prev, element) =>
                                prev > (element as int) ? prev : element) *
                        1.2)
                    .toDouble(),
                gradientColors: const [
                  PartnerAdminStyles.warningColor,
                  Color(0xFFFFD580),
                ],
              ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Revenus par mois
            if (_reservationAnalytics!.revenueByMonth.isNotEmpty)
              AdminLineChartWidget(
                title: 'Revenus par Mois (€)',
                subtitle: 'Derniers 12 mois',
                data: _reservationAnalytics!.revenueByMonth,
                maxY: (_reservationAnalytics!.revenueByMonth.values
                        .fold<double>(0.0, (prev, element) {
                      final double value = element is int
                          ? element.toDouble()
                          : element is double
                              ? element
                              : 0.0;
                      return prev > value ? prev : value;
                    }) *
                    1.2),
                gradientColors: const [
                  PartnerAdminStyles.successColor,
                  Color(0xFF8FECC0),
                ],
                filled: true,
                curved: true,
              ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Top 5 des prestataires
            if (_reservationAnalytics!.topPartners.isNotEmpty)
              _buildTopPartnersCard(),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Distribution par statut
            if (_reservationAnalytics!.byStatus.isNotEmpty)
              AdminPieChartWidget(
                title: 'Distribution par Statut',
                subtitle: 'Répartition des réservations selon leur statut',
                data: _reservationAnalytics!.byStatus,
                colors: const [
                  PartnerAdminStyles.successColor,
                  PartnerAdminStyles.warningColor,
                  PartnerAdminStyles.infoColor,
                  PartnerAdminStyles.accentColor,
                  PartnerAdminStyles.errorColor,
                ],
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
                color: PartnerAdminStyles.textColor.withOpacity(0.7),
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
