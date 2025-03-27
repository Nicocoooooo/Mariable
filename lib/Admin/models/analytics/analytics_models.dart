import 'package:equatable/equatable.dart';

/// Modèle pour les données analytiques des utilisateurs
class UserAnalytics extends Equatable {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> newUsersByMonth;

  const UserAnalytics({
    required this.total,
    required this.byStatus,
    required this.newUsersByMonth,
  });

  factory UserAnalytics.fromMap(Map<String, dynamic> map) {
    return UserAnalytics(
      total: map['total'] ?? 0,
      byStatus: Map<String, int>.from(map['byStatus'] ?? {}),
      newUsersByMonth: Map<String, int>.from(map['newUsersByMonth'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [total, byStatus, newUsersByMonth];
}

/// Modèle pour les données analytiques des prestataires
class PartnerAnalytics extends Equatable {
  final int total;
  final Map<String, int> byType;
  final Map<String, int> byRegion;
  final Map<String, int> byBudget;
  final Map<String, Map<String, dynamic>> verificationRateByType;

  const PartnerAnalytics({
    required this.total,
    required this.byType,
    required this.byRegion,
    required this.byBudget,
    required this.verificationRateByType,
  });

  factory PartnerAnalytics.fromMap(Map<String, dynamic> map) {
    return PartnerAnalytics(
      total: map['total'] ?? 0,
      byType: Map<String, int>.from(map['byType'] ?? {}),
      byRegion: Map<String, int>.from(map['byRegion'] ?? {}),
      byBudget: Map<String, int>.from(map['byBudget'] ?? {}),
      verificationRateByType: Map<String, Map<String, dynamic>>.from(
        map['verificationRateByType']?.map(
              (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
            ) ??
            {},
      ),
    );
  }

  @override
  List<Object?> get props =>
      [total, byType, byRegion, byBudget, verificationRateByType];
}

/// Modèle pour les données analytiques des réservations
class ReservationAnalytics extends Equatable {
  final int total;
  final Map<String, dynamic> byMonth;
  final Map<String, dynamic> revenueByMonth;
  final Map<String, int> byStatus;
  final Map<String, int> byPartnerType;
  final Map<String, int> topPartners;

  const ReservationAnalytics({
    required this.total,
    required this.byMonth,
    required this.revenueByMonth,
    required this.byStatus,
    required this.byPartnerType,
    required this.topPartners,
  });

  factory ReservationAnalytics.fromMap(Map<String, dynamic> map) {
    return ReservationAnalytics(
      total: map['total'] ?? 0,
      byMonth: Map<String, dynamic>.from(map['byMonth'] ?? {}),
      revenueByMonth: Map<String, dynamic>.from(map['revenueByMonth'] ?? {}),
      byStatus: Map<String, int>.from(map['byStatus'] ?? {}),
      byPartnerType: Map<String, int>.from(map['byPartnerType'] ?? {}),
      topPartners: Map<String, int>.from(map['topPartners'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        total,
        byMonth,
        revenueByMonth,
        byStatus,
        byPartnerType,
        topPartners,
      ];
}
