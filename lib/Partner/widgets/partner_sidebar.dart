import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/services/auth_service.dart';
import '../models/partner_model.dart';

class PartnerSidebar extends StatelessWidget {
  final int selectedIndex;
  final PartnerModel? partner;

  const PartnerSidebar({
    Key? key,
    required this.selectedIndex,
    this.partner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // En-tête du profil
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: PartnerAdminStyles.accentColor,
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.business,
                size: 40,
                color: PartnerAdminStyles.accentColor,
              ),
            ),
            accountName: Text(
              partner?.nomEntreprise ?? 'Entreprise',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              partner?.email ?? 'exemple@email.com',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),

          // Éléments de menu
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            title: 'Tableau de bord',
            index: 0,
            route: '/partner/dashboard',
          ),
          _buildMenuItem(
            context,
            icon: Icons.visibility,
            title: 'Mes offres',
            index: 1,
            route: '/partner/offers',
          ),
          _buildMenuItem(
            context,
            icon: Icons.event,
            title: 'Réservations',
            index: 2,
            route: '/partner/reservations',
          ),
          _buildMenuItem(
            context,
            icon: Icons.message,
            title: 'Messages',
            index: 3,
            route: '/partner/messages',
          ),
          _buildMenuItem(
            context,
            icon: Icons.description,
            title: 'Documents',
            index: 4,
            route: '/partner/documents',
          ),
          _buildMenuItem(
            context,
            icon: Icons.analytics,
            title: 'Statistiques',
            index: 5,
            route: '/partner/stats',
          ),
          _buildMenuItem(
            context,
            icon: Icons.account_circle,
            title: 'Mon profil',
            index: 6,
            route: '/partner/profile',
          ),

          const Divider(),

          // Bouton de déconnexion
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) {
                context.go('/partner/login');
              }
            },
          ),

          const Spacer(),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              '© 2025 Mariable',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required String route,
  }) {
    final bool isSelected = selectedIndex == index;
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
      selected: isSelected,
      onTap: () {
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }
}
