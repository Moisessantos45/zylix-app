import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UriImage extends ImageProvider<UriImage> {
  final String uriString;
  const UriImage(this.uriString);

  @override
  Future<UriImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(UriImage key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(_load(key, decode));
  }

  Future<ImageInfo> _load(UriImage key, ImageDecoderCallback decode) async {
    final uri = Uri.parse(key.uriString);
    final path = uri.scheme == 'file' ? uri.toFilePath() : uri.path;
    final file = File(path);
    if (!file.existsSync()) throw Exception('File not found: $path');
    final bytes = await file.readAsBytes();
    final buffer = await ImmutableBuffer.fromUint8List(bytes);
    final codec = await decode(buffer);
    final frame = await codec.getNextFrame();
    return ImageInfo(image: frame.image);
  }

  @override
  bool operator ==(Object other) =>
      other is UriImage && other.uriString == uriString;

  @override
  int get hashCode => uriString.hashCode;
}
