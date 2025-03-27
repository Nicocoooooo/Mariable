import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/constants/style_constants.dart';

class AdminBarChartWidget extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final String? subtitle;
  final double minY;
  final double maxY;
  final bool showValues;
  final List<Color> gradientColors;

  const AdminBarChartWidget({
    Key? key,
    required this.title,
    required this.data,
    this.subtitle,
    this.minY = 0,
    this.maxY = 100,
    this.showValues = true,
    this.gradientColors = const [Color(0xFF524B46), Color(0xFF8B7E75)],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convertir les données en BarChartGroupData
    final List<BarChartGroupData> barGroups = [];
    int index = 0;

    for (var entry in data.entries) {
      final double value = entry.value is int
          ? (entry.value as int).toDouble()
          : entry.value is double
              ? entry.value
              : 0.0;

      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
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
                    color: PartnerAdminStyles.textColor.withOpacity(0.7),
                  ),
                ),
              ),
            const SizedBox(height: PartnerAdminStyles.paddingMedium),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: minY,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= data.keys.length) {
                            return const SizedBox();
                          }
                          final String label = data.keys.elementAt(index);
                          // Formater l'étiquette si c'est une date (YYYY-MM)
                          String displayLabel = label;
                          if (label.contains('-') && label.length >= 7) {
                            final components = label.split('-');
                            if (components.length >= 2) {
                              displayLabel =
                                  '${components[1]}/${components[0].substring(2)}';
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              displayLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                color: PartnerAdminStyles.textColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: PartnerAdminStyles.textColor,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            if (showValues)
              const SizedBox(height: PartnerAdminStyles.paddingMedium),
            if (showValues)
              Wrap(
                spacing: PartnerAdminStyles.paddingSmall,
                runSpacing: PartnerAdminStyles.paddingSmall,
                children: data.entries.map((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: gradientColors[0],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
