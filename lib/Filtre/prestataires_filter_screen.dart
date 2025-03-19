import 'package:flutter/material.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import '../Filtre/data/models/presta_type_model.dart';
import '../widgets/empty_state.dart';
import 'lieu_types_screen.dart';

class PrestatairesFilterScreen extends StatefulWidget {
  const PrestatairesFilterScreen({Key? key}) : super(key: key);

  @override
  State<PrestatairesFilterScreen> createState() => _PrestatairesFilterScreenState();
}

class _PrestatairesFilterScreenState extends State<PrestatairesFilterScreen> {
  final _searchController = TextEditingController();
  final PrestaRepository _repository = PrestaRepository();
  
  List<Map<String, dynamic>> _prestaTypes = [];
  List<Map<String, dynamic>> _filteredPrestaTypes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPrestaTypes();
    _searchController.addListener(_filterPrestaTypes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPrestaTypes);
    _searchController.dispose();
    super.dispose();
  }

  void _filterPrestaTypes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPrestaTypes = List.from(_prestaTypes);
      } else {
        _filteredPrestaTypes = _prestaTypes
            .where((type) => type['name'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }


Future<void> _fetchPrestaTypes() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Ajouter un délai avant de récupérer les données
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Fetch prestataire types using the repository
    final prestaTypes = await _repository.getPrestaTypes();
    
    // Si la liste est vide, utiliser des données fictives
    if (prestaTypes.isEmpty) {
      print('No prestataire types found, using default values');

      final defaultTypes = [
        PrestaTypeModel(id: 1, name: 'Lieu', description: 'Lieux pour votre mariage'),
        // ... autres types par défaut
      ];
      
      final prestaTypesMapList = defaultTypes.map((type) => type.toMap()).toList();
      
      setState(() {
        _prestaTypes = prestaTypesMapList;
        _filteredPrestaTypes = List.from(_prestaTypes);
        _isLoading = false;
      });
      return;
    }
    
    final prestaTypesMapList = prestaTypes.map((type) => type.toMap()).toList();

    setState(() {
      _prestaTypes = prestaTypesMapList;
      _filteredPrestaTypes = List.from(_prestaTypes);
      _isLoading = false;
    });
  } catch (e) {
    print('No prestataire types found, using default values');

    
    setState(() {
      _errorMessage = 'Erreur lors du chargement des types de prestataires: ${e.toString()}';
      _isLoading = false;
      
      // Ajouter des données fictives en cas d'erreur
      _prestaTypes = [
        {'id': 1, 'name': 'Lieu', 'description': 'Lieux pour votre mariage'},
        {'id': 2, 'name': 'Traiteur', 'description': 'Services de restauration'},
        {'id': 3, 'name': 'Photographe', 'description': 'Capture de vos souvenirs'},
        {'id': 4, 'name': 'Wedding Planner', 'description': 'Organisation complète de votre mariage'},
      ];
      _filteredPrestaTypes = List.from(_prestaTypes);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    // Use theme colors from the main app
    final Color accentColor = Theme.of(context).colorScheme.primary; // #524B46
    final Color grisTexte = Theme.of(context).colorScheme.onSurface; // #2B2B2B
    final Color beige = Theme.of(context).colorScheme.secondary; // #FFF3E4

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle and close button row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                // Title
                Text(
                  'Types de prestataires',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: grisTexte,
                  ),
                ),
                // Close button
                IconButton(
                  icon: Icon(Icons.close, color: grisTexte),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un type de prestataire',
                hintStyle: TextStyle(color: grisTexte.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: grisTexte.withOpacity(0.6)),
                filled: true,
                fillColor: beige.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),
          
          // List of prestataire types
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _filteredPrestaTypes.isEmpty
                        ? EmptyState(
                            title: 'Aucun type de prestataire trouvé',
                            message: 'Essayez de modifier votre recherche ou consultez tous les prestataires disponibles.',
                            icon: Icons.search_off,
                            actionLabel: 'Voir tous les prestataires',
                            onActionPressed: () {
                              _searchController.clear();
                              _filterPrestaTypes();
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredPrestaTypes.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final prestaType = _filteredPrestaTypes[index];
                              return _buildPrestaTypeCard(prestaType, accentColor, grisTexte);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrestaTypeCard(Map<String, dynamic> prestaType, Color accentColor, Color grisTexte) {
    return InkWell(
      onTap: () {
        // Handle tap based on the type of prestataire
        _handlePrestaTypeSelection(prestaType);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: prestaType['image_url'] != null
                  ? Image.network(
                      prestaType['image_url'],
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 80,
                          color: accentColor.withOpacity(0.1),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: accentColor.withOpacity(0.5),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 100,
                      height: 80,
                      color: accentColor.withOpacity(0.1),
                      child: Icon(
                        Icons.business_outlined,
                        color: accentColor.withOpacity(0.5),
                      ),
                    ),
            ),
            
            // Text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prestaType['name'] ?? 'Sans nom',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: grisTexte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prestaType['description'] ?? 'Aucune description',
                      style: TextStyle(
                        fontSize: 13,
                        color: grisTexte.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Arrow icon
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle selection based on prestataire type
  Future<void> _handlePrestaTypeSelection(Map<String, dynamic> prestaType) async {
    // Get the name of the prestataire type
    final String typeName = prestaType['name'].toString().toLowerCase();
    
    // Handle different types of prestataires
    switch (typeName) {
      case 'lieu':
        // Show lieu types screen
        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return const LieuTypesScreen();
            },
          ),
        );
        
        if (result != null) {
          // Return both presta type and lieu type
          Navigator.pop(context, {
            'prestaType': prestaType,
            'subType': result,
          });
        }
        break;
        
      case 'photographe':
      case 'traiteur':
      case 'wedding planner':
        // For now, just return the selected prestataire type
        // You can add specialized screens for these types later
        Navigator.pop(context, prestaType);
        break;
        
      default:
        // For all other types, just return the selected type
        Navigator.pop(context, prestaType);
        break;
    }
  }
}