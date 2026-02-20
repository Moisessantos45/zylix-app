import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/shared/grid_scroll_mixin.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class OptimizeImageScreen extends StatefulWidget {
  const OptimizeImageScreen({super.key});

  @override
  State<OptimizeImageScreen> createState() => _OptimizeImageScreenState();
}

class _OptimizeImageScreenState extends State<OptimizeImageScreen>
    with GridScrollMixin<OptimizeImageScreen> {
  ValueNotifier<double> quantity = ValueNotifier<double>(80);
  ValueNotifier<String> selectQuantity = ValueNotifier<String>("Medium");
  final isProcessing = ValueNotifier<bool>(false);

  Future<void> processFiles() async {
    if (!isSelectionValid()) return;

    isProcessing.value = true;

    try {
      await NativeBridge.optimizeImage(
        selectedFilesPaths.value,
        int.tryParse(quantity.value.toStringAsFixed(0)) ?? 80,
        directoryPath.value,
      );

      if (mounted) {
        showGlobalSnackBar("¡Optimización exitosa!");

        thumbnails.value.clear();
        loadedCount.value = 0;

        selectedFilesPaths.value.clear();
        directoryPath.value = "";
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
        quantity,
        selectQuantity,
      ]),
      builder: (context, child) {
        final value = selectedFilesPaths.value;

        return LoadingOverlay(
          isLoading: isProcessing.value,
          message: "Optimize Images",
          child: Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "Optimize Images",
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
                                    key: ValueKey("upload"),
                                    subtitle:
                                        "Tap here to select JPG, PNG, or GIF files from your gallery.",
                                    onPressed: selectFiles,
                                  )
                                : FileListHeader(
                                    key: ValueKey("header"),
                                    title: "Images",
                                    amount: value.length,
                                    onPressed: () {
                                      thumbnails.value.clear();
                                      loadedCount.value = 0;
                                      selectedFilesPaths.value.clear();
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
                                          Icons.image,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text("Not Found images"),
                                      ],
                                    ),
                                  )
                                : ImageGrid(
                                    items: value,
                                    thumbnails: thumbnails.value,
                                    loadedCount: loadedCount.value,
                                    scroll: scrollController,
                                    onTap: (value) {
                                      removeImage(value);
                                    },
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
                            const SizedBox(height: 16),
                            ImageQualitySelector(
                              quantity: quantity.value,
                              select: selectQuantity.value,
                              onChanged: (value) {
                                quantity.value =
                                    double.tryParse(value.toStringAsFixed(0)) ??
                                    80;
                              },
                              onTap: (value, quality) {
                                quantity.value = quality;
                                selectQuantity.value = value;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomElevatedButton(
                              title: "Optimize Images",
                              onPressed: processFiles,
                              isLoading: isProcessing,
                            ),
                          ],
                          const SizedBox(height: 10),
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
