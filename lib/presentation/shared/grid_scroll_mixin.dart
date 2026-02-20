import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zylix/config/service/custom_content_image_provider.dart';
import 'package:zylix/config/service/native_bridge.dart';

mixin GridScrollMixin<T extends StatefulWidget> on State<T> {
  late ScrollController scrollController;
  ValueNotifier<String> directoryPath = ValueNotifier<String>('');
  ValueNotifier<List<String>> selectedFilesPaths = ValueNotifier<List<String>>(
    [],
  );
  ValueNotifier<List<Uint8List?>> thumbnails = ValueNotifier<List<Uint8List?>>(
    [],
  );
  ValueNotifier<int> loadedCount = ValueNotifier<int>(0);
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

    final int previousCount = selectedFilesPaths.value.length;

    if (!mounted) return;
    selectedFilesPaths.value = [...selectedFilesPaths.value, ...images];

    thumbnails.value.addAll(List.generate(images.length, (_) => null));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadNewImagesBatch(previousCount);
    });
  }

  Future<void> getDirectoryPath() async {
    final directory = await NativeBridge.pickFolder();
    if (directory == null) return;

    debugPrint('Directorio seleccionado: $directory');

    if (!mounted) return;
    directoryPath.value = directory;
  }

  bool isSelectionValid() {
    if (selectedFilesPaths.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selecciona imágenes primero"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (directoryPath.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selecciona directorio de salida"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> loadNextBatch() async {
    final start = loadedCount.value;
    final end = (loadedCount.value + BATCH_SIZE).clamp(
      0,
      selectedFilesPaths.value.length,
    );

    if (start >= selectedFilesPaths.value.length) return;

    debugPrint('Cargando batch $start-$end');

    final batchUris = selectedFilesPaths.value.sublist(start, end);
    final batchBytes = await ContentUriImageProvider.loadThumbnailsBatch(
      uris: batchUris,
      maxSize: 200,
      quality: 75,
    );

    if (mounted) {
      for (int i = 0; i < batchBytes.length; i++) {
        thumbnails.value[start + i] = batchBytes[i];
      }
      loadedCount.value = end;
    }
  }

  Future<void> loadNewImagesBatch(int startIndex) async {
    int currentIndex = startIndex;

    while (currentIndex < selectedFilesPaths.value.length) {
      final end = (currentIndex + BATCH_SIZE).clamp(
        0,
        selectedFilesPaths.value.length,
      );

      debugPrint('Cargando nuevas imágenes: $currentIndex-$end');

      final batchUris = selectedFilesPaths.value.sublist(currentIndex, end);
      final batchBytes = await ContentUriImageProvider.loadThumbnailsBatch(
        uris: batchUris,
        maxSize: 200,
        quality: 75,
      );

      if (mounted) {
        for (int i = 0; i < batchBytes.length; i++) {
          thumbnails.value[currentIndex + i] = batchBytes[i];
        }
        loadedCount.value = end;
      }

      currentIndex = end;
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= selectedFilesPaths.value.length) return;

    selectedFilesPaths.value.removeAt(index);

    thumbnails.value.removeAt(index);

    if (index < loadedCount.value) {
      loadedCount.value = loadedCount.value - 1;
    }
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
    selectedFilesPaths.value.clear();
    thumbnails.value.clear();
    directoryPath.value = '';
    loadedCount.value = 0;
  }
}
