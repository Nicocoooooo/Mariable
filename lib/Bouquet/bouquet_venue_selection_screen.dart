import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Filtre/data/repositories/lieu_repository.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import 'prestataire_card2.dart';
import 'prestataire_infos.dart';
import 'bouquet_caterer_selection_screen.dart';

class BouquetVenueSelectionScreen extends StatefulWidget {
  final String bouquetId;

  const BouquetVenueSelectionScreen({
    Key? key,
    required this.bouquetId,
  }) : super(key: key);

  @override
  State<BouquetVenueSelectionScreen> createState() => _BouquetVenueSelectionScreenState();
}

class _BouquetVenueSelectionScreenState extends State<BouquetVenueSelectionScreen> {
  final LieuRepository _repository = LieuRepository();
  final PrestaRepository _prestaRepository = PrestaRepository();
  bool _isLoading = true;
  Map<String, dynamic>? _bouquetData;
  List<Map<String, dynamic>> _venues = [];
  String? _selectedVenueId;

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
      // Load bouquet data
      final response = await Supabase.instance.client
          .from('bouquets')
          .select('*')
          .eq('id', widget.bouquetId)
          .single();

      if (response != null) {
        // Convert to Map<String, dynamic>
        Map<String, dynamic> bouquet = {};
        response.forEach((key, value) {
          bouquet[key.toString()] = value;
        });

        setState(() {
          _bouquetData = bouquet;
        });

        // Load venues based on bouquet criteria
        await _loadVenues();
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

  Future<void> _loadVenues() async {
    try {
      // Récupérer seulement la région du bouquet
      final String? region = _bouquetData?['region'];
      
      // Si aucune région n'est spécifiée, utiliser une chaîne vide pour récupérer tous les lieux
      final String regionFilter = region ?? '';

      // Afficher des logs pour le débogage
      print('Chargement des lieux pour la région: $regionFilter');

      // Fetch venues based only on region (ignore other filters)
      List<Map<String, dynamic>> venues = await _prestaRepository.searchPrestataires(
        typeId: 1, // ID for venue type
        region: regionFilter,
        // Supprimer les autres critères de filtrage
        minPrice: null,
        maxPrice: null,
      );

      print('Nombre de lieux trouvés: ${venues.length}');

      // Sort venues by rating
      venues.sort((a, b) {
        final ratingA = a['note_moyenne'] ?? 0.0;
        final ratingB = b['note_moyenne'] ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      setState(() {
        _venues = venues;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des lieux: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des lieux: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectVenue(String venueId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update bouquet with selected venue
      await Supabase.instance.client
          .from('bouquets')
          .update({'lieu_id': venueId})
          .eq('id', widget.bouquetId);

      setState(() {
        _selectedVenueId = venueId;
        _isLoading = false;
      });

      // Navigate to next step
      _navigateToNextStep();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du lieu: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToNextStep() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BouquetCatererSelectionScreen(bouquetId: widget.bouquetId),
      ),
    );
  }

  void _navigateToDetails(Map<String, dynamic> venue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestaireDetailScreen(prestataire: venue),
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
        title: const Text('Sélection du lieu'),
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
                        value: 0.33, // 1/3 steps completed
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
                              isActive: true,
                              isCompleted: _selectedVenueId != null,
                            ),
                            _buildProgressDivider(),
                            _buildProgressIndicator(
                              label: 'Traiteur',
                              isActive: false,
                              isCompleted: false,
                            ),
                            _buildProgressDivider(),
                            _buildProgressIndicator(
                              label: 'Photographe',
                              isActive: false,
                              isCompleted: false,
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
                          'Sélectionnez votre lieu de réception',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nous avons sélectionné ces lieux en fonction de vos critères: région, nombre d\'invités, budget et style.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Filter chip showing current region
                        if (_bouquetData?['region'] != null)
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text('Région: ${_bouquetData!['region']}'),
                                backgroundColor: beige,
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: null, // Read-only in this screen
                              ),
                              
                              Chip(
                                label: Text('Invités: ${_bouquetData!['guest_count'] ?? 'N/A'}'),
                                backgroundColor: beige,
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: null, // Read-only in this screen
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Venue list
                _venues.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun lieu disponible',
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
                                child: const Text('Retour au quiz'),
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
                              final venue = _venues[index];
                              final venueId = venue['id'];
                              final bool isSelected = venueId == _selectedVenueId;
                              
                              return Stack(
                                children: [
                                  // Ajout du conteneur avec bordure pour indiquer la sélection
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      border: isSelected 
                                        ? Border.all(color: accentColor, width: 2.5)
                                        : null,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: PrestaireCard(
                                      prestataire: venue,
                                      onTap: () => _selectVenue(venueId),
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
                                        onPressed: () => _navigateToDetails(venue),
                                        tooltip: 'Voir les détails',
                                      ),
                                    ),
                                  ),
                                  
                                  // Bouton de sélection en bas à droite (sans icône)
                                  Positioned(
                                    bottom: 36,
                                    right: 16,
                                    child: ElevatedButton(
                                      onPressed: () => _selectVenue(venueId),
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
                            childCount: _venues.length,
                          ),
                        ),
                      ),
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
      floatingActionButton: _selectedVenueId != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToNextStep,
              backgroundColor: accentColor,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuer'),
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
                    (isActive ? '1' : label == 'Traiteur' ? '2' : '3'),
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