import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Filtre/prestataires_filter_screen.dart';  // Ajout de l'import pour la page des prestataires
import '../Filtre/data/models/presta_type_model.dart';
import '../Filtre/PrestatairesListScreen.dart';
import '../services/region_service.dart';
import '../routes_partner_admin.dart';
import '../Widgets/lieu_selector_dialog.dart';
import '../Prestataires/PrestatairesScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables pour stocker les sélections
  String _prestaireText = 'Prestataire';
  Map<String, dynamic>? _selectedPrestaType;
  Map<String, dynamic>? _selectedSubType;
  String _lieuText = 'Lieu';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la DA
    const Color grisTexte = Color(0xFF2B2B2B);
    const Color accentColor = Color(0xFF524B46);
    const Color beige = Color(0xFFFFF3E4);

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond au lieu de la vidéo
          SizedBox.expand(
            child: Image.network(
              'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: beige.withAlpha(128),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: accentColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: beige.withOpacity(0.5),
                );
              },
            ),
          ),

          // Overlay pour lisibilité du texte
          Container(
            color: Colors.black.withOpacity(0.2),
          ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Textes principaux
                Text(
                  'Le grand jour approche...',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Color.fromARGB(100, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'À quoi ressemble le mariage de vos rêves ?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Color.fromARGB(100, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Carte de recherche
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Champ Prestataire (avec action pour ouvrir le modal)
                      InkWell(
                        onTap: () => _showPrestatairesFilter(context),
                        child: _buildSearchField(
                          icon: Icons.business,
                          hint: _prestaireText,
                          grisTexte: grisTexte,
                          isSelected: _prestaireText != 'Prestataire',
                        ),
                      ),

                      const Divider(height: 1, thickness: 1),

                      // Champ Lieu
                      InkWell(
                        onTap: () => _showLieuSelector(context),
                        child: _buildSearchField(
                          icon: Icons.place,
                          hint: _lieuText,
                          grisTexte: grisTexte,
                          isSelected: _lieuText != 'Lieu',
                        ),
                      ),

                      const Divider(height: 1, thickness: 1),

                      // Champs Date double
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectDate(context, isStartDate: true),
                              child: _buildSearchField(
                                icon: Icons.calendar_today,
                                hint: _startDate != null
                                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                    : 'Date',
                                grisTexte: grisTexte,
                                isSelected: _startDate != null,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: grisTexte.withOpacity(0.5),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectDate(context, isStartDate: false),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                child: Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Date',
                                  style: TextStyle(
                                    color: _endDate != null
                                        ? grisTexte
                                        : grisTexte.withOpacity(0.5),
                                    fontSize: 14,
                                    fontWeight: _endDate != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bouton Rechercher
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: TextButton(
                          onPressed: _search,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Rechercher',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Pousse la barre de navigation vers le bas
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(grisTexte, accentColor),
    );
  }

  void _search() {
    // Vérifier qu'au moins un critère est rempli
    if (_selectedPrestaType == null &&
        _selectedSubType == null &&
        _lieuText == 'Lieu' &&
        _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veuillez sélectionner au moins un critère de recherche'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Si un sous-type est sélectionné, naviguer vers la liste des prestataires de ce sous-type
    if (_selectedSubType != null) {
      print('Navigation avec sous-type: ${_selectedSubType!['name']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrestatairesListScreen(
            prestaType: PrestaTypeModel.fromMap(_selectedPrestaType!),
            subType: _selectedSubType,
            location: _lieuText != 'Lieu' ? _lieuText : null,
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    }
    // Si seulement un type de prestataire est sélectionné
    else if (_selectedPrestaType != null) {
      print('Navigation avec type principal: ${_selectedPrestaType!['name']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrestatairesListScreen(
            prestaType: PrestaTypeModel.fromMap(_selectedPrestaType!),
            location: _lieuText != 'Lieu' ? _lieuText : null,
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    }
    // Si seul le lieu est renseigné
    else if (_lieuText != 'Lieu') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recherche par lieu : $_lieuText'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Ici vous pourriez naviguer vers une liste de tous les prestataires filtrés par lieu
    }
    // Si seules les dates sont renseignées
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recherche par date'),
          duration: Duration(seconds: 2),
        ),
      );
      // Ici vous pourriez naviguer vers une liste de tous les prestataires disponibles à ces dates
    }
  }

  // Fonction pour sélectionner un lieu

  Future<void> _showLieuSelector(BuildContext context) async {
    final regionService = RegionService();
    List<String> regions = [];
    bool isLoading = true;

    // Récupérer les régions avant d'afficher le modal
    try {
      regions = await regionService.getAllRegions();
    } catch (e) {
      print('Erreur: $e');
      // Utiliser des valeurs par défaut en cas d'erreur
      regions = ['Paris', 'Lyon', 'Marseille', 'Bordeaux', 'Strasbourg'];
    } finally {
      isLoading = false;
    }

    showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Sélectionnez un lieu'),
            backgroundColor: const Color(0xFFFFF3E4),
            content: SizedBox(
              width: double.maxFinite,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: regions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(regions[index]),
                          onTap: () => Navigator.pop(context, regions[index]),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          _lieuText = result;
        });
      }
    });
  }

