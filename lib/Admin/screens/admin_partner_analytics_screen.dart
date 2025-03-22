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

class AdminPartnerAnalyticsScreen extends StatefulWidget {
  const AdminPartnerAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminPartnerAnalyticsScreen> createState() =>
      _AdminPartnerAnalyticsScreenState();
}

class _AdminPartnerAnalyticsScreenState
    extends State<AdminPartnerAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  PartnerAnalytics? _partnerAnalytics;
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
      // Données codées en dur pour les prestataires
      final Map<String, int> partnersByType = {
        'Lieux': 42,
        'Traiteurs': 38,
        'Photographes': 25,
        'DJ': 18,
        'Wedding Planners': 12,
        'Fleuristes': 15,
      };

      final Map<String, int> partnersByRegion = {
        'Paris': 58,
        'Lyon': 32,
        'Marseille': 27,
        'Bordeaux': 19,
        'Lille': 14,
      };

      final Map<String, int> partnersByBudget = {
        'abordable': 65,
        'premium': 45,
        'luxe': 40,
      };

      final Map<String, Map<String, dynamic>> verificationRateByType = {
        'Lieux': {'total': 42, 'verified': 32, 'rate': '76.2'},
        'Traiteurs': {'total': 38, 'verified': 28, 'rate': '73.7'},
        'Photographes': {'total': 25, 'verified': 17, 'rate': '68.0'},
        'DJ': {'total': 18, 'verified': 11, 'rate': '61.1'},
        'Wedding Planners': {'total': 12, 'verified': 9, 'rate': '75.0'},
        'Fleuristes': {'total': 15, 'verified': 10, 'rate': '66.7'},
      };

      final fakeAnalytics = {
        'total': partnersByType.values.fold(0, (a, b) => a + b),
        'byType': partnersByType,
        'byRegion': partnersByRegion,
        'byBudget': partnersByBudget,
        'verificationRateByType': verificationRateByType,
      };

      setState(() {
        _partnerAnalytics = PartnerAnalytics.fromMap(fakeAnalytics);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erreur lors du chargement des statistiques prestataires: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse des Prestataires'),
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
              message: 'Chargement des statistiques prestataires...')
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
    if (_partnerAnalytics == null) {
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
                'Analyse des Prestataires',
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
                'Statistiques détaillées sur les prestataires de la plateforme',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: PartnerAdminStyles.textColor.withOpacity(0.7),
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
                            Icons.business,
                            color: PartnerAdminStyles.accentColor,
                            size: 24,
                          ),
                          const SizedBox(
                              width: PartnerAdminStyles.paddingSmall),
                          Text(
                            'Résumé des Prestataires',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingMedium),
                      Text(
                        'Nombre total de prestataires: ${_partnerAnalytics!.total}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: PartnerAdminStyles.paddingSmall),
                      Row(
                        children: [
                          _buildSummaryCard(
                            title: 'Types',
                            value: _partnerAnalytics!.byType.length.toString(),
                            icon: Icons.category,
                            color: PartnerAdminStyles.accentColor,
                          ),
                          const SizedBox(
                              width: PartnerAdminStyles.paddingSmall),
                          _buildSummaryCard(
                            title: 'Régions',
                            value:
                                _partnerAnalytics!.byRegion.length.toString(),
                            icon: Icons.location_on,
                            color: PartnerAdminStyles.infoColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Distribution des prestataires par type
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: AdminPieChartWidget(
                title: 'Distribution des Prestataires par Type',
                subtitle: 'Répartition selon les catégories de service',
                data: _partnerAnalytics!.byType,
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Distribution des prestataires par région
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: AdminBarChartWidget(
                title: 'Prestataires par Région',
                subtitle: 'Nombre de prestataires dans chaque région',
                data: _partnerAnalytics!.byRegion,
                maxY: 70,
                gradientColors: const [
                  PartnerAdminStyles.infoColor,
                  Color(0xFF7FC8F8),
                ],
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Distribution par budget
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: AdminPieChartWidget(
                title: 'Distribution par Budget',
                subtitle:
                    'Répartition des prestataires selon leur niveau de prix',
                data: _partnerAnalytics!.byBudget,
                colors: const [
                  PartnerAdminStyles.successColor,
                  PartnerAdminStyles.warningColor,
                  PartnerAdminStyles.errorColor,
                ],
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Taux de vérification par type de prestataire
            SlideTransition(
              position: _animationController.drive(Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut))),
              child: _buildVerificationRatesCard(),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(PartnerAdminStyles.borderRadiusMedium),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRatesCard() {
    return Card(
      elevation: PartnerAdminStyles.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Taux de Vérification par Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pourcentage de prestataires vérifiés dans chaque catégorie',
              style: TextStyle(
                fontSize: 14,
                color: PartnerAdminStyles.textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _partnerAnalytics!.verificationRateByType.length,
              itemBuilder: (context, index) {
                final entry = _partnerAnalytics!.verificationRateByType.entries
                    .elementAt(index);
                final type = entry.key;
                final data = entry.value;
                final total = data['total'] as int;
                final verified = data['verified'] as int;
                final rate = double.parse(data['rate'].toString());

                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: PartnerAdminStyles.paddingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            type,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$verified/$total (${rate.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: PartnerAdminStyles.accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: rate / 100,
                        backgroundColor:
                            PartnerAdminStyles.accentColor.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            PartnerAdminStyles.accentColor),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
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
