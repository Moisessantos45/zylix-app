import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ApkCleaner {
  static Future<void> cleanOldApks() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null && await directory.exists()) {
        final List<FileSystemEntity> entities = await directory.list().toList();
        for (final entity in entities) {
          if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
            try {
              await entity.delete();
              debugPrint('🧹 APK residual eliminado con éxito: ${entity.path}');
            } catch (e) {
              debugPrint('⚠️ No se pudo eliminar el archivo ${entity.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error al limpiar APKs residuales: $e');
    }
  }
}
