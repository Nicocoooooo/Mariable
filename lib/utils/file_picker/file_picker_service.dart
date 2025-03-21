import 'package:flutter/foundation.dart';
import 'dart:typed_data';

import 'default_file_picker.dart';
import 'ios_file_picker.dart';

/// Modèle représentant un fichier sélectionné
class CustomPickedFile {
  final String name;
  final Uint8List? bytes;
  final String? path;
  final String? mimeType;

  CustomPickedFile({
    required this.name,
    this.bytes,
    this.path,
    this.mimeType,
  });
}

/// Service abstrait pour la sélection de fichiers
abstract class FilePickerService {
  /// Sélectionne un seul fichier
  Future<CustomPickedFile?> pickSingleFile({
    List<String>? allowedExtensions,
  });

  /// Sélectionne plusieurs fichiers
  Future<List<CustomPickedFile>> pickMultipleFiles({
    List<String>? allowedExtensions,
  });

  /// Factory qui retourne l'implémentation appropriée selon la plateforme
  factory FilePickerService() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IOSFilePickerService();
    } else {
      return DefaultFilePickerService();
    }
  }
}
