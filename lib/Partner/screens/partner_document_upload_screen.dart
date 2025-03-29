import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/constants/style_constants.dart';
import '../../utils/logger.dart';
import '../services/document_service.dart';

class PartnerDocumentUploadScreen extends StatefulWidget {
  final String fileName;
  final Uint8List fileBytes;
  final String fileType;
  final String partnerId;
  final VoidCallback onUploadComplete;

  const PartnerDocumentUploadScreen({
    super.key,
    required this.fileName,
    required this.fileBytes,
    required this.fileType,
    required this.partnerId,
    required this.onUploadComplete,
  });

  @override
  State<PartnerDocumentUploadScreen> createState() =>
      _PartnerDocumentUploadScreenState();
}

class _PartnerDocumentUploadScreenState
    extends State<PartnerDocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final DocumentService _documentService = DocumentService();

  late TextEditingController _typeController;
  late String _selectedType;
  String? _reservationId;
  bool _isUploading = false;
  String? _errorMessage;

  final List<String> _documentTypes = [
    'contrat',
    'facture',
    'devis',
    'photo',
    'autre',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.fileType;
    _typeController = TextEditingController(text: widget.fileType);
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      await _documentService.uploadDocument(
        partnerId: widget.partnerId,
        fileName: widget.fileName,
        fileBytes: widget.fileBytes,
        type: _selectedType,
        reservationId: _reservationId,
      );

      widget.onUploadComplete();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      AppLogger.error('Erreur lors du téléchargement du document', e);
      setState(() {
        _errorMessage =
            'Une erreur est survenue lors du téléchargement du document';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Télécharger un document',
      ),
      body: _isUploading
          ? const LoadingIndicator(message: 'Téléchargement en cours...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Infos du fichier
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PartnerAdminStyles.beige.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PartnerAdminStyles.beige,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations du fichier',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: PartnerAdminStyles.accentColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Nom du fichier
                          Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                size: 18,
                                color: PartnerAdminStyles.textColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.fileName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: PartnerAdminStyles.textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Taille du fichier
                          Row(
                            children: [
                              const Icon(
                                Icons.data_usage,
                                size: 18,
                                color: PartnerAdminStyles.textColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(widget.fileBytes.length / 1024).toStringAsFixed(2)} Ko',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: PartnerAdminStyles.textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),

                    const Text(
                      'Type de document',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: PartnerAdminStyles.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Sélection du type
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: PartnerAdminStyles.defaultInputDecoration(
                        'Type',
                        prefixIcon: const Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un type de document';
                        }
                        return null;
                      },
                      items: _documentTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.substring(0, 1).toUpperCase() +
                              type.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Réservation associée (optionnel)
                    const Text(
                      'Réservation associée (optionnel)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: PartnerAdminStyles.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Laissez vide si ce document n\'est pas lié à une réservation spécifique.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Champ pour la réservation (dans une version future, cela pourrait être un dropdown)
                    TextFormField(
                      decoration: PartnerAdminStyles.defaultInputDecoration(
                        'ID de réservation',
                        hint: 'Optionnel',
                        prefixIcon: const Icon(Icons.event_note),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _reservationId = value.isEmpty ? null : value;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Bouton de téléchargement
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploadDocument,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('TÉLÉCHARGER'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PartnerAdminStyles.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
