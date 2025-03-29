import 'package:flutter/material.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import '../widgets/empty_state.dart';

class TraiteurTypesScreen extends StatefulWidget {
  const TraiteurTypesScreen({super.key});

  @override
  State<TraiteurTypesScreen> createState() => _TraiteurTypesScreenState();
}


class _TraiteurTypesScreenState extends State<TraiteurTypesScreen> {
  final _searchController = TextEditingController();
  final PrestaRepository _repository = PrestaRepository();
  
  List<Map<String, dynamic>> _traiteurTypes = [];
  List<Map<String, dynamic>> _filteredTraiteurTypes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTraiteurTypes();
    _searchController.addListener(_filterTraiteurTypes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTraiteurTypes);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTraiteurTypes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTraiteurTypes = List.from(_traiteurTypes);
      } else {
        _filteredTraiteurTypes = _traiteurTypes
            .where((type) => type['name'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
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
                'Types de traiteurs',
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
                hintText: 'Rechercher un type de traiteur',
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
          
          // List of traiteur types
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red[700]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _fetchTraiteurTypes,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réessayer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredTraiteurTypes.isEmpty
                        ? EmptyState(
                            title: 'Aucun type de traiteur trouvé',
                            message: 'Les types de traiteurs ne sont pas disponibles pour le moment ou n\'ont pas encore été configurés dans la base de données.',
                            icon: Icons.search_off,
                            actionLabel: 'Réinitialiser la recherche',
                            onActionPressed: () {
                              _searchController.clear();
                              _filterTraiteurTypes();
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredTraiteurTypes.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final traiteurType = _filteredTraiteurTypes[index];
                              return _buildTraiteurTypeCard(traiteurType, accentColor, grisTexte);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraiteurTypeCard(Map<String, dynamic> traiteurType, Color accentColor, Color grisTexte) {
    return InkWell(
      onTap: () {
        // Return the selected traiteur type to the previous screen
        Navigator.pop(context, traiteurType);
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
              child: traiteurType['image_url'] != null
                  ? Image.network(
                      traiteurType['image_url'],
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
                        Icons.restaurant,
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
                      traiteurType['name'] ?? 'Sans nom',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: grisTexte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      traiteurType['description'] ?? 'Aucune description',
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
  // Dans _TraiteurTypesScreenState, ajoutez cette méthode:
Future<void> _fetchTraiteurTypes() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Appel à la méthode du repository
      final traiteurTypes = await _repository.getTraiteurTypes();
      
      setState(() {
        _traiteurTypes = traiteurTypes;
        _filteredTraiteurTypes = List.from(_traiteurTypes);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching traiteur types: $e');
      setState(() {
        _errorMessage = 'Erreur lors du chargement des types de traiteurs: ${e.toString()}';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
    });
  }
}

}
