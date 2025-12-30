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
  List<String> selectedFilesPaths = [];
  List<String> thumbnails = [];
  String directoryPath = "";
  double quantity = 80;
  bool isProcessing = false;

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
      await NativeBridge.optimizePdf(
        selectedFilesPaths,
        quantity.toInt(),
        directoryPath,
      );

      if (mounted) {
        showGlobalSnackBar("¡Optimización exitosa!");
        setState(() {
          selectedFilesPaths.clear();
          thumbnails.clear();
          directoryPath = "";
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
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isProcessing,
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
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      Text(
                        "Optimize your pdfs.",
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (selectedFilesPaths.isEmpty)
                        UploadFile(
                          subtitle:
                              "Tap here to select PDFs, PNG from your explorer.",
                          onPressed: selectFiles,
                        ),
                      const SizedBox(height: 16),
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
                            ? Text("Not Found PDFs")
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
                          title: "Optimize PDFs",
                          onPressed: directoryPath.isNotEmpty
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
