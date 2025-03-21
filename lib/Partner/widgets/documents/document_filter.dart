import 'package:flutter/material.dart';
import '../../../shared/constants/style_constants.dart';

class DocumentFilter extends StatelessWidget {
  final String? selectedType;
  final String? selectedStatus;
  final Function(String?) onTypeChanged;
  final Function(String?) onStatusChanged;

  const DocumentFilter({
    Key? key,
    this.selectedType,
    this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrer les documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PartnerAdminStyles.accentColor,
            ),
          ),
          const SizedBox(height: 16),

          // Filtre par type
          const Text(
            'Type de document',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: PartnerAdminStyles.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip('Tous', null),
              _buildTypeChip('Contrat', 'contrat'),
              _buildTypeChip('Facture', 'facture'),
              _buildTypeChip('Devis', 'devis'),
              _buildTypeChip('Photo', 'photo'),
              _buildTypeChip('Autre', 'autre'),
            ],
          ),

          const SizedBox(height: 16),

          // Filtre par statut
          const Text(
            'Statut',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: PartnerAdminStyles.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip('Tous', null),
              _buildStatusChip('Actif', 'active'),
              _buildStatusChip('Brouillon', 'draft'),
              _buildStatusChip('Archivé', 'archived'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String? value) {
    final bool isSelected = selectedType == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onTypeChanged(selected ? value : null);
      },
      selectedColor: PartnerAdminStyles.accentColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? PartnerAdminStyles.accentColor
            : PartnerAdminStyles.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatusChip(String label, String? value) {
    final bool isSelected = selectedStatus == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onStatusChanged(selected ? value : null);
      },
      selectedColor: PartnerAdminStyles.accentColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? PartnerAdminStyles.accentColor
            : PartnerAdminStyles.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
