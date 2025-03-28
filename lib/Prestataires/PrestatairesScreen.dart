import 'package:flutter/material.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import '../Filtre/data/models/presta_type_model.dart';
import '../Filtre/PrestatairesListScreen.dart';

class PrestatairesScreen extends StatefulWidget {
  const PrestatairesScreen({Key? key}) : super(key: key);

  @override
  State<PrestatairesScreen> createState() => _PrestatairesScreenState();
}

class _PrestatairesScreenState extends State<PrestatairesScreen> with SingleTickerProviderStateMixin {
  final PrestaRepository _repository = PrestaRepository();
  bool _isLoading = true;
  List<PrestaTypeModel> _prestaTypes = [];
  String _errorMessage = '';
  
  // Pour les animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPrestaTypes();
    
    // Initialiser l'animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPrestaTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      final types = await _repository.getPrestaTypes();
      
      setState(() {
        _prestaTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching prestataire types: $e');
      
      setState(() {
        _errorMessage = 'Impossible de charger les types de prestataires: $e';
        _isLoading = false;
        
        // Données par défaut améliorées avec des descriptions plus élégantes
        _prestaTypes = [
          PrestaTypeModel(
            id: 1, 
            name: 'Lieu', 
            description: 'Du château romantique à la plage paradisiaque, trouvez le cadre parfait pour votre mariage.'
          ),
          PrestaTypeModel(
            id: 2, 
            name: 'Traiteur', 
            description: 'Des mets raffinés servis avec élégance pour enchanter vos invités et créer un moment de partage inoubliable.'
          ),
          PrestaTypeModel(
            id: 3, 
            name: 'Photographe', 
            description: 'L\'artiste qui immortalisera vos précieux souvenirs pour revivre éternellement votre plus beau jour.'
          ),
          PrestaTypeModel(
            id: 4, 
            name: 'Wedding Planner', 
            description: 'L\'organisateur qui s\'occupera de tous les détails pour que vous profitiez pleinement de votre journée.'
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Types de prestataires'),
        backgroundColor: const Color(0xFF524B46),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre élégant sur fond crème
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
            color: const Color(0xFFF5F2EA), // Couleur crème élégante
            width: double.infinity,
            child: Column(
              children: [
                // Ligne décorative en haut
                Container(
                  height: 1,
                  width: 100,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: Color(0xFF524B46), // Couleur dorée élégante
                ),
                
                // Titre principal
                const Text(
                  'Nos prestataires pour votre mariage',
                  style: TextStyle(
                    color: Color(0xFF524B46),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Sous-titre élégant
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 20, right: 20),
                  child: Text(
                    'Des partenaires de confiance sélectionnés pour leur excellence',
                    style: TextStyle(
                      color: Color(0xFF8A7F77),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Ligne décorative en bas
                Container(
                  height: 1,
                  width: 100,
                  margin: const EdgeInsets.only(top: 20),
                  color: Color(0xFF524B46), // Couleur dorée élégante
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Contenu principal
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
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            itemCount: _prestaTypes.length,
                            itemBuilder: (context, index) {
                              final prestaType = _prestaTypes[index];
                              return _buildPrestaTypeCard(prestaType);
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrestaTypeCard(PrestaTypeModel type) {
    // Images par défaut pour les différentes catégories - meilleures images de mariage
    final Map<String, String> defaultImages = {
      'lieu': 'https://images.unsplash.com/photo-1573676048035-9c2a72b6a12a?q=80&w=2942&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'traiteur': 'https://images.unsplash.com/photo-1495147466023-ac5c588e2e94?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'photographe': 'https://images.unsplash.com/photo-1623783356340-95375aac85ce?q=80&w=2948&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'wedding planner': 'https://images.unsplash.com/photo-1585556282289-d4d5a7967936?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    };

    // Obtenir l'URL de l'image selon le type
    final String imageUrl = defaultImages[type.name.toLowerCase()] ?? 
                           'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToPrestaList(type),
        child: Stack(
          children: [
            // Image d'arrière-plan
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              ),
            ),
            
            // Dégradé pour la lisibilité du texte
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // Contenu texte
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Icône flèche pour indiquer l'action - version plus élégante
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF524B46),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Badge élégant pour le type de prestataire
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F2EA),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  type.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A7F77),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPrestaList(PrestaTypeModel type) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => PrestatairesListScreen(
          prestaType: type,
        ),
      ),
    );
  }
}