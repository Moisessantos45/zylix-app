import 'package:flutter/material.dart';
import 'package:zylix/config/service/native_bridge.dart';

mixin PdfFileSelectorMixin<T extends StatefulWidget> on State<T> {
  ValueNotifier<List<String>> selectedFilesPaths = ValueNotifier<List<String>>(
    [],
  );
  TextEditingController pdfNameController = TextEditingController();
  ValueNotifier<List<String>> thumbnails = ValueNotifier<List<String>>([]);
  ValueNotifier<String> directoryPath = ValueNotifier<String>("");
  ValueNotifier<bool> isProcessing = ValueNotifier<bool>(false);

  Future<void> selectFiles() async {
    final files = await NativeBridge.pickMultiplePDFs();
    debugPrint('Files seleccionadas: $files');

    if (files.isEmpty) return;
    final filesNames = await NativeBridge.getFileNamesBatch(files);

    selectedFilesPaths.value = List<String>.from(selectedFilesPaths.value)..addAll(files);
    thumbnails.value = List<String>.from(thumbnails.value)..addAll(filesNames);
  }

  void removeFiles(int index) {
    if (index < 0 || index >= selectedFilesPaths.value.length) return;
    selectedFilesPaths.value = List<String>.from(selectedFilesPaths.value)..removeAt(index);
    thumbnails.value = List<String>.from(thumbnails.value)..removeAt(index);
  }

  Future<void> getDirectoryPath() async {
    final directory = await NativeBridge.pickFolder();
    if (directory == null) return;
    debugPrint('Directorio seleccionado: $directory');
    directoryPath.value = directory;
  }

  @override
  void dispose() {
    pdfNameController.dispose();
    selectedFilesPaths.value.clear();
    thumbnails.value.clear();
    directoryPath.value = "";
    isProcessing.value = false;
    super.dispose();
  }
}
