import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:path/path.dart' as path;
import '../../utils/logger.dart';
import 'file_picker_service.dart';

/// Implémentation spécifique pour iOS utilisant image_picker
class IOSFilePickerService implements FilePickerService {
  final image_picker.ImagePicker _picker = image_picker.ImagePicker();

  @override
  Future<CustomPickedFile?> pickSingleFile({
    List<String>? allowedExtensions,
  }) async {
    try {
      // Déterminer si on sélectionne une image ou un document
      if (_isImageExtensions(allowedExtensions)) {
        return await _pickImageFile();
      } else {
        // Pour les autres types de fichiers, utiliser la galerie comme fallback
        return await _pickDocumentFile();
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la sélection du fichier', e);
      return null;
    }
  }

  @override
  Future<List<CustomPickedFile>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    try {
      // Pour les images, nous pouvons utiliser image_picker
      if (_isImageExtensions(allowedExtensions)) {
        final List<image_picker.XFile> images = await _picker.pickMultiImage();
        return _convertXFilesToPickedFiles(images);
      } else {
        // Pour les autres types, une seule sélection
        final singleFile = await _pickDocumentFile();
        return singleFile != null ? [singleFile] : [];
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la sélection multiple', e);
      return [];
    }
  }

  /// Vérifie si les extensions autorisées sont principalement des images
  bool _isImageExtensions(List<String>? extensions) {
    if (extensions == null || extensions.isEmpty) {
      return true; // Par défaut, considérer comme des images
    }

    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'heic'];
    final matchingExtensions = extensions
        .map((e) => e.toLowerCase())
        .where((e) => imageExtensions.contains(e))
        .length;

    // Si plus de la moitié sont des images, utiliser le picker d'images
    return matchingExtensions / extensions.length > 0.5;
  }

  /// Sélectionne une image depuis la galerie
  Future<CustomPickedFile?> _pickImageFile() async {
    final image_picker.XFile? image = await _picker.pickImage(
      source: image_picker.ImageSource.gallery,
    );

    if (image == null) return null;

    return _convertXFileToPickedFile(image);
  }

  /// Sélectionne un document (utilise la galerie comme fallback)
  Future<CustomPickedFile?> _pickDocumentFile() async {
    // Pour iOS, nous utilisons la galerie comme fallback
    final image_picker.XFile? file = await _picker.pickImage(
      source: image_picker.ImageSource.gallery,
    );

    if (file == null) return null;

    return _convertXFileToPickedFile(file);
  }

  /// Convertit un XFile en CustomPickedFile
  Future<CustomPickedFile> _convertXFileToPickedFile(
      image_picker.XFile file) async {
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      AppLogger.error('Erreur lors de la lecture du fichier', e);
    }

    final fileName = path.basename(file.path);
    final extension = path.extension(file.path).replaceAll('.', '');

    return CustomPickedFile(
      name: fileName,
      bytes: bytes,
      path: file.path,
      mimeType: _getMimeType(extension),
    );
  }

  /// Convertit une liste de XFile en liste de CustomPickedFile
  Future<List<CustomPickedFile>> _convertXFilesToPickedFiles(
      List<image_picker.XFile> files) async {
    List<CustomPickedFile> result = [];

    for (var file in files) {
      final pickedFile = await _convertXFileToPickedFile(file);
      result.add(pickedFile);
    }

    return result;
  }

  /// Détermine le type MIME basé sur l'extension
  String _getMimeType(String extension) {
    final ext = extension.toLowerCase();

    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
