import 'package:flutter/material.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import '../data/presta_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/prestataireCard.dart';
import '../widgets/details.dart'; // Assurez-vous d'importer la page de détails

/// Écran de sélection du lieu pour le bouquet
class ChoixLieuScreen extends StatefulWidget {
  final Function(LieuModel) onLieuSelected;
  final LieuModel? selectedLieu;
  final QuizResults? quizResults;

  const ChoixLieuScreen({
    Key? key,
    required this.onLieuSelected,
    this.selectedLieu,
    this.quizResults,
  }) : super(key: key);

  @override
  State<ChoixLieuScreen> createState() => _ChoixLieuScreenState();
}

class _ChoixLieuScreenState extends State<ChoixLieuScreen> {
  final PrestaRepository _repository = PrestaRepository();
  List<LieuModel> _lieux = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLieux();
  }

  /// Charge la liste des lieux depuis le repository
  Future<void> _loadLieux() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Récupérer les lieux depuis la base de données via PrestaRepository
// Récupérer tous les lieux (prestataires de type 3)
    final lieuxData = await _repository.getPrestairesByType(1);
    // Convertir les données en modèles LieuModel
    final lieux = lieuxData.map((data) => LieuModel.fromMap(data)).toList();

    setState(() {
      _lieux = lieux;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Erreur lors du chargement des lieux: ${e.toString()}';
      _isLoading = false;
    });
  }
}
  
  /// Charge des données factices en attendant l'API
  void _loadMockLieux() {
    final List<Map<String, dynamic>> mockData = [];
    
    // Générer des lieux factices
    final regions = ['Paris', 'Lyon', 'Bordeaux', 'Marseille', 'Strasbourg'];
    final typesLieu = [
      'Château', 'Domaine', 'Salle de réception', 'Hôtel', 'Villa', 'Manoir'
    ];
    
    for (int i = 1; i <= 10; i++) {
      final bool hasHebergement = i % 2 == 0;
      final bool hasEspaceExterieur = i % 3 != 0;
      final bool hasPiscine = i % 5 == 0;
      final String region = regions[i % regions.length];
      final String typeLieu = typesLieu[i % typesLieu.length];
      
      // Description des salles (simplifiée pour l'exemple)
      final Map<String, dynamic> descriptionSalles = {
        'salle_reception': {
          'capacite': 100 + (i * 20),
          'description': 'Salle principale avec vue panoramique',
        },
        'salle_cocktail': {
          'capacite': 50 + (i * 10),
          'description': 'Espace convivial pour cocktail et vin d\'honneur',
        },
      };
      
      mockData.add({
        'id': i.toString(),
        'nom_entreprise': '$typeLieu ${_getRandomName(i)}',
        'description': 'Magnifique $typeLieu avec cadre exceptionnel pour votre mariage. Capacité jusqu\'à ${100 + (i * 30)} personnes.',
        'photo_url': null,
        'prix_base': 2000.0 + (i * 500),
        'note_moyenne': 3.5 + (i % 5) * 0.3,
        'region': region,
        'type_lieu': typeLieu,
        'description_salles': descriptionSalles,
        'capacite_max': 100 + (i * 30),
        'espace_exterieur': hasEspaceExterieur,
        'piscine': hasPiscine,
        'parking': true,
        'hebergement': hasHebergement,
        'capacite_hebergement': hasHebergement ? 20 + (i * 4) : 0,
      });
    }
    
    setState(() {
      _lieux = mockData.map((data) => LieuModel.fromMap(data)).toList();
      _isLoading = false;
    });
  }
  
  /// Génère un nom aléatoire pour les données factices
  String _getRandomName(int seed) {
    final names = [
      'Royal', 'Élégance', 'Belle Vue', 'Grand Siècle', 'Prestige', 
      'Paradis', 'Émeraude', 'Romantique', 'Charme', 'Sérénité'
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
            'Choisissez votre lieu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        
        // Indication de sélection
        if (widget.selectedLieu != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Lieu sélectionné: ${widget.selectedLieu!.nomEntreprise}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Contenu principal - Liste verticale de lieux
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
              : _lieux.isEmpty
                ? EmptyState(
                    title: 'Aucun lieu disponible',
                    message: 'Nous ne trouvons pas de lieux à vous proposer actuellement.',
                    icon: Icons.villa,
                  )
                : _buildVerticalLieuxList(),
        ),
      ],
    );
  }
  
  /// Construit la liste verticale des lieux
  Widget _buildVerticalLieuxList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _lieux.length,
      itemBuilder: (context, index) {
        final lieu = _lieux[index];
        final isSelected = widget.selectedLieu?.id == lieu.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PrestaireCard(
            prestataire: lieu.toMap(),
            isSelected: isSelected,
            onTap: () => _selectLieu(lieu),
            onDetailPressed: () => _openLieuDetails(lieu), // Ajout du bouton pour les détails
          ),
        );
      },
    );
  }
  
  /// Ouvre la page de détails du lieu
  void _openLieuDetails(LieuModel lieu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestataireDetailScreen(
          type: 'lieu',
          prestataire: lieu.toMap(),
          isSelected: widget.selectedLieu?.id == lieu.id,
          onSelect: () => _selectLieu(lieu),
        ),
      ),
    );
  }
  
  /// Sélectionne un lieu et le communique au parent
  void _selectLieu(LieuModel lieu) {
    widget.onLieuSelected(lieu);
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lieu.nomEntreprise} sélectionné'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}