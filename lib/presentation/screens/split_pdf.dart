import 'package:flutter/material.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class SplitPdfScreen extends StatefulWidget {
  const SplitPdfScreen({super.key});

  @override
  State<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends State<SplitPdfScreen> {
  List<String> selectedFilesPaths = [];
  List<String> thumbnails = [];
  String directoryPath = "";
  bool isProcessing = false;
  int? startPage;
  int? endPage;
  int? splitAt;

  Future<void> selectFiles() async {
    final files = await NativeBridge.pickMultiplePDFs();
    debugPrint('Files seleccionadas: $files');

    if (files.isEmpty) return;
    final filesNames = await NativeBridge.getFileNamesBatch(files);

    setState(() {
      selectedFilesPaths.addAll(files);
      thumbnails.addAll(filesNames);
    });
  }

  void removeFiles(int index) {
    if (index < 0 || index >= selectedFilesPaths.length) return;

    setState(() {
      selectedFilesPaths.removeAt(index);
      thumbnails.removeAt(index);
    });
  }

  Future<void> getDirectoryPath() async {
    final directory = await NativeBridge.pickFolder();
    if (directory == null) return;
    debugPrint('Directorio seleccionado: $directory');
    setState(() {
      directoryPath = directory;
    });
  }

  Future<void> processFiles() async {
    setState(() {
      isProcessing = true;
    });

    try {
      await NativeBridge.splitPdf(
        selectedFilesPaths,
        directoryPath,
        startPage,
        endPage,
        splitAt,
      );

      if (mounted) {
        showGlobalSnackBar("¡PDFs divididos exitosamente!");
        setState(() {
          selectedFilesPaths.clear();
          thumbnails.clear();
          directoryPath = "";
          startPage = null;
          endPage = null;
          splitAt = null;
        });
      }
    } catch (e) {
      showGlobalSnackBar("Error: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    selectedFilesPaths.clear();
    thumbnails.clear();
    directoryPath = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isProcessing,
      message: "Splitting PDFs...",
      child: Scaffold(
        backgroundColor: Color(0xfff6f8f6),
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
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      Text(
                        "Split your PDFs into individual pages or custom ranges.",
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (selectedFilesPaths.isEmpty)
                        UploadFile(
                          subtitle:
                              "Tap here to select PDFs from your explorer.",
                          onPressed: selectFiles,
                        ),
                      if (selectedFilesPaths.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Start Page',
                                  hintText: 'e.g., 1',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    startPage = int.tryParse(value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'End Page',
                                  hintText: 'e.g., 10',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    endPage = int.tryParse(value);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Split At (page number)',
                            hintText: 'e.g., 5',
                          ),
                          onChanged: (value) {
                            setState(() {
                              splitAt = int.tryParse(value);
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (selectedFilesPaths.isNotEmpty)
                        FileListHeader(
                          title: "PDFs",
                          amount: selectedFilesPaths.length,
                          onPressed: () {
                            setState(() {
                              selectedFilesPaths.clear();
                              thumbnails.clear();
                            });
                          },
                        ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: selectedFilesPaths.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                            : ListView.builder(
                                itemCount: selectedFilesPaths.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final title = thumbnails[index];
                                  return title.isNotEmpty
                                      ? PdfItem(
                                          title: title,
                                          onTap: () {
                                            removeFiles(index);
                                          },
                                        )
                                      : const Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey,
                                        );
                                },
                              ),
                      ),
                      if (selectedFilesPaths.isNotEmpty) ...[
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
                          onPressed: directoryPath.isNotEmpty && !isProcessing
                              ? processFiles
                              : () {},
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
  }
}
