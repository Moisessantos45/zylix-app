import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zylix/config/config.dart';
import 'package:zylix/config/service/native_bridge.dart';

class Api {
  static Future<void> initializeVersion() async {
    debugPrint("Obteniendo versión de la aplicación... ${Config.API_URL}");
    if (Config.API_URL.isEmpty) {
      debugPrint("ERROR: API_URL vacío, abortando...");
      return;
    }

    final version = await NativeBridge.getAppVersion();
    debugPrint("Version: $version");
    if (version == null) return;
    final versionCode = version['version'] ?? "1.0.0";
    await checkVersion(versionCode);
  }

  static Future<void> checkVersion(String versionCode) async {
    try {
      final dio = Dio();

      final response = await dio.get(
        '${Config.API_URL}/version-check',
        queryParameters: {'app': 'zylix-$versionCode'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("Version: $data");
        if (data['data'] != null && data['data']['codeVersion'] != null) {
          if (data['data']['codeVersion'] != versionCode) {
            await NativeBridge.showNotification(
              "Actualización disponible",
              "Nueva versión ${data['data']['codeVersion']} disponible. ¡Actualiza ahora!",
              "update_available",
            );
          }
        }
      }
      debugPrint('Versión verificada correctamente');
    } catch (e) {
      debugPrint('Error al verificar la versión: $e');
    }
  }
}
