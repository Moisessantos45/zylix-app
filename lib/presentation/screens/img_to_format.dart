import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/shared/grid_scroll_mixin.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class ImageToFormatConverterScreen extends StatefulWidget {
  const ImageToFormatConverterScreen({super.key});

  @override
  State<ImageToFormatConverterScreen> createState() =>
      _ImageToFormatConverterScreenState();
}

class _ImageToFormatConverterScreenState
    extends State<ImageToFormatConverterScreen>
    with GridScrollMixin<ImageToFormatConverterScreen> {
  String selectedFormat = "PNG";
  double quantity = 80;
  bool isProcessing = false;

  Future<void> processFiles() async {
    if (selectedFilesPaths.isEmpty) {
      showGlobalSnackBar("Selecciona imágenes primero", isError: true);
      return;
    }
    if (directoryPath.isEmpty) {
      showGlobalSnackBar("Selecciona directorio de salida", isError: true);
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      await NativeBridge.convertImgFormat(
        selectedFilesPaths,
        selectedFormat,
        directoryPath,
      );

      if (mounted) {
        showGlobalSnackBar("Images convertidas exitosamente!");
        setState(() {
          selectedFilesPaths.clear();
          thumbnails.clear();
          directoryPath = "";
          loadedCount = 0;
        });
      }
    } on PlatformException catch (e) {
      showGlobalSnackBar("Error: ${e.message}", isError: true);
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
      message: "Converting Images...",
      child: Scaffold(
        backgroundColor: AppColor.backgroundLight,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Convert Images",
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedFilesPaths.isEmpty)
                        UploadFile(
                          subtitle:
                              "Tap here to select JPG, PNG, or GIF files from your gallery.",
                          onPressed: selectFiles,
                        ),
                      const SizedBox(height: 16),
                      if (selectedFilesPaths.isNotEmpty)
                        FileListHeader(
                          title: "Images",
                          amount: selectedFilesPaths.length,
                          onPressed: () {
                            setState(() {
                              selectedFilesPaths.clear();
                              thumbnails.clear();
                              loadedCount = 0;
                            });
                          },
                        ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: selectedFilesPaths.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text("Not Found Images"),
                                  ],
                                ),
                              )
                            : ImageGrid(
                                items: selectedFilesPaths,
                                thumbnails: thumbnails,
                                loadedCount: loadedCount,
                                scroll: scrollController,
                                onTap: (value) {
                                  removeImage(value);
                                },
                              ),
                      ),
                      const SizedBox(height: 12),
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
                        const Text("Select format for conversion"),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8.0,
                          children: [
                            _buildItemFormat("JPEG"),
                            _buildItemFormat("PNG"),
                            _buildItemFormat("WEBP_LOSSY"),
                            _buildItemFormat("WEBP_LOSSLESS"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomElevatedButton(
                          onPressed: processFiles,
                          title: "Convert Images",
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

  Widget _buildItemFormat(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedFormat == label,
      selectedColor: AppColor.primaryColor,
      backgroundColor: Colors.white,
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: selectedFormat == label
              ? AppColor.primaryColor
              : Colors.white24,
        ),
      ),
      onSelected: (bool selected) {
        setState(() {
          selectedFormat = label;
        });
      },
    );
  }
}
