import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports et Analyses'),
        backgroundColor: PartnerAdminStyles.accentColor,
        foregroundColor: Colors.white,
      ),
      drawer: AdminSidebar(
        currentIndex: 3, // 3 pour Statistiques
        adminName: _adminName,
        adminEmail: _adminEmail,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Text(
              'Rapports et Analyses',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PartnerAdminStyles.textColor,
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingSmall),
            Text(
              'Accédez aux analyses détaillées de la plateforme',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PartnerAdminStyles.textColor.withAlpha(179),
                  ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Cartes des rapports disponibles
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600
                  ? 2
                  : 1, // Responsive: 1 colonne sur petit écran
              childAspectRatio:
                  1.3, // Augmenter l'aspect ratio pour donner plus d'espace
              crossAxisSpacing: 12, // Réduire l'espacement
              mainAxisSpacing: 12, // Réduire l'espacement
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildReportCard(
                  title: 'Analyse des Utilisateurs',
                  description: 'Statistiques et tendances sur les utilisateurs',
                  icon: Icons.people,
                  color: PartnerAdminStyles.infoColor,
                  onTap: () => context.go('/admin/analytics/users'),
                ),
                _buildReportCard(
                  title: 'Analyse des Prestataires',
                  description:
                      'Statistiques sur les prestataires par catégorie et région',
                  icon: Icons.business,
                  color: PartnerAdminStyles.accentColor,
                  onTap: () => context.go('/admin/analytics/partners'),
                ),
                _buildReportCard(
                  title: 'Analyse des Réservations',
                  description: 'Tendances et revenus des réservations',
                  icon: Icons.calendar_today,
                  color: PartnerAdminStyles.warningColor,
                  onTap: () => context.go('/admin/analytics/reservations'),
                ),
                _buildReportCard(
                  title: 'Statistiques Globales',
                  description: 'Vue d\'ensemble de la plateforme',
                  icon: Icons.analytics,
                  color: PartnerAdminStyles.successColor,
                  onTap: () => context.go(PartnerAdminRoutes.adminStats),
                ),
              ],
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),

            // Exportation de données
            Card(
              elevation: PartnerAdminStyles.elevationMedium,
              child: Padding(
                padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exportation des Données',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: PartnerAdminStyles.textColor,
                      ),
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingSmall),
                    Text(
                      'Exportez les données pour une analyse plus approfondie',
                      style: TextStyle(
                        fontSize: 14,
                        color: PartnerAdminStyles.textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Fonction d'exportation à implémenter
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Export des utilisateurs en cours...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people),
                            label: const Text('Utilisateurs'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: PartnerAdminStyles.infoColor,
                              side: const BorderSide(
                                  color: PartnerAdminStyles.infoColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: PartnerAdminStyles.paddingSmall),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Fonction d'exportation à implémenter
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Export des prestataires en cours...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.business),
                            label: const Text('Prestataires'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: PartnerAdminStyles.accentColor,
                              side: const BorderSide(
                                  color: PartnerAdminStyles.accentColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PartnerAdminStyles.paddingSmall),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Fonction d'exportation à implémenter
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Export des réservations en cours...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Réservations'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: PartnerAdminStyles.warningColor,
                              side: const BorderSide(
                                  color: PartnerAdminStyles.warningColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: PartnerAdminStyles.paddingSmall),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Fonction d'exportation à implémenter
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Export complet en cours...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Tout'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: PartnerAdminStyles.successColor,
                              side: const BorderSide(
                                  color: PartnerAdminStyles.successColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PartnerAdminStyles.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: PartnerAdminStyles.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(PartnerAdminStyles.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(PartnerAdminStyles.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PartnerAdminStyles.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: PartnerAdminStyles.textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
