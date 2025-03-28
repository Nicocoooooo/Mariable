import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import 'prestataire_card2.dart';
import 'prestataire_infos.dart';
import 'bouquet_detail_screen.dart';

class BouquetPhotographerSelectionScreen extends StatefulWidget {
  final String bouquetId;

  const BouquetPhotographerSelectionScreen({
    Key? key,
    required this.bouquetId,
  }) : super(key: key);

  @override
  State<BouquetPhotographerSelectionScreen> createState() => _BouquetPhotographerSelectionScreenState();
}

class _BouquetPhotographerSelectionScreenState extends State<BouquetPhotographerSelectionScreen> {
  final PrestaRepository _repository = PrestaRepository();
  bool _isLoading = true;
  Map<String, dynamic>? _bouquetData;
  Map<String, dynamic>? _venueData;
  Map<String, dynamic>? _catererData;
  List<Map<String, dynamic>> _photographers = [];
  String? _selectedPhotographerId;

  @override
  void initState() {
    super.initState();
    _loadBouquetData();
  }

  Future<void> _loadBouquetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load bouquet data including the selected venue and caterer
      final response = await Supabase.instance.client
          .from('bouquets')
          .select('*, lieux:lieu_id(*), traiteurs:traiteur_id(*)')
          .eq('id', widget.bouquetId)
          .single();

      if (response != null) {
        // Convert to Map<String, dynamic>
        Map<String, dynamic> bouquet = {};
        response.forEach((key, value) {
          bouquet[key.toString()] = value;
        });

        // Extract venue data if available
        Map<String, dynamic>? venue;
        if (bouquet.containsKey('lieux') && bouquet['lieux'] != null) {
          venue = {};
          bouquet['lieux'].forEach((key, value) {
            venue![key.toString()] = value;
          });
        }

        // Extract caterer data if available
        Map<String, dynamic>? caterer;
        if (bouquet.containsKey('traiteurs') && bouquet['traiteurs'] != null) {
          caterer = {};
          bouquet['traiteurs'].forEach((key, value) {
            caterer![key.toString()] = value;
          });
        }

        setState(() {
          _bouquetData = bouquet;
          _venueData = venue;
          _catererData = caterer;
        });

        // Load photographers based on bouquet criteria
        await _loadPhotographers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPhotographers() async {
    try {
      // Récupérer seulement la région du bouquet
      final String? region = _bouquetData?['region'];
      
      // Afficher des logs pour le débogage
      print('Chargement des photographes pour la région: $region');

      // Fetch photographers based only on region
      List<Map<String, dynamic>> photographers = await _repository.searchPrestataires(
        typeId: 3, // ID for photographer type
        region: region,
        // Supprimer les limites de prix
        minPrice: null,
        maxPrice: null,
      );

      print('Nombre de photographes trouvés: ${photographers.length}');

      // Sort photographers by rating
      photographers.sort((a, b) {
        final ratingA = a['note_moyenne'] ?? 0.0;
        final ratingB = b['note_moyenne'] ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      setState(() {
        _photographers = photographers;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des photographes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des photographes: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPhotographer(String photographerId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update bouquet with selected photographer
      await Supabase.instance.client
          .from('bouquets')
          .update({'photographe_id': photographerId})
          .eq('id', widget.bouquetId);

      setState(() {
        _selectedPhotographerId = photographerId;
        _isLoading = false;
      });

      // Navigate to bouquet detail
      _navigateToSummary();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du photographe: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSummary() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BouquetSummaryScreen(bouquetId: widget.bouquetId),
      ),
    );
  }

  void _navigateToDetails(Map<String, dynamic> photographer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestaireDetailScreen(prestataire: photographer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color grisTexte = Theme.of(context).colorScheme.onSurface;
    final Color beige = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sélection du photographe'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Header with progress indicators
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Progress bar
                      LinearProgressIndicator(
                        value: 1.0, // 3/3 steps completed
                        backgroundColor: Colors.grey[200],
                        color: accentColor,
                      ),
                      
                      // Progress indicators
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildProgressIndicator(
                              label: 'Lieu',
                              isActive: false,
                              isCompleted: true,
                            ),
                            _buildProgressDivider(),
                            _buildProgressIndicator(
                              label: 'Traiteur',
                              isActive: false,
                              isCompleted: true,
                            ),
                            _buildProgressDivider(),
                            _buildProgressIndicator(
                              label: 'Photographe',
                              isActive: true,
                              isCompleted: _selectedPhotographerId != null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Introduction text
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sélectionnez votre photographe',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nous avons sélectionné ces photographes en fonction de vos critères: région, budget et style.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Selected providers info
                        if (_venueData != null || _catererData != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: beige.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accentColor.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_venueData != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Lieu sélectionné:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _venueData!['nom_entreprise'] ?? 'Lieu sans nom',
                                                style: TextStyle(color: Colors.grey[800]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                if (_catererData != null)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.restaurant, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Traiteur sélectionné:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _catererData!['nom_entreprise'] ?? 'Traiteur sans nom',
                                              style: TextStyle(color: Colors.grey[800]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Photographer list
                _photographers.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun photographe disponible',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Essayez de modifier vos critères',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retour'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final photographer = _photographers[index];
                              final photographerId = photographer['id'];
                              final bool isSelected = photographerId == _selectedPhotographerId;
                              
                              return Stack(
                                children: [
                                  // Conteneur avec bordure pour indiquer la sélection
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      border: isSelected 
                                        ? Border.all(color: accentColor, width: 2.5)
                                        : null,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: PrestaireCard(
                                      prestataire: photographer,
                                      onTap: () => _selectPhotographer(photographerId),
                                      isFavorite: false,
                                    ),
                                  ),
                                  
                                  // Bouton détails ("+")
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.add),
                                        color: accentColor,
                                        iconSize: 24,
                                        onPressed: () => _navigateToDetails(photographer),
                                        tooltip: 'Voir les détails',
                                      ),
                                    ),
                                  ),
                                  
                                  // Bouton de sélection en bas à droite (sans icône)
                                  Positioned(
                                    bottom: 36,
                                    right: 16,
                                    child: ElevatedButton(
                                      onPressed: () => _selectPhotographer(photographerId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.white,
                                        elevation: 3,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                      child: const Text(
                                        'Sélectionner',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            childCount: _photographers.length,
                          ),
                        ),
                      ),
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
      floatingActionButton: _selectedPhotographerId != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToSummary,
              backgroundColor: accentColor,
              icon: const Icon(Icons.check),
              label: const Text('Terminer'),
            )
          : null,
    );
  }
  
  Widget _buildProgressIndicator({
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? accentColor
                : isActive
                    ? accentColor.withOpacity(0.2)
                    : Colors.grey[300],
            border: Border.all(
              color: isActive ? accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                )
              : Center(
                  child: Text(
                    (label == 'Lieu' ? '1' : label == 'Traiteur' ? '2' : '3'),
                    style: TextStyle(
                      color: isActive ? accentColor : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? accentColor : Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressDivider() {
    return Container(
      width: 40,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[300],
    );
  }
}