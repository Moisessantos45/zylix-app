import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zylix/config/service/custom_content_image_provider.dart';
import 'package:zylix/config/service/native_bridge.dart';

mixin GridScrollMixin<T extends StatefulWidget> on State<T> {
  late ScrollController scrollController;
  String directoryPath = '';
  List<String> selectedFilesPaths = [];
  List<Uint8List?> thumbnails = [];
  int loadedCount = 0;
  static const int BATCH_SIZE = 20;

  void _initScrollController() {
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 500) {
      loadNextBatch();
    }
  }

  Future<void> selectFiles() async {
    final images = await NativeBridge.pickMultipleImages();
    debugPrint('Imágenes seleccionadas: $images');

    if (images.isEmpty) return;

    final int previousCount = selectedFilesPaths.length;

    if (!mounted) return;
    setState(() {
      selectedFilesPaths.addAll(images);
      thumbnails.addAll(List.generate(images.length, (_) => null));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadNewImagesBatch(previousCount);
    });
  }

  Future<void> getDirectoryPath() async {
    final directory = await NativeBridge.pickFolder();
    if (directory == null) return;

    debugPrint('Directorio seleccionado: $directory');

    if (!mounted) return;
    setState(() {
      directoryPath = directory;
    });
  }

  Future<void> loadNextBatch() async {
    final start = loadedCount;
    final end = (loadedCount + BATCH_SIZE).clamp(0, selectedFilesPaths.length);

    if (start >= selectedFilesPaths.length) return;

    debugPrint('Cargando batch $start-$end');

    final batchUris = selectedFilesPaths.sublist(start, end);
    final batchBytes = await ContentUriImageProvider.loadThumbnailsBatch(
      uris: batchUris,
      maxSize: 200,
      quality: 75,
    );

    if (mounted) {
      setState(() {
        for (int i = 0; i < batchBytes.length; i++) {
          thumbnails[start + i] = batchBytes[i];
        }
        loadedCount = end;
      });
    }
  }

  Future<void> loadNewImagesBatch(int startIndex) async {
    int currentIndex = startIndex;

    while (currentIndex < selectedFilesPaths.length) {
      final end = (currentIndex + BATCH_SIZE).clamp(
        0,
        selectedFilesPaths.length,
      );

      debugPrint('Cargando nuevas imágenes: $currentIndex-$end');

      final batchUris = selectedFilesPaths.sublist(currentIndex, end);
      final batchBytes = await ContentUriImageProvider.loadThumbnailsBatch(
        uris: batchUris,
        maxSize: 200,
        quality: 75,
      );

      if (mounted) {
        setState(() {
          for (int i = 0; i < batchBytes.length; i++) {
            thumbnails[currentIndex + i] = batchBytes[i];
          }
          loadedCount = end;
        });
      }

      currentIndex = end;
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= selectedFilesPaths.length) return;

    setState(() {
      selectedFilesPaths.removeAt(index);
      thumbnails.removeAt(index);

      if (index < loadedCount) {
        loadedCount = loadedCount - 1;
      }
    });
  }

  void scrollToTop() => scrollController.animateTo(
    0,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _initScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }
}
