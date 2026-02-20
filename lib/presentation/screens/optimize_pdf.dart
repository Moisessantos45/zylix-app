import 'package:flutter/material.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class OptimizePdfScreen extends StatefulWidget {
  const OptimizePdfScreen({super.key});

  @override
  State<OptimizePdfScreen> createState() => _OptimizePdfScreenState();
}

class _OptimizePdfScreenState extends State<OptimizePdfScreen> {
  ValueNotifier<List<String>> selectedFilesPaths = ValueNotifier([]);
  ValueNotifier<List<String>> thumbnails = ValueNotifier([]);
  ValueNotifier<String> directoryPath = ValueNotifier("");
  ValueNotifier<double> quantity = ValueNotifier(80);
  ValueNotifier<bool> isProcessing = ValueNotifier<bool>(false);

  Future<void> selectFiles() async {
    final files = await NativeBridge.pickMultiplePDFs();
    debugPrint('Files seleccionadas: $files');

    if (files.isEmpty) return;
    final filesNames = await NativeBridge.getFileNamesBatch(files);

    selectedFilesPaths.value.addAll(files);
    thumbnails.value.addAll(filesNames);
  }

  void removeFiles(int index) {
    if (index < 0 || index >= selectedFilesPaths.value.length) return;

    selectedFilesPaths.value.removeAt(index);
    thumbnails.value.removeAt(index);
  }

  Future<void> getDirectoryPath() async {
    final directory = await NativeBridge.pickFolder();
    if (directory == null) return;
    debugPrint('Directorio seleccionado: $directory');

    directoryPath.value = directory;
  }

  Future<void> processFiles() async {
    if (selectedFilesPaths.value.isEmpty) {
      showGlobalSnackBar("Selecciona PDFs primero", isError: true);
      return;
    }

    if (directoryPath.value.isEmpty) {
      showGlobalSnackBar("Selecciona directorio de salida", isError: true);
      return;
    }

    isProcessing.value = true;

    try {
      await NativeBridge.optimizePdf(
        selectedFilesPaths.value,
        int.tryParse(quantity.value.toString()) ?? 80,
        directoryPath.value,
      );

      if (mounted) {
        showGlobalSnackBar("¡Optimización exitosa!");

        selectedFilesPaths.value.clear();
        thumbnails.value.clear();
        directoryPath.value = "";
      }
    } catch (e) {
      showGlobalSnackBar("Error: $e", isError: true);
    } finally {
      if (mounted) {
        isProcessing.value = false;
      }
    }
  }

  @override
  void dispose() {
    selectedFilesPaths.value.clear();
    thumbnails.value.clear();
    directoryPath.value = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        selectedFilesPaths,
        thumbnails,
        directoryPath,
        isProcessing,
        quantity,
      ]),
      builder: (context, child) {
        final value = selectedFilesPaths.value;

        return LoadingOverlay(
          isLoading: isProcessing.value,
          message: "Optimize PDFs",
          child: Scaffold(
            backgroundColor: Color(0xfff6f8f6),
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "Optimize PDFs",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            body: SafeArea(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double horizontalPadding = constraints.maxWidth * 0.05;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Optimize your pdfs.",
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: value.isEmpty
                                ? UploadFile(
                                    key: ValueKey("upload"),
                                    subtitle:
                                        "Tap here to select PDFs, PNG from your explorer.",
                                    onPressed: selectFiles,
                                  )
                                : FileListHeader(
                                    key: ValueKey("header"),
                                    title: "PDFs",
                                    amount: value.length,
                                    onPressed: () {
                                      selectedFilesPaths.value.clear();
                                      thumbnails.value.clear();
                                    },
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: value.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf_outlined,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text("Not Found PDFs"),
                                      ],
                                    ),
                                  )
                                : RepaintBoundary(
                                    child: ListView.builder(
                                      itemCount: value.length,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final title = thumbnails.value[index];
                                        return title.isNotEmpty
                                            ? PdfItem(
                                                title: title,
                                                onTap: () {
                                                  removeFiles(index);
                                                },
                                              )
                                            : const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: Colors.grey,
                                              );
                                      },
                                    ),
                                  ),
                          ),
                          if (value.isNotEmpty) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomOutlinedButton(
                                    getDirectoryPath: selectFiles,
                                    title: "Add more",
                                    icon: Icons.add_photo_alternate,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomOutlinedButton(
                                    getDirectoryPath: getDirectoryPath,
                                    title: "Folder",
                                    icon: Icons.folder_open,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            CustomElevatedButton(
                              title: "Optimize PDFs",
                              onPressed: processFiles,
                              isLoading: isProcessing,
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
