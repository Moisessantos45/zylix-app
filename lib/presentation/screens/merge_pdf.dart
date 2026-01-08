import 'package:flutter/material.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class MergePdfScreen extends StatefulWidget {
  const MergePdfScreen({super.key});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen> {
  List<String> selectedFilesPaths = [];
  TextEditingController pdfNameController = TextEditingController();
  List<String> thumbnails = [];
  String directoryPath = "";
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
      await NativeBridge.mergePdfs(
        selectedFilesPaths,
        pdfNameController.text.isEmpty ? "document" : pdfNameController.text,
        directoryPath,
      );

      if (mounted) {
        showGlobalSnackBar("¡PDFs fusionados exitosamente!");
        setState(() {
          selectedFilesPaths.clear();
          thumbnails.clear();
          directoryPath = "";
        });
        pdfNameController.clear();
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
    pdfNameController.dispose();
    selectedFilesPaths.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isProcessing,
      message: "Merging PDFs...",
      child: Scaffold(
        backgroundColor: Color(0xfff6f8f6),
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Marge PDFs",
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
                        "Convert your photos into a single PDF document.",
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
                      if (selectedFilesPaths.isNotEmpty)
                        TextField(
                          controller: pdfNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name the PDF',
                            suffixText: '.pdf',
                          ),
                        ),
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
                          title: "Merge PDFs",
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
