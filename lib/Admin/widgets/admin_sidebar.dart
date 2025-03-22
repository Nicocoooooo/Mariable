import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../../routes_partner_admin.dart';
import '../../shared/constants/style_constants.dart';

class AdminSidebar extends StatelessWidget {
  final int currentIndex;
  final String adminName;
  final String adminEmail;

  const AdminSidebar({
    Key? key,
    required this.currentIndex,
    required this.adminName,
    required this.adminEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 2,
      child: Column(
        children: [
          // En-tête avec les informations de l'admin
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            color: PartnerAdminStyles.accentColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  backgroundColor: PartnerAdminStyles.accentColor,
                  radius: 30,
                  child: Text(
                    adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  adminName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  adminEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PartnerAdminStyles.textColor.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard,
                  title: 'Tableau de bord',
                  route: PartnerAdminRoutes.adminDashboard,
                ),
                _buildMenuItem(
                  context,
                  index: 1,
                  icon: Icons.business,
                  title: 'Prestataires',
                  route: PartnerAdminRoutes.adminPartnersList,
                ),
                _buildMenuItem(
                  context,
                  index: 2,
                  icon: Icons.verified_user,
                  title: 'Validations',
                  route: '/admin/validations', // À ajouter dans routes
                ),
                _buildMenuItem(
                  context,
                  index: 3,
                  icon: Icons.analytics,
                  title: 'Statistiques',
                  route: PartnerAdminRoutes.adminStats,
                ),
                _buildMenuItem(
                  context,
                  index: 4,
                  icon: Icons.settings,
                  title: 'Paramètres',
                  route: '/admin/settings', // À ajouter dans routes
                ),
              ],
            ),
          ),
          // Bouton déconnexion
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PartnerAdminStyles.accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final bool isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? PartnerAdminStyles.accentColor
            : PartnerAdminStyles.textColor.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? PartnerAdminStyles.accentColor
              : PartnerAdminStyles.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selectedTileColor: PartnerAdminStyles.accentColor.withOpacity(0.1),
      selected: isSelected,
      onTap: () {
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    // ignore: use_build_context_synchronously
    context.go(PartnerAdminRoutes.adminLogin);
  }
}
