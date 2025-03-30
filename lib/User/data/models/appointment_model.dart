// lib/User/data/models/appointment_model.dart

class AppointmentModel {
  final String id;
  final String userId;
  final String providerId;
  final String providerName;
  final String providerType;
  final DateTime appointmentDate;
  final String status;
  final DateTime createdAt;
  final String notes;
  final String timeSlot;
  final String providerImageUrl;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    this.providerType = '',
    required this.appointmentDate,
    required this.status,
    required this.createdAt,
    required this.notes,
    required this.timeSlot,
    this.providerImageUrl = '',
  });

  // Constructeur pour créer un objet à partir de JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      providerId: json['presta_id'] ?? '',
      providerName: json['presta_name'] ?? '',
      providerType: json['presta_type'] ?? '',
      appointmentDate: json['appointment_date'] != null 
          ? DateTime.parse(json['appointment_date']) 
          : DateTime.now(),
      status: json['status'] ?? 'confirmé',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      notes: json['notes'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      providerImageUrl: json['provider_image_url'] ?? '',
    );
  }

  // Méthode pour convertir l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'presta_id': providerId,
      'presta_name': providerName,
      'presta_type': providerType,
      'appointment_date': appointmentDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
      'time_slot': timeSlot,
    };
  }

  // Méthode pour créer une copie de l'objet avec des modifications
  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? providerName,
    String? providerType,
    DateTime? appointmentDate,
    String? status,
    DateTime? createdAt,
    String? notes,
    String? timeSlot,
    String? providerImageUrl,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerType: providerType ?? this.providerType,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      timeSlot: timeSlot ?? this.timeSlot,
      providerImageUrl: providerImageUrl ?? this.providerImageUrl,
    );
  }
}