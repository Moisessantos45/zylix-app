import 'package:flutter/material.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/pdf_file_selector_mixin.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class ExtractTextPdfScreen extends StatefulWidget {
  const ExtractTextPdfScreen({super.key});

  @override
  State<ExtractTextPdfScreen> createState() => _ExtractTextPdfScreenState();
}

class _ExtractTextPdfScreenState extends State<ExtractTextPdfScreen>
    with PdfFileSelectorMixin<ExtractTextPdfScreen> {
  
  Future<void> processFiles() async {
    if (selectedFilesPaths.value.isEmpty) {
      showGlobalSnackBar("No hay archivos seleccionados.", isError: true);
      return;
    }

    if (directoryPath.value.isEmpty) {
      showGlobalSnackBar(
        "No hay directorio de destino seleccionado.",
        isError: true,
      );
      return;
    }

    isProcessing.value = true;

    try {
      await NativeBridge.extractTextFromPdfs(
        selectedFilesPaths.value,
        directoryPath.value,
      );

      if (mounted) {
        showGlobalSnackBar("¡Texto extraído exitosamente!");
        selectedFilesPaths.value = [];
        thumbnails.value = [];
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
    selectedFilesPaths.value = [];
    thumbnails.value = [];
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
      ]),
      builder: (context, child) {
        final value = selectedFilesPaths.value;
        return LoadingOverlay(
          isLoading: isProcessing.value,
          message: "Extracting text...",
          child: Scaffold(
            backgroundColor: Color(0xfff6f8f6),
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "Extract PDF Text",
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
                            "Extrae y guarda el texto de tus archivos PDF en documentos .txt de manera sencilla.",
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
                                        "Toca aquí para seleccionar PDFs desde el explorador.",
                                    onPressed: selectFiles,
                                  )
                                : SizedBox.shrink(key: ValueKey("options")),
                          ),
                          if (value.isNotEmpty) const SizedBox(height: 16),
                          if (value.isNotEmpty)
                            FileListHeader(
                              title: "PDFs",
                              amount: value.length,
                              onPressed: () {
                                selectedFilesPaths.value = [];
                                thumbnails.value = [];
                              },
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
                                        Text("No PDFs seleccionados"),
                                      ],
                                    ),
                                  )
                                : RepaintBoundary(
                                    child: ListView.builder(
                                      itemCount: value.length,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final title = thumbnails.value.isNotEmpty && thumbnails.value.length > index
                                            ? thumbnails.value[index]
                                            : "";
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
                                    title: "Añadir más",
                                    icon: Icons.add_photo_alternate,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomOutlinedButton(
                                    getDirectoryPath: getDirectoryPath,
                                    title: "Carpeta",
                                    icon: Icons.folder_open,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            CustomElevatedButton(
                              title: "Extraer Texto",
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
