import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/constants/style_constants.dart';

class AdminPieChartWidget extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final String? subtitle;
  final List<Color> colors;
  final bool showLegend;
  final bool showValues;
  final double radius;

  const AdminPieChartWidget({
    Key? key,
    required this.title,
    required this.data,
    this.subtitle,
    this.colors = const [
      Color(0xFF524B46),
      Color(0xFF8B7E75),
      Color(0xFF3CB371),
      Color(0xFF4682B4),
      Color(0xFFDC3545),
      Color(0xFFFFA500),
      Color(0xFF9370DB),
      Color(0xFF20B2AA),
    ],
    this.showLegend = true,
    this.showValues = true,
    this.radius = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convertir les données en sections de camembert
    final List<PieChartSectionData> sections = [];
    int index = 0;
    double total = 0;

    // Calculer le total
    for (var entry in data.entries) {
      final double value = entry.value is int
          ? (entry.value as int).toDouble()
          : entry.value is double
              ? entry.value
              : 0.0;
      total += value;
    }

    // Créer les sections
    for (var entry in data.entries) {
      final double value = entry.value is int
          ? (entry.value as int).toDouble()
          : entry.value is double
              ? entry.value
              : 0.0;

      if (value > 0) {
        final double percentage = (value / total) * 100;

        sections.add(
          PieChartSectionData(
            color: colors[index % colors.length],
            value: value,
            title: showValues ? '${percentage.toStringAsFixed(1)}%' : '',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }

      index++;
    }

    return Card(
      elevation: PartnerAdminStyles.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(PartnerAdminStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: PartnerAdminStyles.textColor.withAlpha(179),
                  ),
                ),
              ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            Center(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
            if (showLegend)
              const SizedBox(height: PartnerAdminStyles.paddingMedium),
            if (showLegend)
              Wrap(
                spacing: PartnerAdminStyles.paddingMedium,
                runSpacing: PartnerAdminStyles.paddingSmall,
                children: List.generate(data.length, (index) {
                  final entry = data.entries.elementAt(index);
                  final color = colors[index % colors.length];

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PartnerAdminStyles.textColor,
                        ),
                      ),
                    ],
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
