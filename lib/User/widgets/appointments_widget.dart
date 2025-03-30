import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentsWidget extends StatefulWidget {
  final bool showAllAppointments;
  final int maxToShow;
  final VoidCallback? onViewAllTap;

  // Modification du constructeur pour inclure les paramètres manquants
  const AppointmentsWidget({
    Key? key,
    this.showAllAppointments = false,
    this.maxToShow = 3,
    this.onViewAllTap,
  }) : super(key: key);

  @override
  State<AppointmentsWidget> createState() => _AppointmentsWidgetState();
}
class _AppointmentsWidgetState extends State<AppointmentsWidget> {
  final AppointmentService _appointmentService = AppointmentService();
  bool _isLoading = true;
  List<AppointmentModel> _appointments = [];
  
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }
  
  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appointments = await _appointmentService.getUserAppointments();
      
      // Ne montre que les rendez-vous à venir et non annulés
      final upcomingAppointments = appointments.where((app) => 
        app.appointmentDate.isAfter(DateTime.now()) && 
        app.status != 'annulé'
      ).toList();
      
      setState(() {
        _appointments = upcomingAppointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _cancelAppointment(String appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content: const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      final success = await _appointmentService.cancelAppointment(appointmentId);
      
      if (success) {
        _loadAppointments(); // Recharger la liste
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rendez-vous annulé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'annulation du rendez-vous'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

@override
Widget build(BuildContext context) {
  return Container(
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
    child: _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                color: Color(0xFF524B46),
              ),
            ),
          )
        : _appointments.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Empêche le défilement
                itemCount: widget.showAllAppointments 
                    ? _appointments.length
                    : _appointments.length < widget.maxToShow 
                        ? _appointments.length 
                        : widget.maxToShow,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(_appointments[index]);
                },
              ),
  );
}
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Vous n\'avez pas de rendez-vous à venir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Explorez notre catalogue de prestataires et prenez rendez-vous pour visiter les lieux ou rencontrer des professionnels',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Naviguer vers la page des prestataires
              Navigator.pushNamed(context, '/prestataires');
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
  
  Widget _buildAppointmentCard(AppointmentModel appointment) {
    // Formater la date
    final DateFormat dateFormatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final String formattedDate = dateFormatter.format(appointment.appointmentDate);
    
    // Vérifier si providerImageUrl existe, sinon utiliser une chaîne vide
    final String providerImageUrl = appointment.providerImageUrl ?? '';
    
    // Vérifier si providerType existe, sinon utiliser une valeur par défaut
    final String providerType = appointment.providerType.isNotEmpty 
        ? appointment.providerType 
        : 'Prestataire';
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec le nom du prestataire
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Image ou avatar du prestataire
                CircleAvatar(
                  backgroundColor: const Color(0xFF524B46).withOpacity(0.2),
                  radius: 20,
                  child: providerImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            providerImageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Text(appointment.providerName.isNotEmpty 
                                    ? appointment.providerName[0].toUpperCase() 
                                    : 'P'),
                          ),
                        )
                      : Text(
                          appointment.providerName.isNotEmpty
                              ? appointment.providerName[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            color: Color(0xFF524B46),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Nom et type du prestataire
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.providerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        providerType,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Détails du rendez-vous
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date et heure
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF524B46),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date du rendez-vous',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$formattedDate à ${appointment.timeSlot}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Statut du rendez-vous
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF524B46),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            appointment.status == 'confirmé' ? 'Confirmé' : 
                              (appointment.status == 'annulé' ? 'Annulé' : 'En attente'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appointment.status == 'confirmé' 
                                  ? Colors.green 
                                  : (appointment.status == 'annulé' ? Colors.red : Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bouton d'annulation (seulement si le rendez-vous n'est pas déjà annulé)
                if (appointment.status != 'annulé')
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _cancelAppointment(appointment.id),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                      label: const Text(
                        'Annuler le rendez-vous',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}