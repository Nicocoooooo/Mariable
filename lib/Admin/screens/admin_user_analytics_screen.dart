import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/pie_chart_widget.dart';
import '../models/analytics/analytics_models.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';

class AdminUserAnalyticsScreen extends StatefulWidget {
  const AdminUserAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserAnalyticsScreen> createState() =>
      _AdminUserAnalyticsScreenState();
}

class _AdminUserAnalyticsScreenState extends State<AdminUserAnalyticsScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  UserAnalytics? _userAnalytics;
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadUserAnalytics();
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

  Future<void> _loadUserAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final analytics = await _adminService.getUsersAnalytics();
      setState(() {
        _userAnalytics = UserAnalytics.fromMap(analytics);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erreur lors du chargement des statistiques utilisateurs: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse des Utilisateurs'),
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
              message: 'Chargement des statistiques utilisateurs...')
          : _errorMessage.isNotEmpty
              ? ErrorView(
                  message: _errorMessage,
                  onAction: _loadUserAnalytics,
                  actionLabel: 'Réessayer',
                )
              : _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    if (_userAnalytics == null) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Text(
              'Analyse des Utilisateurs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PartnerAdminStyles.textColor,
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingSmall),
            Text(
              'Statistiques détaillées sur les utilisateurs de la plateforme',
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
                          Icons.people,
                          color: PartnerAdminStyles.infoColor,
                          size: 24,
                        ),
                        const SizedBox(width: PartnerAdminStyles.paddingSmall),
                        Text(
                          'Résumé des Utilisateurs',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    Text(
                      'Nombre total d\'utilisateurs: ${_userAnalytics!.total}',
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
                      children: _userAnalytics!.byStatus.entries.map((entry) {
                        return Chip(
                          label: Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: PartnerAdminStyles.infoColor,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Graphique des nouveaux utilisateurs par mois
            if (_userAnalytics!.newUsersByMonth.isNotEmpty)
              AdminBarChartWidget(
                title: 'Nouveaux Utilisateurs par Mois',
                subtitle: 'Derniers 6 mois',
                data: _userAnalytics!.newUsersByMonth,
                maxY: (_userAnalytics!.newUsersByMonth.values.fold<int>(
                            0,
                            (prev, element) =>
                                prev > (element as int) ? prev : element) *
                        1.2)
                    .toDouble(),
                gradientColors: const [
                  PartnerAdminStyles.infoColor,
                  Color(0xFF7FC8F8),
                ],
              ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Distribution des utilisateurs par statut
            if (_userAnalytics!.byStatus.isNotEmpty)
              AdminPieChartWidget(
                title: 'Distribution des Utilisateurs par Statut',
                subtitle: 'Répartition des utilisateurs selon leur statut',
                data: _userAnalytics!.byStatus,
                colors: const [
                  PartnerAdminStyles.infoColor,
                  PartnerAdminStyles.warningColor,
                  PartnerAdminStyles.successColor,
                  PartnerAdminStyles.errorColor,
                  PartnerAdminStyles.accentColor,
                ],
              ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),
          ],
        ),
      ),
    );
  }
}
