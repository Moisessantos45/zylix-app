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
  ValueNotifier<String> selectedFormat = ValueNotifier<String>("PNG");
  double quantity = 80;
  ValueNotifier<bool> isProcessing = ValueNotifier<bool>(false);

  Future<void> processFiles() async {
    if (!isSelectionValid()) return;

    isProcessing.value = true;

    try {
      await NativeBridge.convertImgFormat(
        selectedFilesPaths.value,
        selectedFormat.value,
        directoryPath.value,
      );

      if (mounted) {
        showGlobalSnackBar("Images convertidas exitosamente!");

        thumbnails.value.clear();
        loadedCount.value = 0;
        selectedFilesPaths.value.clear();
        directoryPath.value = '';
        selectedFormat.value = "PNG";
      }
    } on PlatformException catch (e) {
      showGlobalSnackBar("Error: ${e.message}", isError: true);
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
        loadedCount,
        directoryPath,
        isProcessing,
      ]),
      builder: (context, child) {
        final value = selectedFilesPaths.value;

        return LoadingOverlay(
          isLoading: isProcessing.value,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: value.isEmpty
                                ? UploadFile(
                                    key: ValueKey('upload'),
                                    subtitle:
                                        "Tap here to select JPG, PNG, or GIF files from your gallery.",
                                    onPressed: selectFiles,
                                  )
                                : FileListHeader(
                                    key: ValueKey('header'),
                                    title: "Images",
                                    amount: value.length,
                                    onPressed: () {
                                      thumbnails.value.clear();
                                      loadedCount.value = 0;
                                      selectedFilesPaths.value.clear();
                                      selectedFormat.value = "PNG";
                                    },
                                  ),
                          ),

                          const SizedBox(height: 10),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: value.isEmpty
                                ? const Center(
                                    key: ValueKey('empty'),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    key: ValueKey('grid'),
                                    items: value,
                                    thumbnails: thumbnails.value,
                                    loadedCount: loadedCount.value,
                                    scroll: scrollController,
                                    onTap: (value) {
                                      removeImage(value);
                                    },
                                  ),
                          ),
                          const SizedBox(height: 12),
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

  Widget _buildItemFormat(String label) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedFormat,
      builder: (context, value, child) {
        return ChoiceChip(
          label: Text(label),
          selected: value == label,
          selectedColor: AppColor.primaryColor,
          backgroundColor: Colors.white,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: value == label ? AppColor.primaryColor : Colors.white24,
            ),
          ),
          onSelected: (bool selected) {
            selectedFormat.value = label;
          },
        );
      },
    );
  }
}
