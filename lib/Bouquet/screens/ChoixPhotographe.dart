import 'package:flutter/material.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import '../data/presta_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/prestataireCard.dart';
import '../widgets/details.dart';

/// Écran de sélection du photographe pour le bouquet
class ChoixPhotographeScreen extends StatefulWidget {
  final Function(PhotographeModel) onPhotographeSelected;
  final PhotographeModel? selectedPhotographe;
  final QuizResults? quizResults;

  const ChoixPhotographeScreen({
    Key? key,
    required this.onPhotographeSelected,
    this.selectedPhotographe,
    this.quizResults,
  }) : super(key: key);

  @override
  State<ChoixPhotographeScreen> createState() => _ChoixPhotographeScreenState();
}

class _ChoixPhotographeScreenState extends State<ChoixPhotographeScreen> {
  final PrestaRepository _repository = PrestaRepository();
  List<PhotographeModel> _photographes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPhotographes();
  }

  /// Charge la liste des photographes depuis le repository
  Future<void> _loadPhotographes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Utilisation du repository pour charger les photographes
      try {
        final photographesData = await _repository.getPrestairesByType(3);
        print('Photographes chargés: ${photographesData.length}');
        
        // Debug: Vérifier les données reçues
        if (photographesData.isNotEmpty) {
          print('Premier photographe: ${photographesData.first}');
          print('URL image: ${photographesData.first['photo_url'] ?? photographesData.first['image_url'] ?? "Aucune image"}');
        }
        
        // Conversion des données en modèles
        final photographes = photographesData.map((data) {
          // Assurez-vous que le champ photo_url existe
          if (data['photo_url'] == null && data['image_url'] != null) {
            data['photo_url'] = data['image_url'];
          }
          
          // Conversion des données en modèle PhotographeModel
          try {
            return PhotographeModel.fromMap(data);
          } catch (e) {
            print('Erreur conversion photographe: $e');
            print('Données: $data');
            // Créer un modèle minimal en cas d'erreur 
            return PhotographeModel(
              id: data['id'] ?? 'unknown',
              nomEntreprise: data['nom_entreprise'] ?? 'Photographe sans nom',
              description: data['description'] ?? '',
              photoUrl: data['photo_url'] ?? data['image_url'],
              prixBase: data['prix_base'] != null ? (data['prix_base'] as num).toDouble() : 0.0,
              style: data['style'] is List ? List<String>.from(data['style']) : [],
              optionsDuree: {},
              drone: data['drone'] == true,
            );
          }
        }).toList();
        
        setState(() {
          _photographes = photographes;
          _isLoading = false;
        });
      } catch (e) {
        print('Erreur lors du chargement des photographes: $e');
        // Si l'API rencontre une erreur, utiliser des données factices
        _loadMockPhotographes();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des photographes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  /// Charge des données factices en attendant l'API
  void _loadMockPhotographes() {
    final List<Map<String, dynamic>> mockData = [];
    
    // Générer des photographes factices
    final regions = ['Paris', 'Lyon', 'Bordeaux', 'Marseille', 'Strasbourg'];
    final stylesPhoto = [
      'Reportage', 'Artistique', 'Traditionnel', 'Journalistique', 'Contemporain', 'Vintage'
    ];
    
    for (int i = 1; i <= 10; i++) {
      final bool hasDrone = i % 3 == 0;
      final String region = regions[i % regions.length];
      
      // Générer 1-2 styles pour chaque photographe
      final List<String> styles = [];
      styles.add(stylesPhoto[i % stylesPhoto.length]);
      if (i % 2 == 0) {
        styles.add(stylesPhoto[(i + 3) % stylesPhoto.length]);
      }
      
      // Options de durée (simplifiées pour l'exemple)
      final Map<String, dynamic> optionsDuree = {
        'demi_journee': {
          'prix': 800 + (i * 50),
          'description': 'Couverture de la cérémonie et des premiers moments de la réception',
        },
        'journee': {
          'prix': 1200 + (i * 80),
          'description': 'Couverture de la préparation jusqu\'au début de soirée',
        },
        'journee_complete': {
          'prix': 1500 + (i * 100),
          'description': 'Couverture complète de la préparation jusqu\'à la fin de soirée',
        },
      };
      
      mockData.add({
        'id': i.toString(),
        'nom_entreprise': 'Studio ${_getRandomName(i)}',
        'description': 'Photographe spécialisé dans le style ${styles.join(", ")}. Capturez les plus beaux moments de votre mariage.',
        'photo_url': null,
        'prix_base': 800.0 + (i * 100),
        'note_moyenne': 3.5 + (i % 5) * 0.3,
        'region': region,
        'style': styles,
        'options_duree': optionsDuree,
        'drone': hasDrone,
      });
    }
    
    setState(() {
      _photographes = mockData.map((data) => PhotographeModel.fromMap(data)).toList();
      _isLoading = false;
    });
  }
  
  /// Génère un nom aléatoire pour les données factices
  String _getRandomName(int seed) {
    final names = [
      'Lumière', 'Vision', 'Capture', 'Objectif', 'Clic', 
      'Image', 'Cadre', 'Moment', 'Pixel', 'Focus'
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
            'Choisissez votre photographe',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        
        // Indication de sélection
        if (widget.selectedPhotographe != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Photographe sélectionné: ${widget.selectedPhotographe!.nomEntreprise}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Contenu principal - Liste verticale de photographes
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
              : _photographes.isEmpty
                ? EmptyState(
                    title: 'Aucun photographe disponible',
                    message: 'Nous ne trouvons pas de photographes à vous proposer actuellement.',
                    icon: Icons.camera_alt_outlined,
                    actionLabel: 'Réessayer',
                    onActionPressed: _loadPhotographes,
                  )
                : _buildVerticalPhotographesList(),
        ),
      ],
    );
  }
  
  /// Construit la liste verticale des photographes
  Widget _buildVerticalPhotographesList() {
    return RefreshIndicator(
      onRefresh: _loadPhotographes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _photographes.length,
        itemBuilder: (context, index) {
          final photographe = _photographes[index];
          final isSelected = widget.selectedPhotographe?.id == photographe.id;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PrestaireCard(
              prestataire: photographe.toMap(),
              isSelected: isSelected,
              onTap: () => _selectPhotographe(photographe),
              onDetailPressed: () => _openPhotographeDetails(photographe),
              isFavorite: false,
              onFavoriteToggle: () {},
            ),
          );
        },
      ),
    );
  }
  
  /// Ouvre la page de détails du photographe
  void _openPhotographeDetails(PhotographeModel photographe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestataireDetailScreen(
          type: 'photographe',
          prestataire: photographe.toMap(),
          isSelected: widget.selectedPhotographe?.id == photographe.id,
          onSelect: () => _selectPhotographe(photographe),
        ),
      ),
    );
  }
  
  /// Sélectionne un photographe et le communique au parent
  void _selectPhotographe(PhotographeModel photographe) {
    widget.onPhotographeSelected(photographe);
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${photographe.nomEntreprise} sélectionné'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}