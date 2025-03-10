import 'package:equatable/equatable.dart';

class AvisModel extends Equatable {
  final String id;
  final String prestaireId;
  final String? userId;
  final double note;
  final String commentaire;
  final DateTime createdAt;
  final Map<String, dynamic>? profile;

  const AvisModel({
    required this.id,
    required this.prestaireId,
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
      prestaireId: map['prestataire_id'],
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
      'prestataire_id': prestaireId,
      'user_id': userId,
      'note': note,
      'commentaire': commentaire,
      'created_at': createdAt.toIso8601String(),
      'profiles': profile,
    };
  }

  @override
  List<Object?> get props => [id, prestaireId, userId, note, commentaire, createdAt, profile];
}