// lib/User/services/appointment_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/appointment_model.dart';
import 'package:logging/logging.dart';

class AppointmentService {
  final Logger _logger = Logger('AppointmentService');
  final SupabaseClient _supabase = Supabase.instance.client;

  // Création d'un nouveau rendez-vous
Future<bool> createAppointment(AppointmentModel appointment) async {
  try {
    // Vérification de la disponibilité du créneau horaire
    final bool isAvailable = await isTimeSlotAvailable(
      appointment.providerId,
      appointment.appointmentDate,
      appointment.timeSlot,
    );

    if (!isAvailable) {
      _logger.warning('Le créneau horaire n\'est plus disponible');
      return false;
    }

    // Insérer le rendez-vous dans la base de données
    // Adapté pour correspondre aux noms de colonnes dans votre BD
    final response = await _supabase.from('appointments').insert({
      'user_id': appointment.userId,
      'presta_id': appointment.providerId,  // Utilise presta_id
      'presta_name': appointment.providerName,  // Utilise presta_name
      'appointment_date': appointment.appointmentDate.toIso8601String(),
      'status': appointment.status,
      'notes': appointment.notes,
      'time_slot': appointment.timeSlot,
      // Pas besoin d'ajouter provider_type puisqu'il n'existe pas dans la BD
    }).select();

      // Vérifier si l'insertion a réussi
      if (response != null && response.isNotEmpty) {
        _logger.info('Rendez-vous créé avec succès: ${response[0]['id']}');
        
        // Envoyer une notification ou un email de confirmation (implémentation à ajouter)
        _sendAppointmentConfirmation(appointment);
        
        return true;
      } else {
        _logger.warning('Échec de création du rendez-vous');
        return false;
      }
    } catch (e) {
      _logger.severe('Erreur lors de la création du rendez-vous: $e');
      return false;
    }
  }

  // Récupérer tous les rendez-vous d'un utilisateur
  Future<List<AppointmentModel>> getUserAppointments() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser == null) {
        _logger.warning('Aucun utilisateur connecté');
        return [];
      }

      final response = await _supabase
          .from('appointments')
          .select()
          .eq('user_id', currentUser.id)
          .order('appointment_date', ascending: true);

      if (response != null) {
        List<AppointmentModel> appointments = [];
        
        for (var item in response) {
          appointments.add(AppointmentModel.fromJson(item));
        }
        
        return appointments;
      } else {
        return [];
      }
    } catch (e) {
      _logger.severe('Erreur lors de la récupération des rendez-vous: $e');
      return [];
    }
  }

  // Récupérer les rendez-vous à venir d'un utilisateur
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser == null) {
        return [];
      }

      final now = DateTime.now().toUtc().toIso8601String();
      
      final response = await _supabase
          .from('appointments')
          .select()
          .eq('user_id', currentUser.id)
          .eq('status', 'confirmé')
          .gt('appointment_date', now)
          .order('appointment_date', ascending: true);

      if (response != null) {
        List<AppointmentModel> appointments = [];
        
        for (var item in response) {
          appointments.add(AppointmentModel.fromJson(item));
        }
        
        return appointments;
      } else {
        return [];
      }
    } catch (e) {
      _logger.severe('Erreur lors de la récupération des rendez-vous à venir: $e');
      return [];
    }
  }

  // Annuler un rendez-vous
  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final response = await _supabase
          .from('appointments')
          .update({'status': 'annulé'})
          .eq('id', appointmentId)
          .select();

      if (response != null && response.isNotEmpty) {
        _logger.info('Rendez-vous annulé avec succès: $appointmentId');
        return true;
      } else {
        _logger.warning('Échec d\'annulation du rendez-vous: $appointmentId');
        return false;
      }
    } catch (e) {
      _logger.severe('Erreur lors de l\'annulation du rendez-vous: $e');
      return false;
    }
  }

  // Vérifier si un créneau horaire est disponible
Future<bool> isTimeSlotAvailable(String providerId, DateTime date, String timeSlot) async {
  try {
    // Créer la plage horaire pour la vérification
    final startDate = DateTime(date.year, date.month, date.day, 0, 0, 0).toUtc().toIso8601String();
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc().toIso8601String();

    // Adapter pour utiliser presta_id au lieu de provider_id
    final response = await _supabase
        .from('appointments')
        .select()
        .eq('presta_id', providerId)  // Utiliser presta_id
        .eq('time_slot', timeSlot)
        .eq('status', 'confirmé')
        .gte('appointment_date', startDate)
        .lte('appointment_date', endDate);

    // Si aucun rendez-vous n'est trouvé, le créneau est disponible
    return response == null || response.isEmpty;
  } catch (e) {
    _logger.severe('Erreur lors de la vérification du créneau: $e');
    return false;
  }
}

  // Méthode pour envoyer une confirmation (simulation)
  void _sendAppointmentConfirmation(AppointmentModel appointment) {
    // Envoyer un email ou une notification push
    // Cette méthode est une simulation et pourrait être implémentée avec un service d'emails
    _logger.info('Envoi de la confirmation pour le rendez-vous avec ${appointment.providerName}');
  }
}