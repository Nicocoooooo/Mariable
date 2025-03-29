// lib/Partner/widgets/stats/period_selector.dart
import 'package:flutter/material.dart';
import '../../../shared/constants/style_constants.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final List<String> periods;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.periods = const ['7j', '14j', '30j', '90j', 'Tout'],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Text(
              'Période :',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PartnerAdminStyles.textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: periods
                      .map(
                        (period) => _buildPeriodChip(period),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final bool isSelected = selectedPeriod == period;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(period),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onPeriodChanged(period);
          }
        },
        selectedColor: PartnerAdminStyles.accentColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected
              ? PartnerAdminStyles.accentColor
              : PartnerAdminStyles.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
