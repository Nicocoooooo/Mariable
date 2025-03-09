import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import '../widgets/empty_state.dart';

class LieuTypesScreen extends StatefulWidget {
  const LieuTypesScreen({Key? key}) : super(key: key);

  @override
  State<LieuTypesScreen> createState() => _LieuTypesScreenState();
}

class _LieuTypesScreenState extends State<LieuTypesScreen> {
  final _searchController = TextEditingController();
  final PrestaRepository _repository = PrestaRepository();
  
  List<Map<String, dynamic>> _lieuTypes = [];
  List<Map<String, dynamic>> _filteredLieuTypes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLieuTypes();
    _searchController.addListener(_filterLieuTypes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLieuTypes);
    _searchController.dispose();
    super.dispose();
  }

  void _filterLieuTypes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLieuTypes = List.from(_lieuTypes);
      } else {
        _filteredLieuTypes = _lieuTypes
            .where((type) => type['name'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

 Future<void> _fetchLieuTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Fetch lieu types from Supabase
      final response = await Supabase.instance.client
          .from('lieu_type')
          .select('id, name, description, image_url')
          .order('id', ascending: true);

      // Correction du problème de type
      final List<Map<String, dynamic>> typedResponse = [];
      
      // Conversion explicite des éléments en Map<String, dynamic>
      for (var item in response) {
        if (item is Map) {
          // Convertir en Map<String, dynamic>
          final Map<String, dynamic> typedItem = {};
          item.forEach((key, value) {
            typedItem[key.toString()] = value;
          });
          typedResponse.add(typedItem);
        }
      }

      setState(() {
        _lieuTypes = typedResponse;
        _filteredLieuTypes = List.from(_lieuTypes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des types de lieux: ${e.toString()}';
        _isLoading = false;
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
                  'Types de lieux',
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
                hintText: 'Rechercher un type de lieu',
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
          
          // List of lieu types
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
                    : _filteredLieuTypes.isEmpty
                        ? EmptyState(
                            title: 'Aucun type de lieu trouvé',
                            message: 'Essayez de modifier votre recherche',
                            icon: Icons.search_off,
                            actionLabel: 'Réinitialiser la recherche',
                            onActionPressed: () {
                              _searchController.clear();
                              _filterLieuTypes();
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredLieuTypes.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final lieuType = _filteredLieuTypes[index];
                              return _buildLieuTypeCard(lieuType, accentColor, grisTexte);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLieuTypeCard(Map<String, dynamic> lieuType, Color accentColor, Color grisTexte) {
    return InkWell(
      onTap: () {
        // Return the selected lieu type to the previous screen
        Navigator.pop(context, lieuType);
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
              child: lieuType['image_url'] != null
                  ? Image.network(
                      lieuType['image_url'],
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
                        Icons.place_outlined,
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
                      lieuType['name'] ?? 'Sans nom',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: grisTexte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lieuType['description'] ?? 'Aucune description',
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
}
