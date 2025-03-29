import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/user_auth_service.dart';
import '../utils/logger.dart';
import 'package:mariable/routes_user.dart';
import 'package:go_router/go_router.dart';
import '/Prestataires/PrestatairesScreen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  DateTime? _weddingDate;
  String? _errorMessage;
  
  // Liste des tâches de l'utilisateur
  List<Map<String, dynamic>> _userTasks = [];
  
  // Liste des tâches prédéfinies pour le mariage
  final List<String> _predefinedTasks = [
    'Réserver le lieu de réception',
    'Envoyer les invitations',
    'Choisir le traiteur',
    'Réserver le photographe',
    'Réserver le DJ ou groupe de musique',
    'Commander le gâteau de mariage',
    'Choisir les alliances',
    'Préparer la liste de cadeaux',
    'Réserver la voiture de mariage',
    'Choisir les tenues de mariage',
    'Planifier la lune de miel',
    'Organiser la répétition',
    'Réserver l\'officiant',
    'Choisir le fleuriste',
    'Planifier le menu',
  ];
  
  final UserAuthService _authService = UserAuthService();
  
  @override
  void initState() {
    super.initState();
    // Délai léger pour permettre à l'écran de se monter complètement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }
  
  // Méthode pour charger les données de l'utilisateur
  Future<void> _loadUserData() async {
    // Vérifier si le widget est toujours monté
    if (!mounted) return;
    
    // Mettre à jour l'état pour montrer le chargement
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      AppLogger.info("Chargement des données utilisateur pour le dashboard: ${user?.id}");
      
      if (user == null) {
        AppLogger.info("Utilisateur non connecté, redirection vers login");
        if (mounted) {
          context.go(UserRoutes.userLogin);
        }
        return;
      }
      
      // Vérifier si le profil existe déjà
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      // Vérifier si le widget est toujours monté après la requête
      if (!mounted) return;
      
      if (response != null) {
        // Profil trouvé, mettre à jour l'interface
        setState(() {
          _userData = response;
          
          if (response['date_debut_mariage'] != null) {
            _weddingDate = DateTime.parse(response['date_debut_mariage']);
          }
          
          // Initialiser avec des tâches fictives pour l'exemple
          // Dans une vraie implémentation, chargez-les depuis la base de données
          _userTasks = [
            {'id': '1', 'title': 'Réserver le lieu de réception', 'done': true},
            {'id': '2', 'title': 'Envoyer les invitations', 'done': false},
            {'id': '3', 'title': 'Choisir le traiteur', 'done': false},
            {'id': '4', 'title': 'Réserver le photographe', 'done': false},
          ];
          
          _isLoading = false;
        });
      } else {
        // Profil non trouvé, créer un nouveau profil
        try {
          // Créer un profil minimal pour l'utilisateur
          final insertResponse = await Supabase.instance.client.from('profiles').insert({
            'id': user.id,
            'email': user.email,
            'prenom': '',
            'nom': '',
            'status': 'client',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }).select();
          
          // Vérifier à nouveau si le widget est monté
          if (!mounted) return;
          
          // Vérifier si l'insertion a réussi
          if (insertResponse.isNotEmpty) {
            setState(() {
              _userData = insertResponse[0];
              _isLoading = false;
            });
          } else {
            throw Exception("Échec de création du profil utilisateur");
          }
        } catch (insertError) {
          AppLogger.error("Erreur lors de la création du profil", insertError);
          
          // Vérifier si le widget est toujours monté
          if (!mounted) return;
          
          setState(() {
            _errorMessage = 'Erreur lors de la création du profil utilisateur: ${insertError.toString()}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des données utilisateur', e);
      
      // Vérifier si le widget est toujours monté
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données utilisateur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  // Méthode pour se déconnecter
  Future<void> _signOut() async {
    try {
      AppLogger.info("Tentative de déconnexion...");
      await Supabase.instance.client.auth.signOut();
      AppLogger.info("Déconnexion réussie, redirection vers login");
      
      // Vérifier si le widget est toujours monté
      if (!mounted) return;
      
      context.go(UserRoutes.userLogin);
    } catch (e) {
      AppLogger.error('Erreur lors de la déconnexion', e);
      
      // Vérifier si le widget est toujours monté
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: ${e.toString()}')),
      );
    }
  }

  // Widget pour afficher le compte à rebours jusqu'au mariage
  Widget _buildCountdown() {
    if (_weddingDate == null) return const SizedBox.shrink();
    
    // Calcul des jours restants
    final now = DateTime.now();
    final difference = _weddingDate!.difference(now);
    final daysLeft = difference.inDays;
    
    // Couleur en fonction de la proximité de la date
    Color countdownColor = Colors.green;
    if (daysLeft < 30) {
      countdownColor = Colors.red;
    } else if (daysLeft < 90) {
      countdownColor = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: countdownColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: countdownColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_top,
            color: countdownColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            daysLeft > 0
                ? 'Plus que $daysLeft jour${daysLeft > 1 ? 's' : ''} !'
                : daysLeft == 0
                    ? 'C\'est aujourd\'hui !'
                    : 'Votre mariage a déjà eu lieu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: countdownColor,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget pour afficher la liste des tâches
  Widget _buildTasksList() {
    return Column(
      children: [
        for (var task in _userTasks)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: task['done'] ? Colors.green : const Color(0xFF524B46).withOpacity(0.2),
                child: Icon(
                  task['done'] ? Icons.check : Icons.hourglass_empty,
                  color: task['done'] ? Colors.white : const Color(0xFF524B46),
                  size: 14,
                ),
              ),
              title: Text(
                task['title'],
                style: TextStyle(
                  decoration: task['done'] ? TextDecoration.lineThrough : null,
                  color: task['done'] ? Colors.grey : Colors.black,
                ),
              ),
              trailing: task['done']
                  ? null
                  : TextButton(
                      onPressed: () {
                        setState(() {
                          task['done'] = true;
                        });
                        // Dans une vraie implémentation, mettez à jour la base de données
                      },
                      child: const Text('Marquer terminé'),
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        
        // Bouton pour ajouter une tâche
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          child: OutlinedButton.icon(
            onPressed: () => _showAddTaskDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une tâche'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF524B46),
              side: const BorderSide(color: Color(0xFF524B46)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
  
  // Dialogue pour ajouter une nouvelle tâche
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une tâche'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predefinedTasks.length,
              itemBuilder: (context, index) {
                final task = _predefinedTasks[index];
                // Vérifier si la tâche existe déjà
                final bool alreadyExists = _userTasks.any((t) => t['title'] == task);
                
                return ListTile(
                  title: Text(task),
                  enabled: !alreadyExists,
                  onTap: alreadyExists ? null : () {
                    setState(() {
                      _userTasks.add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': task,
                        'done': false,
                      });
                    });
                    Navigator.of(context).pop();
                    // Dans une vraie implémentation, sauvegardez dans la base de données
                  },
                  trailing: alreadyExists 
                    ? const Icon(Icons.check_circle, color: Colors.grey) 
                    : const Icon(Icons.add_circle_outline),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _showCustomTaskDialog();
                Navigator.of(context).pop();
              },
              child: const Text('Tâche personnalisée'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialogue pour ajouter une tâche personnalisée
  void _showCustomTaskDialog() {
    final TextEditingController taskController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tâche personnalisée'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(
              labelText: 'Nom de la tâche',
              hintText: 'Ex: Acheter des accessoires',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  setState(() {
                    _userTasks.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'title': taskController.text,
                      'done': false,
                    });
                  });
                  Navigator.of(context).pop();
                  // Dans une vraie implémentation, sauvegardez dans la base de données
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
  
  // Widget pour afficher la liste des prestataires favoris
  Widget _buildFavoritesList() {
    // Liste vide pour le moment, avec un message
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Vous n\'avez pas encore de prestataires favoris',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Explorez notre catalogue de prestataires et ajoutez-les à vos favoris pour les retrouver ici',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrestatairesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('Explorer les prestataires'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF524B46),
              side: const BorderSide(color: Color(0xFF524B46)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget pour afficher les informations du profil
  Widget _buildProfileSection() {
    // Récupérer les valeurs depuis les données de l'utilisateur
    String fullName = "";
    if (_userData != null) {
      fullName = "${_userData?['prenom'] ?? ''} ${_userData?['nom'] ?? ''}".trim();
      if (fullName.isEmpty) {
        fullName = "Non défini";
      }
    } else {
      fullName = "Non défini";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Informations utilisateur principales
          _buildProfileItem(
            icon: Icons.person,
            label: 'Nom',
            value: fullName,
          ),
          const Divider(height: 24),
          _buildProfileItem(
            icon: Icons.email,
            label: 'Email',
            value: _userData?['email'] ?? 'Non défini',
          ),
          const Divider(height: 24),
          _buildProfileItem(
            icon: Icons.phone,
            label: 'Téléphone',
            value: _userData?['telephone_conjoint'] ?? 'Non défini',
          ),
          
          // Informations sur le conjoint
          if (_userData?['prenom_conjoint'] != null || _userData?['nom_conjoint'] != null) ...[
            const Divider(height: 24),
            _buildProfileItem(
              icon: Icons.people,
              label: 'Conjoint',
              value: "${_userData?['prenom_conjoint'] ?? ''} ${_userData?['nom_conjoint'] ?? ''}".trim(),
            ),
          ],
          
          if (_userData?['email_conjoint'] != null) ...[
            const Divider(height: 24),
            _buildProfileItem(
              icon: Icons.email_outlined,
              label: 'Email du conjoint',
              value: _userData?['email_conjoint'],
            ),
          ],
          
          // Informations sur le mariage
          if (_userData?['region'] != null) ...[
            const Divider(height: 24),
            _buildProfileItem(
              icon: Icons.location_on,
              label: 'Région',
              value: _userData?['region'],
            ),
          ],
          
          if (_userData?['budget_total'] != null) ...[
            const Divider(height: 24),
            _buildProfileItem(
              icon: Icons.euro,
              label: 'Budget',
              value: "${_userData?['budget_total']} €",
            ),
          ],
          
          if (_userData?['nombre_invites'] != null) ...[
            const Divider(height: 24),
            _buildProfileItem(
              icon: Icons.group,
              label: 'Nombre d\'invités',
              value: "${_userData?['nombre_invites']}",
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Bouton modifier profil
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCompleteProfileDialog(),
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper pour les items du profil
  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF524B46),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Dialogue pour compléter le profil
  void _showCompleteProfileDialog() {
    final formKey = GlobalKey<FormState>();
    final prenomController = TextEditingController(text: _userData?['prenom'] ?? '');
    final nomController = TextEditingController(text: _userData?['nom'] ?? '');
    final prenomConjointController = TextEditingController(text: _userData?['prenom_conjoint'] ?? '');
    final nomConjointController = TextEditingController(text: _userData?['nom_conjoint'] ?? '');
    final emailConjointController = TextEditingController(text: _userData?['email_conjoint'] ?? '');
    final telephoneController = TextEditingController(text: _userData?['telephone_conjoint'] ?? '');
    final invitesController = TextEditingController(text: _userData?['nombre_invites']?.toString() ?? '');
    
    // Valeurs sélectionnées pour les dropdowns
    String? selectedRegion = _userData?['region'];
    double? selectedBudget = _userData?['budget_total'];
    
    // Liste des régions françaises
    final List<String> regions = [
      'Auvergne-Rhône-Alpes',
      'Bourgogne-Franche-Comté',
      'Bretagne',
      'Centre-Val de Loire',
      'Corse',
      'Grand Est',
      'Hauts-de-France',
      'Île-de-France',
      'Normandie',
      'Nouvelle-Aquitaine',
      'Occitanie',
      'Pays de la Loire',
      'Provence-Alpes-Côte d\'Azur',
      'Guadeloupe',
      'Martinique',
      'Guyane',
      'La Réunion',
      'Mayotte',
    ];
    
    // Options de budget (par tranche de 5K€)
    final List<double> budgetOptions = [
      10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 
      60000, 70000, 80000, 90000, 100000, 150000, 200000
    ];
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFFFFF3E4).withOpacity(0.95),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre principal avec style élégant
                      Center(
                        child: Text(
                          'Personnaliser votre profil',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF524B46),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Informations personnelles
                      Text(
                        'Vos informations',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF524B46),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ prénom amélioré
                      Text(
                        'Prénom',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: prenomController,
                        decoration: InputDecoration(
                          hintText: 'Votre prénom',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF524B46)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ nom amélioré
                      Text(
                        'Nom',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: nomController,
                        decoration: InputDecoration(
                          hintText: 'Votre nom',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF524B46)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ téléphone amélioré
                      Text(
                        'Téléphone',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: telephoneController,
                        decoration: InputDecoration(
                          hintText: 'Votre numéro de téléphone',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF524B46)),
                          ),
                          prefixIcon: const Icon(Icons.phone, color: Color(0xFF524B46)),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Informations du conjoint
                      Text(
                        'Informations du conjoint',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF524B46),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ prénom du conjoint
                      Text(
                        'Prénom du conjoint',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: prenomConjointController,
                        decoration: InputDecoration(
                          hintText: 'Prénom du conjoint',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF524B46)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ nom du conjoint
                      Text(
                        'Nom du conjoint',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: nomConjointController,
                        decoration: InputDecoration(
                          hintText: 'Nom du conjoint',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF524B46)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ email du conjoint
                      Text(
                        'Email du conjoint',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: emailConjointController,
                        decoration: InputDecoration(
                          hintText: 'Email du conjoint',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF524B46)),
                          ),
                          prefixIcon: const Icon(Icons.email, color: Color(0xFF524B46)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Informations du mariage
                      Text(
                        'Informations du mariage',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF524B46),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Sélection de région avec dropdown
                      Text(
                        'Région du mariage',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.location_on, color: Color(0xFF524B46)),
                            ),
                            value: selectedRegion,
                            hint: const Text('Sélectionnez une région'),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF524B46)),
                            items: regions.map<DropdownMenuItem<String>>((String region) {
                              return DropdownMenuItem<String>(
                                value: region,
                                child: Text(region),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              selectedRegion = newValue;
                            },
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Sélection de budget avec dropdown
                      Text(
                        'Budget total estimé',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<double>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.euro, color: Color(0xFF524B46)),
                            ),
                            value: selectedBudget,
                            hint: const Text('Sélectionnez un budget'),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF524B46)),
                            items: budgetOptions.map<DropdownMenuItem<double>>((double budget) {
                              return DropdownMenuItem<double>(
                                value: budget,
                                child: Text(NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0).format(budget)),
                              );
                            }).toList(),
                            onChanged: (double? newValue) {
                              selectedBudget = newValue;
                            },
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nombre d'invités
                      Text(
                        'Nombre d\'invités',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: invitesController,
                        decoration: InputDecoration(
                          hintText: 'Nombre approximatif d\'invités',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF524B46)),
                          ),
                          prefixIcon: const Icon(Icons.people, color: Color(0xFF524B46)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Boutons d'action alignés à droite
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Bouton annuler
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 16),
                          // Bouton enregistrer
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                Navigator.of(context).pop();
                                
                                // Vérifier si le widget est monté avant de mettre à jour l'état
                                if (!mounted) return;
                                
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  final user = Supabase.instance.client.auth.currentUser;
                                  if (user != null) {
                                    // Préparer les données à mettre à jour
                                    final Map<String, dynamic> updateData = {
                                      'prenom': prenomController.text,
                                      'nom': nomController.text,
                                      'telephone_conjoint': telephoneController.text,
                                      'prenom_conjoint': prenomConjointController.text,
                                      'nom_conjoint': nomConjointController.text,
                                      'email_conjoint': emailConjointController.text,
                                      'region': selectedRegion,
                                      'budget_total': selectedBudget,
                                      'updated_at': DateTime.now().toIso8601String(),
                                    };
                                    
                                    // Ajouter nombre d'invités s'il est numérique
                                    if (invitesController.text.isNotEmpty) {
                                      updateData['nombre_invites'] = int.tryParse(invitesController.text);
                                    }
                                    
                                    // Mettre à jour dans la base de données
                                    await Supabase.instance.client
                                        .from('profiles')
                                        .update(updateData)
                                        .eq('id', user.id);
                                    
                                    // Recharger les données
                                    await _loadUserData();
                                    
                                    // Vérifier si le widget est monté avant d'afficher le SnackBar
                                    if (!mounted) return;
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Profil mis à jour avec succès'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  AppLogger.error('Erreur lors de la mise à jour du profil', e);
                                  
                                  // Vérifier si le widget est monté avant de mettre à jour l'état
                                  if (!mounted) return;
                                  
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF524B46),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Enregistrer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Méthode pour sélectionner la date du mariage
  Future<void> _selectWeddingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _weddingDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF524B46),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2B2B2B),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      // Vérifier si le widget est monté avant de mettre à jour l'état
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Mettre à jour la date de mariage dans la base de données
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          await Supabase.instance.client
              .from('profiles')
              .update({'date_debut_mariage': picked.toIso8601String()})
              .eq('id', user.id);
          
          // Vérifier si le widget est monté avant de mettre à jour l'état
          if (!mounted) return;
          
          setState(() {
            _weddingDate = picked;
          });
        }
      } catch (e) {
        AppLogger.error('Erreur lors de la mise à jour de la date de mariage', e);
        
        // Vérifier si le widget est monté avant de mettre à jour l'état
        if (!mounted) return;
        
        setState(() {
          _errorMessage = 'Erreur lors de la mise à jour de la date de mariage: ${e.toString()}';
        });
      } finally {
        // Vérifier si le widget est monté avant de mettre à jour l'état
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Barre de navigation
  Widget _buildBottomNavigationBar(Color grisTexte, Color accentColor) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.search, 'Prestataires', grisTexte, onTap: () {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrestatairesScreen(),
            ),
           );
          }),
          _buildNavItem(Icons.favorite_border, 'Favoris', grisTexte),
          _buildNavItem(Icons.home, 'Accueil', grisTexte, onTap: () {
            context.go('/');
          }),
          _buildNavItem(Icons.shopping_bag_outlined, 'Bouquet', grisTexte),
          _buildNavItem(Icons.person_outline, 'Profil', accentColor, isSelected: true),
        ],
      ),
    );
  }

  // Élément de la barre de navigation
  Widget _buildNavItem(IconData icon, String label, Color color, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? color : color.withOpacity(0.5),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : color.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la DA
    const Color accentColor = Color(0xFF524B46);
    const Color grisTexte = Color(0xFF2B2B2B);
    const Color beige = Color(0xFFFFF3E4);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon espace mariage'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  color: accentColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête avec salutation et date de mariage
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: beige.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Salutation avec prénom et nom
                                Text(
                                  'Bienvenue, ${_userData?['prenom'] ?? ''} ${_userData?['nom'] ?? 'Utilisateur'}',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Date de mariage ou message si non définie
                                if (_weddingDate != null) ...[
                                  Text(
                                    'Votre grand jour',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: grisTexte,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: accentColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('dd MMMM yyyy', 'fr_FR').format(_weddingDate!),
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: accentColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Bouton pour modifier la date
                                      TextButton.icon(
                                        onPressed: () => _selectWeddingDate(context),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Modifier'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: accentColor,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Compte à rebours
                                  _buildCountdown(),
                                ] else ...[
                                  Text(
                                    'Vous n\'avez pas encore défini la date de votre mariage',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      color: grisTexte,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _selectWeddingDate(context),
                                      icon: const Icon(Icons.calendar_today),
                                      label: const Text('Choisir une date'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Section Tâches à faire
                          Text(
                            'Vos tâches à faire',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Liste des tâches
                          _buildTasksList(),
                          
                          const SizedBox(height: 24),
                          
                          
                          // Section Profil
                          Text(
                            'Votre profil',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Informations du profil
                          _buildProfileSection(),
                          
                          // Ajouter de l'espace en bas pour éviter que la navbar cache du contenu
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
      // Ajouter la barre de navigation
      bottomNavigationBar: _buildBottomNavigationBar(grisTexte, accentColor),
    );
  }
}