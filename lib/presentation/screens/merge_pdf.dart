import 'package:flutter/material.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/shared/pdf_file_selector_mixin.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class MergePdfScreen extends StatefulWidget {
  const MergePdfScreen({super.key});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen>
    with PdfFileSelectorMixin<MergePdfScreen> {
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
      await NativeBridge.mergePdfs(
        selectedFilesPaths.value,
        pdfNameController.text.isEmpty ? "document" : pdfNameController.text,
        directoryPath.value,
      );

      if (mounted) {
        showGlobalSnackBar("¡PDFs fusionados exitosamente!");

        selectedFilesPaths.value = [];
        thumbnails.value = [];
        directoryPath.value = "";
        pdfNameController.clear();
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
          message: "Merging PDFs...",
          child: Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                "Merge PDFs",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double horizontalPadding = constraints.maxWidth > 800
                      ? (constraints.maxWidth - 800) / 2
                      : constraints.maxWidth * 0.05;
                  if (horizontalPadding < 24) horizontalPadding = 24.0;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Combine multiple PDF files into a single document seamlessly.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.left,
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
                                    selectedFilesPaths.value = [];
                                    thumbnails.value = [];
                                  },
                                ),
                        ),
                        if (value.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: pdfNameController,
                              decoration: InputDecoration(
                                labelText: 'Name the PDF',
                                suffixText: '.pdf',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: value.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Not Found PDFs",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
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
                            title: "Merge PDFs",
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
        );
      },
    );
  }
}
