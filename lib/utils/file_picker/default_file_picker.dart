import 'dart:typed_data';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:path/path.dart' as path;
import '../../utils/logger.dart';
import 'file_picker_service.dart';

/// Implémentation par défaut utilisant également image_picker
class DefaultFilePickerService implements FilePickerService {
  final image_picker.ImagePicker _picker = image_picker.ImagePicker();

  @override
  Future<CustomPickedFile?> pickSingleFile({
    List<String>? allowedExtensions,
  }) async {
    try {
      // Pour les plateformes non-iOS, utiliser également image_picker
      // puisque file_picker cause des problèmes
      final image_picker.XFile? file = await _picker.pickImage(
        source: image_picker.ImageSource.gallery,
      );

      if (file == null) return null;

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
      // Pour les images, utiliser pickMultiImage
      final List<image_picker.XFile> images = await _picker.pickMultiImage();
      List<CustomPickedFile> result = [];

      for (var file in images) {
        Uint8List? bytes;
        try {
          bytes = await file.readAsBytes();
        } catch (e) {
          AppLogger.error('Erreur lors de la lecture du fichier', e);
        }

        final fileName = path.basename(file.path);
        final extension = path.extension(file.path).replaceAll('.', '');

        result.add(CustomPickedFile(
          name: fileName,
          bytes: bytes,
          path: file.path,
          mimeType: _getMimeType(extension),
        ));
      }

      return result;
    } catch (e) {
      AppLogger.error('Erreur lors de la sélection multiple', e);
      return [];
    }
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
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
