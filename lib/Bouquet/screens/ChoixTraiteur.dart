import 'package:flutter/material.dart';
import 'dart:convert';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import '../data/presta_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/prestataireCard.dart';
import '../widgets/details.dart';

/// Écran de sélection du traiteur pour le bouquet
class ChoixTraiteurScreen extends StatefulWidget {
  final Function(TraiteurModel) onTraiteurSelected;
  final TraiteurModel? selectedTraiteur;
  final String? lieuId; // ID du lieu sélectionné pour filtrer les traiteurs compatibles
  final QuizResults? quizResults;

  const ChoixTraiteurScreen({
    Key? key,
    required this.onTraiteurSelected,
    this.selectedTraiteur,
    this.lieuId,
    this.quizResults,
  }) : super(key: key);

  @override
  State<ChoixTraiteurScreen> createState() => _ChoixTraiteurScreenState();
}

class _ChoixTraiteurScreenState extends State<ChoixTraiteurScreen> {
  final PrestaRepository _repository = PrestaRepository();
  List<TraiteurModel> _traiteurs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTraiteurs();
  }

  /// Charge la liste des traiteurs depuis le repository
  Future<void> _loadTraiteurs() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      List<Map<String, dynamic>> traiteursData = [];
      
      // Utilisation du repository pour charger les traiteurs
      try {
        
          // Sinon, récupérer tous les traiteurs
          traiteursData = await _repository.getPrestairesByType(2);
        
        
        print('Traiteurs chargés: ${traiteursData.length}');
        
        // Debug: Vérifier les données reçues
        if (traiteursData.isNotEmpty) {
          print('Premier traiteur: ${traiteursData.first}');
          print('URL image: ${traiteursData.first['photo_url'] ?? "Aucune image"}');
        }
        
        // Conversion des données en modèles
        final traiteurs = traiteursData.map((data) {
          // Conversion des données en modèle TraiteurModel
          try {
            return TraiteurModel(
              id: data['id'],
              nomEntreprise: data['nom_entreprise'],
              description: data['description'] ?? '',
              photoUrl: data['photo_url'],
              prixBase: data['prix_base'] != null ? (data['prix_base'] as num).toDouble() : 0.0,
              typeCuisine: _extractTypeCuisine(data),
              maxInvites: data['max_invites'] ?? 100,
              equipementsInclus: data['equipements_inclus'] == true,
              personnelInclus: data['personnel_inclus'] == true,
              
            );
          } catch (e) {
            print('Erreur conversion traiteur: $e');
            print('Données: $data');
            // Créer un modèle minimal en cas d'erreur
            return TraiteurModel(
              id: data['id'] ?? 'unknown',
              nomEntreprise: data['nom_entreprise'] ?? 'Traiteur sans nom',
              description: data['description'] ?? '',
              photoUrl: data['photo_url'],
              prixBase: data['prix_base'] != null ? (data['prix_base'] as num).toDouble() : 0.0,
              typeCuisine: [],
              maxInvites: 0,
              equipementsInclus: false,
              personnelInclus: false,
             
            );
          }
        }).toList();
        
        setState(() {
          _traiteurs = traiteurs;
          _isLoading = false;
        });
      } catch (e) {
        print('Erreur lors du chargement des traiteurs: $e');
        // Si l'API rencontre une erreur, utiliser des données factices
        _loadMockTraiteurs();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des traiteurs: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  /// Extrait la liste des types de cuisine d'un traiteur
  List<String> _extractTypeCuisine(Map<String, dynamic> data) {
    if (data['type_cuisine'] == null) return [];
    
    try {
      if (data['type_cuisine'] is List) {
        return List<String>.from(data['type_cuisine']);
      } else if (data['type_cuisine'] is String) {
        if (data['type_cuisine'].toString().isEmpty) return [];
        
        // Essayer de parser comme JSON si c'est une chaîne
        try {
          final parsed = jsonDecode(data['type_cuisine']);
          if (parsed is List) {
            return List<String>.from(parsed);
          }
        } catch (e) {
          // Si ce n'est pas un JSON, traiter comme une seule valeur
          return [data['type_cuisine'].toString()];
        }
      }
    } catch (e) {
      print('Erreur extraction type_cuisine: $e');
    }
    
    return [];
  }
  
  /// Charge des données factices en attendant l'API
  void _loadMockTraiteurs() {
    final List<Map<String, dynamic>> mockData = [];
    
    // Générer des traiteurs factices
    final regions = ['Paris', 'Lyon', 'Bordeaux', 'Marseille', 'Strasbourg'];
    final typesCuisine = [
      'Française', 'Italienne', 'Méditerranéenne', 'Fusion', 'Gastronomique', 'Végétarienne'
    ];
    
    for (int i = 1; i <= 12; i++) {
      final bool hasEquipements = i % 2 == 0;
      final bool hasPersonnel = i % 3 != 0;
      final String region = regions[i % regions.length];
      
      // Générer 2-3 types de cuisine pour chaque traiteur
      final List<String> cuisines = [];
      cuisines.add(typesCuisine[(i * 2) % typesCuisine.length]);
      cuisines.add(typesCuisine[(i * 3) % typesCuisine.length]);
      if (i % 3 == 0) {
        cuisines.add(typesCuisine[(i * 5) % typesCuisine.length]);
      }
      
      mockData.add({
        'id': i.toString(),
        'nom_entreprise': 'Traiteur ${_getRandomName(i)}',
        'description': 'Traiteur spécialisé dans la cuisine ${cuisines.join(", ")}. Service de qualité pour votre mariage.',
        'photo_url': null,
        'prix_base': 50.0 + (i * 10),
        'note_moyenne': 3.5 + (i % 5) * 0.3,
        'region': region,
        'type_cuisine': cuisines,
        'max_invites': 100 + (i * 25),
        'equipements_inclus': hasEquipements,
        'personnel_inclus': hasPersonnel,
        'type_traiteur': typesCuisine[i % typesCuisine.length],
      });
    }
    
    setState(() {
      _traiteurs = mockData.map((data) => TraiteurModel(
        id: data['id'],
        nomEntreprise: data['nom_entreprise'],
        description: data['description'],
        photoUrl: data['photo_url'],
        prixBase: data['prix_base'],
        typeCuisine: List<String>.from(data['type_cuisine']),
        maxInvites: data['max_invites'],
        equipementsInclus: data['equipements_inclus'],
        personnelInclus: data['personnel_inclus'],
    
      )).toList();
      _isLoading = false;
    });
  }
  
  /// Génère un nom aléatoire pour les données factices
  String _getRandomName(int seed) {
    final names = [
      'Délices', 'Saveurs', 'Excellence', 'Gourmet', 'Passion', 
      'Gourmandise', 'Gastronomie', 'Prestige', 'Arôme', 'Festif'
    ];
    return names[seed % names.length];
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de la section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Choisissez votre traiteur',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        
        // Indication de sélection
        if (widget.selectedTraiteur != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Traiteur sélectionné: ${widget.selectedTraiteur!.nomEntreprise}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Contenu principal - Liste verticale de traiteurs
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                )
              : _traiteurs.isEmpty
                ? EmptyState(
                    title: 'Aucun traiteur disponible',
                    message: widget.lieuId != null 
                        ? 'Nous ne trouvons pas de traiteurs compatibles avec le lieu choisi.' 
                        : 'Nous ne trouvons pas de traiteurs à vous proposer actuellement.',
                    icon: Icons.restaurant_menu,
                    actionLabel: 'Réessayer',
                    onActionPressed: _loadTraiteurs,
                  )
                : _buildVerticalTraiteursList(),
        ),
      ],
    );
  }
  
  /// Construit la liste verticale des traiteurs
  Widget _buildVerticalTraiteursList() {
    return RefreshIndicator(
      onRefresh: _loadTraiteurs,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _traiteurs.length,
        itemBuilder: (context, index) {
          final traiteur = _traiteurs[index];
          final isSelected = widget.selectedTraiteur?.id == traiteur.id;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PrestaireCard(
              prestataire: traiteur.toMap(),
              isSelected: isSelected,
              onTap: () => _selectTraiteur(traiteur),
              onDetailPressed: () => _openTraiteurDetails(traiteur),
              isFavorite: false,
              onFavoriteToggle: () {},
            ),
          );
        },
      ),
    );
  }
  
  /// Ouvre la page de détails du traiteur
  void _openTraiteurDetails(TraiteurModel traiteur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestataireDetailScreen(
          type: 'traiteur',
          prestataire: traiteur.toMap(),
          isSelected: widget.selectedTraiteur?.id == traiteur.id,
          onSelect: () => _selectTraiteur(traiteur),
        ),
      ),
    );
  }
  
  /// Sélectionne un traiteur et le communique au parent
  void _selectTraiteur(TraiteurModel traiteur) {
    widget.onTraiteurSelected(traiteur);
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${traiteur.nomEntreprise} sélectionné'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}