import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.example.zylix/channel',
  );

  static Future<Uint8List> getBytesFromUri(String uriString) async {
    try {
      final result = await _channel.invokeMethod('getBytesFromUri', {
        'uri': uriString,
      });
      return result as Uint8List;
    } catch (e) {
      throw Exception('Error leyendo URI: $e');
    }
  }

  static Future<List<String>> pickMultipleImages() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod(
        'pickMultipleImages',
      );
      return result?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<String>> pickMultiplePDFs() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod(
        'pickMultiplePDFs',
      );
      return result?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> setExecutable(String path) async {
    return await _channel.invokeMethod('setExecutable', {'path': path}) ??
        false;
  }

  static Future<String?> pickFolder() async {
    try {
      final String? result = await _channel.invokeMethod('pickFolder');
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<void> installApk(String filePath) async {
    await _channel.invokeMethod('installApk', {'filePath': filePath});
  }

  static Future<Map<String, dynamic>?> getAppVersion() async {
    try {
      final result = await _channel.invokeMethod('get-app-version');

      if (result != null && result is Map) {
        return Map<String, dynamic>.from(result);
      }

      return null;
    } on PlatformException catch (_) {
      return null;
    }
  }

  static Future<void> restartApp() async {
    try {
      await _channel.invokeMethod("restart_app");
    } catch (e) {
      debugPrint("Error restarting app: $e");
    }
  }

  static Future<void> clearCache() async {
    try {
      await _channel.invokeMethod("clearCache");
    } catch (e) {
      debugPrint("Error clearing cache: $e");
    }
  }

  static Future<bool> saveKeyValue(String key, bool value) async {
    try {
      await _channel.invokeMethod('save-key-value', {
        'key': key,
        'value': value,
      });
      return true;
    } catch (e) {
      debugPrint("Error saving key-value: $e");
      return false;
    }
  }

  static Future<bool> getKeyValue(String key) async {
    try {
      final result = await _channel.invokeMethod('get-key-value', {'key': key});
      return result ?? false;
    } catch (e) {
      debugPrint("Error getting key-value: $e");
      return false;
    }
  }

  static Future<bool> saveKeyValueInt(String key, int value) async {
    try {
      await _channel.invokeMethod('save-key-value', {
        'key': key,
        'value': value,
      });
      return true;
    } catch (e) {
      debugPrint("Error saving key-value-int: $e");
      return false;
    }
  }

  static Future<int> getKeyValueInt(String key) async {
    try {
      final result = await _channel.invokeMethod('get-key-value-int', {
        'key': key,
      });
      return result ?? 0;
    } catch (e) {
      debugPrint("Error getting key-value-int: $e");
      return 0;
    }
  }

  static Future<void> showNotification(
    String title,
    String message,
    String channelId,
  ) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'message': message,
        'channelId': channelId,
      });
    } catch (e) {
      debugPrint("Error showing notification: $e");
    }
  }

  static Future<List<String>> getFileNamesBatch(List<String> listPaths) async {
    try {
      final List<dynamic> response = await _channel.invokeMethod(
        "getFileNamesBatch",
        {"uris": listPaths},
      );

      return List<String>.from(response);
    } catch (e) {
      debugPrint("Error $e");
      return [];
    }
  }

  static Future<void> imgToPdf(
    List<String> imagePaths,
    String pdfName,
    String outputPdfPath,
  ) async {
    try {
      await _channel.invokeMethod('imgToPdf', {
        'imagePaths': imagePaths,
        "pdfName": pdfName,
        'outputPath': outputPdfPath,
      });
    } catch (e) {
      debugPrint('Error in imgToPdf: $e');
      throw Exception('Error converting image to PDF: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> pdfToImg(
    List<String> pdfPaths,
    String outputImagePath,
  ) async {
    try {
      await _channel.invokeMethod('pdfsToImages', {
        'pdfPaths': pdfPaths,
        'outputDirPath': outputImagePath,
      });
    } catch (e) {
      debugPrint('Error in pdfToImg: $e');
      throw Exception('Error converting PDF to image: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> mergePdfs(
    List<String> pdfPaths,
    String pdfName,
    String outputPdfPath,
  ) async {
    try {
      await _channel.invokeMethod('mergePdfs', {
        'pdfPaths': pdfPaths,
        'outputName': pdfName,
        "outputDirPath": outputPdfPath,
      });
    } catch (e) {
      debugPrint('Error in mergePdfs: $e');
      throw Exception('Error merging PDFs: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> splitPdf(
    List<String> pdfPaths,
    String outputDirPath,
    int? startPage,
    int? endPage,
    int? splitAt,
  ) async {
    try {
      await _channel.invokeMethod('splitPdfs', {
        'pdfPaths': pdfPaths,
        'outputDirPath': outputDirPath,
        'startPage': startPage,
        'endPage': endPage,
        'splitAt': splitAt,
      });
    } catch (e) {
      debugPrint('Error in splitPdf: $e');
      throw Exception('Error splitting PDF: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> optimizePdf(
    List<String> pdfPath,
    int quantity,
    String directoryPath,
  ) async {
    try {
      await _channel.invokeMethod('optimizePdfPdf', {
        'pdfPaths': pdfPath,
        "quality": quantity,
        'outputDirPath': directoryPath,
      });
    } catch (e) {
      debugPrint('Error in optimizePdf: $e');
      throw Exception('Error optimizing PDF: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> optimizeImage(
    List<String> imagePath,
    int quality,
    String outputImagePath,
  ) async {
    try {
      await _channel.invokeMethod('optimizeImages', {
        'imagePaths': imagePath,
        "quality": quality,
        'outputDirPath': outputImagePath,
      });
    } catch (e) {
      debugPrint('Error in optimizeImage: $e');
      throw Exception('Error optimizing image: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> convertImgFormat(
    List<String> imagePaths,
    String format,
    String outputImagePath,
  ) async {
    try {
      await _channel.invokeMethod('convertImagesToFormat', {
        'imagePaths': imagePaths,
        "targetFormat": format,
        'outputDirPath': outputImagePath,
      });
    } catch (e) {
      debugPrint('Error in convertImgFormat: $e');
      throw Exception('Error converting image format: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> extractTextFromPdfs(
    List<String> pdfPaths,
    String outputDirPath,
  ) async {
    try {
      await _channel.invokeMethod('extractTextFromPdfs', {
        'pdfPaths': pdfPaths,
        'outputDirPath': outputDirPath,
      });
    } catch (e) {
      debugPrint('Error in extractTextFromPdfs: $e');
      throw Exception('Error extracting text from PDF: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> removeImageBackground(
    List<String> imagePaths,
    String outputDirPath,
  ) async {
    try {
      await _channel.invokeMethod('removeImageBackground', {
        'imagePaths': imagePaths,
        'outputDirPath': outputDirPath,
      });
    } catch (e) {
      debugPrint('Error in removeImageBackground: $e');
      throw Exception('Error removing background from images: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> rotatePdfs(
    List<String> pdfPaths,
    String outputDirPath, {
    required int angle,
    String? pageRange,
  }) async {
    try {
      await _channel.invokeMethod('rotatePdfs', {
        'pdfPaths': pdfPaths,
        'outputDirPath': outputDirPath,
        'angle': angle,
        pageRange != null ? 'pageRange': pageRange : null,
      });
    } catch (e) {
      debugPrint('Error in rotatePdfs: $e');
      throw Exception('Error rotating PDFs: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> addWatermarkToPdfs(
    List<String> pdfPaths,
    String outputDirPath, {
    required String watermarkText,
    double opacity = 0.3,
    double fontSize = 48.0,
  }) async {
    try {
      await _channel.invokeMethod('addWatermarkToPdfs', {
        'pdfPaths': pdfPaths,
        'outputDirPath': outputDirPath,
        'watermarkText': watermarkText,
        'opacity': opacity,
        'fontSize': fontSize,
      });
    } catch (e) {
      debugPrint('Error in addWatermarkToPdfs: $e');
      throw Exception('Error adding watermark: $e');
    } finally {
      await clearCache();
    }
  }

  static Future<void> copyUriToDirectory(
    String sourceUri,
    String outputDirPath,
    String fileName,
  ) async {
    try {
      await _channel.invokeMethod('copyUriToDirectory', {
        'sourceUri': sourceUri,
        'outputDirPath': outputDirPath,
        'fileName': fileName,
      });
    } catch (e) {
      debugPrint('Error in copyUriToDirectory: $e');
      throw Exception('Error copying file: $e');
    }
  }

  static Future<Map<String, dynamic>?> scanDocument() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'startDocumentScanner',
      );
      return result;
    } catch (e) {
      debugPrint('Error in scanDocument: $e');
      throw Exception('Error starting document scanner: $e');
    }
  }
}