// Modification de la fonction _selectDate dans lib/Home/HomeScreen.dart
  Future<void> _selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final DateTime now = DateTime.now();

    // Définir la bonne date initiale pour chaque cas
    DateTime initialDate;
    if (isStartDate) {
      initialDate = _startDate ?? now;
    } else {
      // Pour la date de fin, utiliser la date de début + 1 jour ou aujourd'hui + 1 jour
      initialDate = _endDate ??
          (_startDate != null
              ? _startDate!.add(const Duration(days: 1))
              : now.add(const Duration(days: 1)));
    }

    // Assurer que la date initiale est dans la plage valide
    if (initialDate.isBefore(now)) {
      initialDate = now;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      // Pour la date de début, commencer à aujourd'hui
      // Pour la date de fin, commencer à la date de début ou aujourd'hui
      firstDate: isStartDate ? now : (_startDate ?? now),
      lastDate: DateTime(now.year + 3), // Permettre jusqu'à 3 ans dans le futur

      // S'assurer qu'aucun jour n'est désactivé
      selectableDayPredicate: (DateTime date) {
        return true; // Permettre tous les jours, y compris les weekends
      },

      // Peut-être ajouter des paramètres supplémentaires pour personnaliser l'apparence
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF524B46), // Couleur accent
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF2B2B2B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Réinitialiser la date de fin si elle est antérieure à la nouvelle date de début
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Ouvre le modal des filtres prestataires
  Future<void> _showPrestatairesFilter(BuildContext context) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return const PrestatairesFilterScreen();
        },
      ),
    );

    // Traiter le résultat selon ce qui a été sélectionné
    if (result != null) {
      print("Selected result: $result"); // Ajoutez ce debug

      // Si le résultat contient à la fois un type de prestataire et un sous-type
      if (result is Map<String, dynamic> &&
          result.containsKey('prestaType') &&
          result.containsKey('subType')) {
        final prestaType = result['prestaType'];
        final subType = result['subType'];

        setState(() {
          _selectedPrestaType = prestaType;
          _selectedSubType = subType;
          // Personnaliser le texte en fonction du type
          if (prestaType['name'].toString().toLowerCase() == 'traiteur') {
            _prestaireText = '${prestaType['name']}: ${subType['name']}';
          } else {
            _prestaireText = '${prestaType['name']}: ${subType['name']}';
          }
        });
      }
      // Si le résultat est juste un type de prestataire
      else {
        setState(() {
          _selectedPrestaType = result;
          _selectedSubType = null;
          _prestaireText = result['name'];
        });
      }
    }
  }

  Widget _buildSearchField({
    required IconData icon,
    required String hint,
    required Color grisTexte,
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? grisTexte : grisTexte.withOpacity(0.6),
          ),
          const SizedBox(width: 15),
          Text(
            hint,
            style: TextStyle(
              color: isSelected ? grisTexte : grisTexte.withOpacity(0.6),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Barre de navigation
  Widget _buildBottomNavigationBar(Color grisTexte, Color accentColor) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.search, 'Prestataires', grisTexte, onTap: () {
           Navigator.push(
            context,
           MaterialPageRoute(
            builder: (context) => PrestatairesScreen(), // Utilisez le nouvel écran
           ),
          );
          }),
          _buildNavItem(Icons.favorite_border, 'Favoris', grisTexte),
          _buildNavItem(Icons.home, 'Accueil', accentColor, isSelected: true),
          _buildNavItem(Icons.shopping_bag_outlined, 'Bouquet', grisTexte),
          _buildNavItem(
            Icons.person_outline,
            'Profil',
            grisTexte,
            onTap: () => context.go(PartnerAdminRoutes.profileSelector),
          ),
        ],
      ),
    );
  }

  // Élément de la barre de navigation
  Widget _buildNavItem(IconData icon, String label, Color color, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? color : color.withOpacity(0.5),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : color.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}