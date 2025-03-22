import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({Key? key}) : super(key: key);

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _statsData = {};
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadStats();
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

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final stats = await _adminService.getGlobalStats();
      setState(() {
        _statsData = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des statistiques: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: PartnerAdminStyles.accentColor,
        foregroundColor: Colors.white,
      ),
      drawer: AdminSidebar(
        currentIndex: 3, // 3 pour Statistiques
        adminName: _adminName,
        adminEmail: _adminEmail,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des statistiques...')
          : _errorMessage.isNotEmpty
              ? ErrorView(
                  message: _errorMessage,
                  onAction: _loadStats,
                  actionLabel: 'Réessayer',
                )
              : _buildStatsContent(),
    );
  }

  Widget _buildStatsContent() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Text(
              'Statistiques Globales',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PartnerAdminStyles.textColor,
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingSmall),
            Text(
              'Vue d\'ensemble des statistiques de la plateforme',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PartnerAdminStyles.textColor.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Statistiques des prestataires
            _buildStatSection(
              title: 'Prestataires',
              icon: Icons.business,
              color: PartnerAdminStyles.accentColor,
              child: _buildStatCards([
                {
                  'title': 'Total',
                  'value': _statsData['totalPrestataires'].toString(),
                  'icon': Icons.people_alt,
                  'color': PartnerAdminStyles.accentColor,
                },
                {
                  'title': 'Vérifiés',
                  'value': _statsData['prestatairesVerifies'].toString(),
                  'icon': Icons.verified,
                  'color': PartnerAdminStyles.successColor,
                },
                {
                  'title': 'Taux de vérification',
                  'value': _statsData['totalPrestataires'] > 0
                      ? '${(_statsData['prestatairesVerifies'] / _statsData['totalPrestataires'] * 100).toStringAsFixed(1)}%'
                      : '0%',
                  'icon': Icons.percent,
                  'color': PartnerAdminStyles.infoColor,
                },
              ]),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Statistiques des utilisateurs
            _buildStatSection(
              title: 'Utilisateurs',
              icon: Icons.people,
              color: PartnerAdminStyles.infoColor,
              child: _buildStatCards([
                {
                  'title': 'Total',
                  'value': _statsData['totalUtilisateurs'].toString(),
                  'icon': Icons.people_alt,
                  'color': PartnerAdminStyles.infoColor,
                },
              ]),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Statistiques des réservations
            _buildStatSection(
              title: 'Réservations',
              icon: Icons.calendar_today,
              color: PartnerAdminStyles.warningColor,
              child: _buildStatCards([
                {
                  'title': 'Total',
                  'value': _statsData['totalReservations'].toString(),
                  'icon': Icons.calendar_today,
                  'color': PartnerAdminStyles.warningColor,
                },
                {
                  'title': 'Réservations par prestataire',
                  'value': _statsData['totalPrestataires'] > 0
                      ? (_statsData['totalReservations'] /
                              _statsData['totalPrestataires'])
                          .toStringAsFixed(1)
                      : '0',
                  'icon': Icons.business_center,
                  'color': PartnerAdminStyles.accentColor,
                },
              ]),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Rapport de plateforme (carte plus grande)
            Card(
              elevation: PartnerAdminStyles.elevationMedium,
              child: Padding(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rapport de Plateforme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingSmall),
                    _buildRapportItem(
                      title: 'Prestataires vérifiés',
                      value: _statsData['prestatairesVerifies'],
                      total: _statsData['totalPrestataires'],
                      color: PartnerAdminStyles.successColor,
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingSmall),
                    _buildRapportItem(
                      title: 'Réservations par prestataire',
                      value: _statsData['totalReservations'],
                      divisor: _statsData['totalPrestataires'],
                      suffix: '',
                      color: PartnerAdminStyles.warningColor,
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingSmall),
                    _buildRapportItem(
                      title: 'Réservations par utilisateur',
                      value: _statsData['totalReservations'],
                      divisor: _statsData['totalUtilisateurs'],
                      suffix: '',
                      color: PartnerAdminStyles.infoColor,
                    ),
                  ],
                ),
              ),
            ),
            // Ajouter un espace supplémentaire en bas pour éviter tout problème
            const SizedBox(height: PartnerAdminStyles.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: PartnerAdminStyles.paddingMedium),
        child,
      ],
    );
  }

  Widget _buildStatCards(List<Map<String, dynamic>> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12, // Réduit pour éviter overflow
        mainAxisSpacing: 12, // Réduit pour éviter overflow
        childAspectRatio: 1.7, // Augmenté pour réduire la hauteur des cartes
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: PartnerAdminStyles.elevationSmall,
          child: Padding(
            padding:
                const EdgeInsets.all(PartnerAdminStyles.paddingSmall), // Réduit
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stat['icon'] as IconData,
                  color: stat['color'] as Color,
                  size: 22, // Légèrement plus petit
                ),
                const SizedBox(height: 6), // Réduit
                Text(
                  stat['value'] as String,
                  style: const TextStyle(
                    fontSize: 20, // Légèrement plus petit
                    fontWeight: FontWeight.bold,
                    color: PartnerAdminStyles.textColor,
                  ),
                  overflow: TextOverflow.ellipsis, // Évite les débordements
                ),
                Text(
                  stat['title'] as String,
                  style: TextStyle(
                    fontSize: 13, // Plus petit
                    color: PartnerAdminStyles.textColor.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis, // Évite les débordements
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRapportItem({
    required String title,
    required int value,
    int? total,
    int? divisor,
    String suffix = '%',
    required Color color,
  }) {
    // Calcul de la valeur à afficher
    String displayValue;
    double percentage = 0;

    if (total != null && total > 0) {
      percentage = value / total * 100;
      displayValue = '${percentage.toStringAsFixed(1)}$suffix';
    } else if (divisor != null && divisor > 0) {
      double ratio = value / divisor;
      percentage = ratio * 100; // Pour la barre de progression
      displayValue = ratio.toStringAsFixed(1);
    } else {
      displayValue = '0$suffix';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis, // Évite les débordements
              ),
            ),
            const SizedBox(width: 4),
            Text(
              displayValue,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2), // Réduit
        LinearProgressIndicator(
          value: (percentage / 100)
              .clamp(0.0, 1.0), // Assurer que la valeur est entre 0 et 1
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6, // Légèrement plus petite
        ),
      ],
    );
  }
}
