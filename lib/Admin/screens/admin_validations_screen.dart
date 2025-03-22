import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/partner_card.dart';
import '../../Partner/models/partner_model.dart';
import '../../shared/constants/style_constants.dart';
import '../../routes_partner_admin.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';

class AdminValidationsScreen extends StatefulWidget {
  const AdminValidationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminValidationsScreen> createState() => _AdminValidationsScreenState();
}

class _AdminValidationsScreenState extends State<AdminValidationsScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<PartnerModel> _unverifiedPartners = [];
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadUnverifiedPartners();
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

  Future<void> _loadUnverifiedPartners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final partners = await _adminService.getUnverifiedPartners();
      setState(() {
        _unverifiedPartners = partners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des prestataires: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPartner(PartnerModel partner) async {
    final success = await _adminService.updatePartnerVerificationStatus(
      partner.id,
      true,
    );

    if (success) {
      setState(() {
        _unverifiedPartners.removeWhere((p) => p.id == partner.id);
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prestataire vérifié avec succès'),
          backgroundColor: PartnerAdminStyles.successColor,
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la vérification du prestataire'),
          backgroundColor: PartnerAdminStyles.errorColor,
        ),
      );
    }
  }

  Future<void> _toggleActiveStatus(PartnerModel partner) async {
    final newStatus = !partner.actif;
    final success = await _adminService.updatePartnerActiveStatus(
      partner.id,
      newStatus,
    );

    if (success) {
      final index = _unverifiedPartners.indexWhere((p) => p.id == partner.id);
      if (index != -1) {
        setState(() {
          _unverifiedPartners[index] =
              _unverifiedPartners[index].copyWith(actif: newStatus);
        });
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Erreur lors de la mise à jour du statut d\'activation'),
          backgroundColor: PartnerAdminStyles.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation des prestataires'),
        backgroundColor: PartnerAdminStyles.accentColor,
        foregroundColor: Colors.white,
      ),
      drawer: AdminSidebar(
        currentIndex: 2, // 2 pour Validations
        adminName: _adminName,
        adminEmail: _adminEmail,
      ),
      body: _isLoading
          ? const LoadingIndicator(
              message: 'Chargement des prestataires en attente...')
          : _errorMessage.isNotEmpty
              ? ErrorView(
                  message: _errorMessage,
                  onAction: _loadUnverifiedPartners,
                  actionLabel: 'Réessayer',
                )
              : _buildValidationsContent(),
    );
  }

  Widget _buildValidationsContent() {
    return RefreshIndicator(
      onRefresh: _loadUnverifiedPartners,
      child: _unverifiedPartners.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: PartnerAdminStyles.accentColor,
                  ),
                  const SizedBox(height: PartnerAdminStyles.paddingMedium),
                  Text(
                    'Aucun prestataire en attente de validation',
                    style: TextStyle(
                      fontSize: 16,
                      color: PartnerAdminStyles.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: PartnerAdminStyles.paddingMedium),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(PartnerAdminRoutes.adminPartnersList);
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Voir tous les prestataires'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PartnerAdminStyles.accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
              itemCount: _unverifiedPartners.length,
              itemBuilder: (context, index) {
                final partner = _unverifiedPartners[index];
                return PartnerCard(
                  partner: partner,
                  onVerifyToggle: () => _verifyPartner(partner),
                  onActiveToggle: () => _toggleActiveStatus(partner),
                );
              },
            ),
    );
  }
}
