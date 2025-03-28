import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/region_service.dart';
import 'bouquet_venue_selection_screen.dart';
import '../buttons/AnimatedReserveButton.dart';

class BouquetQuizScreen extends StatefulWidget {
  const BouquetQuizScreen({Key? key}) : super(key: key);

  @override
  State<BouquetQuizScreen> createState() => _BouquetQuizScreenState();
}

class _BouquetQuizScreenState extends State<BouquetQuizScreen> {
  // Current page index
  int _currentPage = 0;

  // Controllers for text inputs
  final TextEditingController _nameController = TextEditingController();
  
  // Selected data
  String? _selectedRegion;
  DateTime? _selectedDate;
  int _guestCount = 80;
  String _budgetRange = 'medium'; // 'low', 'medium', 'high', 'luxury'
  String _style = 'classic'; // 'classic', 'bohemian', 'modern', 'rustic'
  
  // Page controllers
  final PageController _pageController = PageController(initialPage: 0);

  // Available regions for dropdown
  List<String> _regions = [];
  bool _isLoadingRegions = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    final regionService = RegionService();
    try {
      final regions = await regionService.getAllRegions();
      setState(() {
        _regions = regions;
        _isLoadingRegions = false;
      });
    } catch (e) {
      setState(() {
        _regions = ['Paris', 'Lyon', 'Marseille', 'Bordeaux', 'Strasbourg'];
        _isLoadingRegions = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final initialDate = _selectedDate ?? now.add(const Duration(days: 90));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {  // Nous avons 4 pages (index 0-3)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishQuiz();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        // Nom du bouquet - optionnel mais préférable
        return true;
      case 1:
        // Seule la région est requise, la date est optionnelle
        return _selectedRegion != null;
      default:
        // Les autres pages sont purement décoratives
        return true;
    }
  }

  Future<void> _finishQuiz() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Vérifier que la région est sélectionnée (seule contrainte obligatoire)
      if (_selectedRegion == null) {
        // Fermer l'indicateur de chargement
        if (mounted) Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une région')),
        );
        return;
      }

      // Create the bouquet avec filtrage uniquement par région
      final response = await Supabase.instance.client.from('bouquets').insert({
        'name': _nameController.text.trim().isNotEmpty 
            ? _nameController.text.trim() 
            : 'Bouquet ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        'region': _selectedRegion,
        'event_date': _selectedDate?.toIso8601String(),
        'guest_count': _guestCount,
        'budget_range': _budgetRange,
        'style': _style,
      }).select().single();

      // Fermer l'indicateur de chargement
      if (mounted) Navigator.pop(context);

      // Navigate to venue selection with the new bouquet ID
      if (response != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BouquetVenueSelectionScreen(bouquetId: response['id']),
          ),
        );
      }
    } catch (e) {
      // Gérer l'erreur en cas d'échec de création du bouquet
      if (mounted) {
        // Fermer l'indicateur de chargement
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // Afficher un message d'erreur plus convivial
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de créer le bouquet. Veuillez réessayer plus tard.'),
            action: SnackBarAction(
              label: 'Détails',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Détails de l\'erreur'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Fermer'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color grisTexte = Theme.of(context).colorScheme.onSurface;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer un bouquet'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentPage > 0) {
              _previousPage();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / 4,  // 4 pages au total
            backgroundColor: Colors.grey[200],
            color: accentColor,
          ),
          
          // Main content with PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Page 1: Bouquet Name
                _buildNamePage(context),
                
                // Page 2: Date and Region
                _buildDateRegionPage(context),
                
                // Page 3: Budget
                _buildBudgetPage(context),
                
                // Page 4: Style
                _buildStylePage(context),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentPage > 0)
                  TextButton.icon(
                    onPressed: _previousPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: AnimatedReserveButton(
                    text: _currentPage == 3 ? 'Terminer' : 'Suivant',
                    onPressed:  _nextPage,
                    color: _canProceed() ? accentColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage(BuildContext context) {
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donnez un nom à votre bouquet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ce nom vous permettra de retrouver facilement votre projet de mariage',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom du bouquet',
                hintText: 'Ex: Notre mariage d\'été',
                filled: true,
                fillColor: beige.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.celebration),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              'Suggestions de noms:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSuggestionChip('Notre grand jour'),
                _buildSuggestionChip('Mariage de rêve'),
                _buildSuggestionChip('Jour J'),
                _buildSuggestionChip('Notre histoire'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBudgetPage(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quel budget ?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez votre fourchette de budget pour votre mariage',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 40),
            
            // Budget options
            _buildBudgetOption(
              title: 'Budget maîtrisé',
              description: 'Moins de 10,000€',
              value: 'low',
              icon: Icons.euro,
              iconCount: 1,
            ),
            
            const SizedBox(height: 16),
            
            _buildBudgetOption(
              title: 'Budget moyen',
              description: '10,000€ - 20,000€',
              value: 'medium',
              icon: Icons.euro,
              iconCount: 1,
            ),
            
            const SizedBox(height: 16),
            
            _buildBudgetOption(
              title: 'Budget premium',
              description: '20,000€ - 35,000€',
              value: 'high',
              icon: Icons.euro,
              iconCount: 1,
            ),
            
            const SizedBox(height: 16),
            
            _buildBudgetOption(
              title: 'Budget exceptionnel',
              description: 'Plus de 35,000€',
              value: 'luxury',
              icon: Icons.euro,
              iconCount: 1,
            ),
            
            const SizedBox(height: 30),
            
            // Note about budget
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: beige.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cette information nous permet de vous proposer des prestataires adaptés à votre budget. Vous pourrez ajuster vos choix à tout moment.',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBudgetOption({
    required String title,
    required String description,
    required String value,
    required IconData icon,
    required int iconCount,
  }) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final bool isSelected = _budgetRange == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _budgetRange = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  iconCount,
                  (index) => Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? accentColor : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? accentColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStylePage(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quel style pour votre mariage ?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez le style qui correspond le mieux à votre vision',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            
            // Style options grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStyleCard(
                  title: 'Classique',
                  imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop',
                  value: 'classic',
                ),
                _buildStyleCard(
                  title: 'Bohème',
                  imageUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?q=80&w=2787&auto=format&fit=crop',
                  value: 'bohemian',
                ),
                _buildStyleCard(
                  title: 'Moderne',
                  imageUrl: 'https://images.unsplash.com/photo-1529636798458-92182e662485?q=80&w=2769&auto=format&fit=crop',
                  value: 'modern',
                ),
                _buildStyleCard(
                  title: 'Champêtre',
                  imageUrl: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?q=80&w=2670&auto=format&fit=crop',
                  value: 'rustic',
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Style description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStyleDescription(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStyleLongDescription(),
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStyleCard({
    required String title,
    required String imageUrl,
    required String value,
  }) {
    final bool isSelected = _style == value;
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return InkWell(
      onTap: () {
        setState(() {
          _style = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.network(
                imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            
            // Title
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            
            // Selected indicator
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  String _getStyleDescription() {
    switch (_style) {
      case 'classic':
        return 'Style Classique';
      case 'bohemian':
        return 'Style Bohème';
      case 'modern':
        return 'Style Moderne';
      case 'rustic':
        return 'Style Champêtre';
      default:
        return 'Style Classique';
    }
  }
  
  String _getStyleLongDescription() {
    switch (_style) {
      case 'classic':
        return 'Un mariage élégant et intemporel avec une palette de couleurs neutres, des arrangements floraux sophistiqués et une ambiance raffinée.';
      case 'bohemian':
        return 'Un mariage décontracté et romantique avec des éléments naturels, des couleurs vives, des arrangements floraux sauvages et une ambiance libre et artistique.';
      case 'modern':
        return 'Un mariage contemporain avec des lignes épurées, des couleurs audacieuses ou monochromes, des éléments géométriques et une ambiance minimaliste.';
      case 'rustic':
        return 'Un mariage chaleureux avec des matériaux naturels comme le bois et la toile de jute, des fleurs champêtres et une ambiance conviviale et authentique.';
      default:
        return 'Un mariage élégant et intemporel avec une palette de couleurs neutres, des arrangements floraux sophistiqués et une ambiance raffinée.';
    }
  }

  Widget _buildSuggestionChip(String text) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    return InputChip(
      label: Text(text),
      backgroundColor: beige.withOpacity(0.5),
      onPressed: () {
        setState(() {
          _nameController.text = text;
        });
      },
    );
  }

  Widget _buildDateRegionPage(BuildContext context) {
    final Color beige = Theme.of(context).colorScheme.secondary;
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Où et quand ?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Indiquez la région et la date prévue de votre mariage',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            
            // Region selection
            Text(
              'Région',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _isLoadingRegions
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  decoration: BoxDecoration(
                    color: beige.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    hint: const Text('Sélectionnez une région'),
                    items: _regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value;
                      });
                    },
                  ),
                ),
            
            const SizedBox(height: 30),
            
            // Date selection
            Text(
              'Date du mariage',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: beige.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 16),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Sélectionnez une date',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Note about date flexibility
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: beige.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pas de souci si vous n\'avez pas encore de date précise, vous pourrez toujours la modifier plus tard.',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Guest count slider
            Text(
              'Nombre d\'invités estimé',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Slider(
              value: _guestCount.toDouble(),
              min: 10,
              max: 300,
              divisions: 29,
              label: _guestCount.toString(),
              onChanged: (value) {
                setState(() {
                  _guestCount = value.toInt();
                });
              },
              activeColor: accentColor,
            ),
            Center(
              child: Text(
                '$_guestCount invités',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Note about guest count
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.people_outline, color: accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Le nombre d\'invités aura un impact sur les lieux et services proposés.',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}