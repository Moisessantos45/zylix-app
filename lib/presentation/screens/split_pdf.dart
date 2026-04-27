import 'package:flutter/material.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/shared/pdf_file_selector_mixin.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class SplitPdfScreen extends StatefulWidget {
  const SplitPdfScreen({super.key});

  @override
  State<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends State<SplitPdfScreen>
    with PdfFileSelectorMixin<SplitPdfScreen> {
  ValueNotifier<int?> startPage = ValueNotifier<int?>(null);
  ValueNotifier<int?> endPage = ValueNotifier<int?>(null);
  ValueNotifier<int?> splitAt = ValueNotifier<int?>(null);

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
      await NativeBridge.splitPdf(
        selectedFilesPaths.value,
        directoryPath.value,
        startPage.value,
        endPage.value,
        splitAt.value,
      );

      if (mounted) {
        showGlobalSnackBar("¡PDFs divididos exitosamente!");
        selectedFilesPaths.value = [];
        thumbnails.value = [];
        directoryPath.value = "";
        startPage.value = null;
        endPage.value = null;
        splitAt.value = null;
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
    startPage.value = null;
    endPage.value = null;
    splitAt.value = null;
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
        startPage,
        endPage,
        splitAt,
      ]),
      builder: (context, child) {
        final value = selectedFilesPaths.value;
        return LoadingOverlay(
          isLoading: isProcessing.value,
          message: "Splitting PDFs...",
          child: Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "Split PDFs",
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
                            "Split your PDFs into individual pages or custom ranges.",
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
                                        "Tap here to select PDFs from your explorer.",
                                    onPressed: selectFiles,
                                  )
                                : Row(
                                    key: ValueKey("options"),
                                    children: [
                                      Expanded(
                                        child: Container(
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
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Start Page',
                                              hintText: 'e.g., 1',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            ),
                                            onChanged: (value) {
                                              startPage.value = int.tryParse(value);
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
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
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'End Page',
                                              hintText: 'e.g., 10',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            ),
                                            onChanged: (value) {
                                              endPage.value = int.tryParse(value);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          if (value.isNotEmpty) ...[
                            const SizedBox(height: 12),
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
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Split At (page number)',
                                  hintText: 'e.g., 5',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onChanged: (value) {
                                  splitAt.value = int.tryParse(value);
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
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
                              title: "Split PDFs",
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
