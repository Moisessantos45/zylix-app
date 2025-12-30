import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';

class ContentUriImageProvider extends ImageProvider<ContentUriImageProvider> {
  final String contentUri;

  static const MethodChannel _channel = MethodChannel(
    'com.example.zylix/channel',
  );
  static final Map<String, Uint8List> _thumbnailCache = {};

  const ContentUriImageProvider(this.contentUri);

  @override
  Future<ContentUriImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ContentUriImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    ContentUriImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: key.contentUri,
      informationCollector: () sync* {
        yield ErrorDescription('contentUri: ${key.contentUri}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
    ContentUriImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    Uint8List? bytes = _thumbnailCache[key.contentUri];

    if (bytes == null || bytes.isEmpty) {
      bytes = await _loadSingleThumbnail(key.contentUri);
      if (bytes != null && bytes.isNotEmpty) {
        _thumbnailCache[key.contentUri] = bytes;
      }
    }

    if (bytes == null || bytes.isEmpty) {
      throw StateError('No se pudo cargar imagen: ${key.contentUri}');
    }

    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
      bytes,
    );
    return decode(buffer);
  }

  Future<Uint8List?> _loadSingleThumbnail(String uri) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'loadThumbnailsBatch',
        {
          'uris': [uri],
          'configs': [
            {'maxSize': 200, 'quality': 75},
          ],
        },
      );

      if (result.isEmpty) return null;
      final List<int> bytesList = List<int>.from(result[0]);
      if (bytesList.isEmpty) return null;
      return Uint8List.fromList(bytesList);
    } catch (e) {
      debugPrint('Single load error: $e');
      return null;
    }
  }

  static Future<List<Uint8List?>> loadThumbnailsBatch({
    required List<String> uris,
    int maxSize = 200,
    int quality = 75,
  }) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'loadThumbnailsBatch',
        {
          'uris': uris,
          'configs': List.generate(uris.length, (_) {
            return {'maxSize': maxSize, 'quality': quality};
          }),
        },
      );

      final List<Uint8List?> list = [];
      for (int i = 0; i < result.length; i++) {
        final List<int> bytesList = List<int>.from(result[i]);
        if (bytesList.isEmpty) {
          list.add(null);
        } else {
          final bytes = Uint8List.fromList(bytesList);
          list.add(bytes);
          _thumbnailCache[uris[i]] = bytes;
        }
      }
      return list;
    } catch (e) {
      debugPrint('Batch load error: $e');
      return List<Uint8List?>.filled(uris.length, null);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentUriImageProvider && other.contentUri == contentUri;

  @override
  int get hashCode => contentUri.hashCode;
}
