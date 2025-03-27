import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/services/auth_service.dart';
import '../../utils/logger.dart';
import '../models/partner_model.dart';
import '../widgets/partner_sidebar.dart';
import '../widgets/stats_card.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  final AuthService _authService = AuthService();
  PartnerModel? _partner;
  bool _isLoading = true;
  String? _errorMessage;

  // Statistiques fictives
  int _totalViews = 0;
  int _totalMessages = 0;
  int _totalReservations = 0;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPartnerData();
  }

  Future<void> _loadPartnerData() async {
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

      // Récupérer les statistiques (ici des données fictives)
      await _loadStats();

      setState(() {
        _partner = PartnerModel.fromMap(response);
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des données du partenaire', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger vos données. Veuillez réessayer.';
      });
    }
  }

  Future<void> _loadStats() async {
    // Dans une vraie application, ces données viendraient de Supabase
    // Ici nous utilisons des données fictives pour la démonstration

    try {
      // Simuler un délai de chargement
      await Future.delayed(const Duration(milliseconds: 800));

      // Données fictives
      setState(() {
        _totalViews = 1256;
        _totalMessages = 18;
        _totalReservations = 8;
        _averageRating = 4.7;
      });
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des statistiques', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tableau de bord',
      ),
      drawer: PartnerSidebar(
        selectedIndex: 0,
        partner: _partner,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des données...')
          : _errorMessage != null
              ? ErrorView(
                  message: _errorMessage!,
                  actionLabel: 'Réessayer',
                  onAction: _loadPartnerData,
                )
              : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message de bienvenue
          Text(
            'Bienvenue, ${_partner?.nomEntreprise ?? 'Partenaire'}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: PartnerAdminStyles.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voici un aperçu de votre activité',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Cartes de statistiques
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatsCard(
                title: 'Vues du profil',
                value: _totalViews.toString(),
                icon: Icons.visibility,
                color: Colors.blue,
                subtitle: 'Ce mois-ci',
              ),
              StatsCard(
                title: 'Note moyenne',
                value: _averageRating.toString(),
                icon: Icons.star,
                color: Colors.amber,
                subtitle: 'Sur 5 étoiles',
              ),
              StatsCard(
                title: 'Messages',
                value: _totalMessages.toString(),
                icon: Icons.message,
                color: Colors.green,
                subtitle: 'Non lus',
                onTap: () => context.push('/partner/messages'),
              ),
              StatsCard(
                title: 'Réservations',
                value: _totalReservations.toString(),
                icon: Icons.event,
                color: Colors.purple,
                subtitle: 'En attente',
                onTap: () => context.push('/partner/reservations'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Section alertes
          const Text(
            'Alertes et notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: PartnerAdminStyles.accentColor,
            ),
          ),
          const SizedBox(height: 16),

          _buildAlertCard(
            title: 'Complétez votre profil',
            message:
                'Ajoutez des photos et détails pour augmenter votre visibilité',
            icon: Icons.account_circle,
            color: Colors.orange,
            actionText: 'Compléter',
            onAction: () => context.push('/partner/profile'),
          ),

          const SizedBox(height: 12),

          _buildAlertCard(
            title: 'Nouveaux messages',
            message: 'Vous avez des messages non lus de clients potentiels',
            icon: Icons.mail,
            color: Colors.blue,
            actionText: 'Voir',
            onAction: () => context.push('/partner/messages'),
          ),

          const SizedBox(height: 32),

          // Section actions rapides
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: PartnerAdminStyles.accentColor,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildQuickActionButton(
                icon: Icons.add_circle,
                label: 'Ajouter une offre',
                onTap: () => context.push('/partner/offers/add'),
              ),
              const SizedBox(width: 16),
              _buildQuickActionButton(
                icon: Icons.upload_file,
                label: 'Télécharger un document',
                onTap: () => context.push('/partner/documents'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: PartnerAdminStyles.beige.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: PartnerAdminStyles.beige,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: PartnerAdminStyles.accentColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: PartnerAdminStyles.accentColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
