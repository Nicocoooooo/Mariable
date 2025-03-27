class DataPointModel {
  final DateTime date;
  final int value;

  DataPointModel({
    required this.date,
    required this.value,
  });

  factory DataPointModel.fromMap(Map<String, dynamic> map) {
    return DataPointModel(
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      value: map['value'] ?? 0,
    );
  }
}
