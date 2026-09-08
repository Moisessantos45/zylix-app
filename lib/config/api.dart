import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zylix/config/config.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:zylix/presentation/utils/compare_version.dart';

class Api {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  static Future<void> initializeVersion() async {
    debugPrint("Obteniendo versión de la aplicación... ${Config.API_URL}");
    if (Config.API_URL.isEmpty) {
      debugPrint("ERROR: API_URL vacío, abortando...");
      return;
    }

    final version = await NativeBridge.getAppVersion();
    debugPrint("Versión local instalada: $version");
    if (version == null) return;

    final currentVersion = version['version'] ?? "1.0.0";
    await checkVersion(currentVersion);
  }

  static Future<void> checkVersion(String currentVersion) async {
    try {
      final response = await _dio.get(
        '${Config.API_URL}/version/zylix',
        queryParameters: {'platforms': 'android'},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final fileData = response.data['data'];
        final String fileName = fileData['name'] ?? '';

        final remoteVersion = extractVersionFromName(fileName);

        debugPrint(
          "Versión remota: $remoteVersion | Versión local: $currentVersion",
        );

        if (remoteVersion.isNotEmpty &&
            compareVersions(remoteVersion, currentVersion) > 0) {
          await NativeBridge.showNotification(
            "Actualización disponible",
            "Nueva versión $remoteVersion disponible. ¡Actualiza ahora!",
            "update_available",
          );
        } else {
          debugPrint(
            "La aplicación ya se encuentra en la última versión ($currentVersion).",
          );
        }
      }

      debugPrint('Versión verificada correctamente');
    } on DioException catch (e) {
      debugPrint('Error de red al consultar versión: ${e.message}');
    } catch (e) {
      debugPrint('Error al verificar la versión: $e');
    }
  }
}
