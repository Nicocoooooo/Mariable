import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bouquet_creation_screen.dart';

class BouquetHomeScreen extends StatefulWidget {
  const BouquetHomeScreen({Key? key}) : super(key: key);

  @override
  State<BouquetHomeScreen> createState() => _BouquetHomeScreenState();
}

class _BouquetHomeScreenState extends State<BouquetHomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bouquets = [];

  @override
  void initState() {
    super.initState();
    _loadBouquets();
  }

  Future<void> _loadBouquets() async {
    // Simuler un chargement depuis une API
    await Future.delayed(const Duration(milliseconds: 800));

    // Pour l'exemple, nous allons créer des bouquets fictifs
    final List<Map<String, dynamic>> mockBouquets = [
      {
        'id': '1',
        'name': 'Bouquet Élégance',
        'description': 'Salle, traiteur et photographe pour un mariage élégant',
        'prestataires': 3,
        'savings': 450,
        'status': 'confirmed',
        'image': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop'
      },
      {
        'id': '2',
        'name': 'Bouquet Champêtre',
        'description': 'Domaine, traiteur et décoratrice pour un mariage dans la nature',
        'prestataires': 4,
        'savings': 650,
        'status': 'pending',
        'image': 'https://images.unsplash.com/photo-1469371670807-013ccf25f16a?q=80&w=2940&auto=format&fit=crop'
      },
    ];

    setState(() {
      _bouquets = mockBouquets;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Couleurs de la charte graphique
    final Color grisTexte = const Color(0xFF2B2B2B);
    final Color accentColor = const Color(0xFF524B46);
    final Color beige = const Color(0xFFFFF3E4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bouquets',
          style: GoogleFonts.playfairDisplay(
            textStyle: TextStyle(
              color: grisTexte,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: grisTexte),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: grisTexte),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBouquets,
        color: accentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête avec image
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                ),
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
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Vos bouquets de prestataires',
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Texte explicatif
              Text(
                'Créez des ensembles de prestataires pour votre mariage et économisez avec les remises exclusives',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: grisTexte.withOpacity(0.7),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Titre de section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vos bouquets sauvegardés',
                    style: GoogleFonts.playfairDisplay(
                      textStyle: TextStyle(
                        color: grisTexte,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Fonction pour voir tous les bouquets
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voir tous les bouquets'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Voir tout',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Liste des bouquets sauvegardés
              _isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: accentColor,
                      ),
                    ),
                  )
                : _bouquets.isEmpty
                  ? _buildEmptyBouquetsState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bouquets.length,
                      itemBuilder: (context, index) {
                        return _buildBouquetCard(_bouquets[index]);
                      },
                    ),
              
              const SizedBox(height: 24),
              
              // Titre de section
              Text(
                'Explorez d\'autres options',
                style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(
                    color: grisTexte,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Options supplémentaires
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Bouquets populaires
                  _buildOptionCard(
                    context: context,
                    icon: Icons.trending_up,
                    title: 'Bouquets populaires',
                    description: 'Découvrez les combinaisons les plus appréciées',
                    color: const Color(0xFF9E7676),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir prochainement'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  
                  // Économies
                  _buildOptionCard(
                    context: context,
                    icon: Icons.savings_outlined,
                    title: 'Vos économies',
                    description: 'Visualisez vos réductions et économies réalisées',
                    color: const Color(0xFFE38B29),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir prochainement'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BouquetCreationScreen(),
            ),
          ).then((_) {
            // Recharger les bouquets lorsque l'utilisateur revient
            _loadBouquets();
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Créer un bouquet',
      ),
    );
  }

  Widget _buildEmptyBouquetsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E4).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFF3E4),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.collections_bookmark_outlined,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun bouquet sauvegardé',
            style: GoogleFonts.playfairDisplay(
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier bouquet en cliquant sur le bouton +',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BouquetCreationScreen(),
                ),
              ).then((_) => _loadBouquets());
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un bouquet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF524B46),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBouquetCard(Map<String, dynamic> bouquet) {
    // Définir une couleur de statut
    Color statusColor;
    String statusText;

    switch (bouquet['status']) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmé';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'En attente';
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Brouillon';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image d'en-tête
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                Image.network(
                  bouquet['image'],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Text(
                    bouquet['name'],
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bouquet['description'],
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoBadge(
                      icon: Icons.people_outline,
                      label: '${bouquet['prestataires']} prestataires',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoBadge(
                      icon: Icons.savings_outlined,
                      label: 'Économie: ${bouquet['savings']} €',
                      color: const Color(0xFF3CB371),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Action pour voir les détails
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Affichage des détails'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Voir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF524B46),
                          side: const BorderSide(color: Color(0xFF524B46)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Action pour modifier
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Modification du bouquet'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Modifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF524B46),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final displayColor = color ?? Colors.grey[700]!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: displayColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: displayColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Comment ça marche ?',
            style: GoogleFonts.playfairDisplay(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpStep(
                  number: '1',
                  title: 'Créez un bouquet',
                  description: 'Sélectionnez au moins 3 prestataires parmi ceux disponibles sur la plateforme.',
                ),
                const SizedBox(height: 16),
                _buildHelpStep(
                  number: '2',
                  title: 'Bénéficiez de réductions',
                  description: 'Obtenez automatiquement des réductions sur le montant total de votre bouquet.',
                ),
                const SizedBox(height: 16),
                _buildHelpStep(
                  number: '3',
                  title: 'Gérez vos demandes',
                  description: 'Suivez l\'évolution de vos demandes et communiquez avec tous vos prestataires en un seul endroit.',
                ),
                const SizedBox(height: 16),
                _buildHelpStep(
                  number: '4',
                  title: 'Facile à modifier',
                  description: 'Vous pouvez modifier votre bouquet à tout moment avant la confirmation finale.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('J\'ai compris'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF524B46),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}