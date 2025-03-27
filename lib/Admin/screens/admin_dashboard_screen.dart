import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/stats_card.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
        title: const Text('Tableau de bord administrateur'),
        backgroundColor: PartnerAdminStyles.accentColor,
        foregroundColor: Colors.white,
      ),
      drawer: AdminSidebar(
        currentIndex: 0, // 0 pour Tableau de bord
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
              : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
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
              'Bienvenue, $_adminName',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PartnerAdminStyles.textColor,
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingSmall),
            Text(
              'Voici une vue d\'ensemble de la plateforme Mariable',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PartnerAdminStyles.textColor.withAlpha(179),
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Cartes de statistiques
            const Text(
              'Statistiques globales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AdminStatsCard(
                  title: 'Prestataires',
                  value: _statsData['totalPrestataires'].toString(),
                  icon: Icons.business,
                  color: PartnerAdminStyles.accentColor,
                  onTap: () => context.go(PartnerAdminRoutes.adminPartnersList),
                ),
                AdminStatsCard(
                  title: 'Prestataires vérifiés',
                  value: _statsData['prestatairesVerifies'].toString(),
                  icon: Icons.verified,
                  color: PartnerAdminStyles.successColor,
                  onTap: () => context.go('/admin/validations'),
                ),
                AdminStatsCard(
                  title: 'Utilisateurs',
                  value: _statsData['totalUtilisateurs'].toString(),
                  icon: Icons.people,
                  color: PartnerAdminStyles.infoColor,
                ),
                AdminStatsCard(
                  title: 'Réservations',
                  value: _statsData['totalReservations'].toString(),
                  icon: Icons.calendar_today,
                  color: PartnerAdminStyles.warningColor,
                ),
              ],
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Section des actions rapides
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            Card(
              elevation: PartnerAdminStyles.elevationSmall,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    PartnerAdminStyles.borderRadiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                child: Column(
                  children: [
                    _buildQuickActionButton(
                      context,
                      icon: Icons.verified_user,
                      title: 'Valider les prestataires en attente',
                      description:
                          'Vérifier et approuver les nouveaux prestataires',
                      onTap: () => context.go('/admin/validations'),
                    ),
                    const Divider(),
                    _buildQuickActionButton(
                      context,
                      icon: Icons.add_business,
                      title: 'Ajouter un nouveau prestataire',
                      description: 'Créer un nouvel espace prestataire',
                      onTap: () => context.go(
                          '${PartnerAdminRoutes.adminPartnerEdit.replaceAll(':id', '')}new'),
                    ),
                    const Divider(),
                    _buildQuickActionButton(
                      context,
                      icon: Icons.person_add,
                      title: 'Ajouter un nouvel administrateur',
                      description: 'Créer un compte administrateur',
                      onTap: () => context.go(PartnerAdminRoutes.adminAddNew),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingSmall),
        decoration: BoxDecoration(
          color: PartnerAdminStyles.accentColor.withAlpha(26),
          borderRadius:
              BorderRadius.circular(PartnerAdminStyles.borderRadiusSmall),
        ),
        child: Icon(
          icon,
          color: PartnerAdminStyles.accentColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
