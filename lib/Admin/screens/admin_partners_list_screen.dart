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

class AdminPartnersListScreen extends StatefulWidget {
  const AdminPartnersListScreen({super.key});

  @override
  State<AdminPartnersListScreen> createState() =>
      _AdminPartnersListScreenState();
}

class _AdminPartnersListScreenState extends State<AdminPartnersListScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<PartnerModel> _partners = [];
  List<PartnerModel> _filteredPartners = [];
  String _searchQuery = '';
  String _filterStatus =
      'Tous'; // 'Tous', 'Vérifiés', 'Non vérifiés', 'Actifs', 'Inactifs'
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadPartners();
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

  Future<void> _loadPartners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final partners = await _adminService.getAllPartners();
      setState(() {
        _partners = partners;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des prestataires: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<PartnerModel> filtered = List.from(_partners);

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((partner) =>
              partner.nomEntreprise
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              partner.nomContact
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              partner.region.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filtrer par statut
    switch (_filterStatus) {
      case 'Vérifiés':
        filtered = filtered.where((partner) => partner.isVerified).toList();
        break;
      case 'Non vérifiés':
        filtered = filtered.where((partner) => !partner.isVerified).toList();
        break;
      case 'Actifs':
        filtered = filtered.where((partner) => partner.actif).toList();
        break;
      case 'Inactifs':
        filtered = filtered.where((partner) => !partner.actif).toList();
        break;
    }

    setState(() {
      _filteredPartners = filtered;
    });
  }

  Future<void> _toggleVerificationStatus(PartnerModel partner) async {
    final newStatus = !partner.isVerified;
    final success = await _adminService.updatePartnerVerificationStatus(
      partner.id,
      newStatus,
    );

    if (success) {
      final index = _partners.indexWhere((p) => p.id == partner.id);
      if (index != -1) {
        setState(() {
          _partners[index] = _partners[index].copyWith(isVerified: newStatus);
          _applyFilters();
        });
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Erreur lors de la mise à jour du statut de vérification'),
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
      final index = _partners.indexWhere((p) => p.id == partner.id);
      if (index != -1) {
        setState(() {
          _partners[index] = _partners[index].copyWith(actif: newStatus);
          _applyFilters();
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
        title: const Text('Gestion des prestataires'),
        backgroundColor: PartnerAdminStyles.accentColor,
        foregroundColor: Colors.white,
      ),
      drawer: AdminSidebar(
        currentIndex: 1, // 1 pour Prestataires
        adminName: _adminName,
        adminEmail: _adminEmail,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des prestataires...')
          : _errorMessage.isNotEmpty
              ? ErrorView(
                  message: _errorMessage,
                  onAction: _loadPartners,
                  actionLabel: 'Réessayer',
                )
              : _buildPartnersListContent(),
    );
  }

  Widget _buildPartnersListContent() {
    return RefreshIndicator(
      onRefresh: _loadPartners,
      child: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilterBar(),

          // Liste des prestataires
          Expanded(
            child: _filteredPartners.isEmpty
                ? Center(
                    child: Text(
                      'Aucun prestataire trouvé',
                      style: TextStyle(
                        color: PartnerAdminStyles.textColor.withAlpha(179), 
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
                    itemCount: _filteredPartners.length,
                    itemBuilder: (context, index) {
                      final partner = _filteredPartners[index];
                      return PartnerCard(
                        partner: partner,
                        onVerifyToggle: () =>
                            _toggleVerificationStatus(partner),
                        onActiveToggle: () => _toggleActiveStatus(partner),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un prestataire...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    PartnerAdminStyles.borderRadiusMedium),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: PartnerAdminStyles.paddingMedium),

          // Filtres de statut
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous'),
                _buildFilterChip('Vérifiés'),
                _buildFilterChip('Non vérifiés'),
                _buildFilterChip('Actifs'),
                _buildFilterChip('Inactifs'),
              ],
            ),
          ),

          // Infos sur le nombre de résultats
          Padding(
            padding:
                const EdgeInsets.only(top: PartnerAdminStyles.paddingSmall),
            child: Text(
              '${_filteredPartners.length} prestataires trouvés',
              style: TextStyle(
                color: PartnerAdminStyles.textColor.withAlpha(179),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: PartnerAdminStyles.paddingSmall),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = selected ? label : 'Tous';
            _applyFilters();
          });
        },
        selectedColor: PartnerAdminStyles.accentColor.withAlpha(51),
        labelStyle: TextStyle(
          color: isSelected
              ? PartnerAdminStyles.accentColor
              : PartnerAdminStyles.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
