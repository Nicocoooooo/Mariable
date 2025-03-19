import 'package:equatable/equatable.dart';

class AvisModel extends Equatable {
  final String id;
  final String prestataireId; // ID du prestataire (lieu, traiteur, etc.)
  final String? userId;      // ID de l'utilisateur qui a laissé l'avis
  final double note;
  final String commentaire;
  final DateTime createdAt;
  final Map<String, dynamic>? profile; // Infos de l'utilisateur (optionnel)

  const AvisModel({
    required this.id,
    required this.prestataireId,
    this.userId,
    required this.note,
    required this.commentaire,
    required this.createdAt,
    this.profile,
  });

  /// Création à partir d'une Map (réponse Supabase)
  factory AvisModel.fromMap(Map<String, dynamic> map) {
    return AvisModel(
      id: map['id'],
      prestataireId: map['prestataire_id'],
      userId: map['user_id'],
      note: map['note'] is int ? (map['note'] as int).toDouble() : map['note'],
      commentaire: map['commentaire'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      profile: map['profiles'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prestataire_id': prestataireId,
      'user_id': userId,
      'note': note,
      'commentaire': commentaire,
      'created_at': createdAt.toIso8601String(),
      'profiles': profile,
    };
  }

  @override
  List<Object?> get props => [id, prestataireId, userId, note, commentaire, createdAt, profile];
}
