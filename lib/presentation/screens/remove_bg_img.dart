import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/shared/grid_scroll_mixin.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class RemoveBgImageScreen extends StatefulWidget {
  const RemoveBgImageScreen({super.key});

  @override
  State<RemoveBgImageScreen> createState() => _RemoveBgImageScreenState();
}

class _RemoveBgImageScreenState extends State<RemoveBgImageScreen>
    with GridScrollMixin<RemoveBgImageScreen> {
  final isProcessing = ValueNotifier<bool>(false);

  Future<void> processFiles() async {
    if (!isSelectionValid()) return;

    isProcessing.value = true;

    try {
      await NativeBridge.removeImageBackground(
        selectedFilesPaths.value,
        directoryPath.value,
      );

      if (mounted) {
        showGlobalSnackBar("¡Fondo removido exitosamente!");

        thumbnails.value = [];
        loadedCount.value = 0;

        selectedFilesPaths.value = [];
        directoryPath.value = "";
      }
    } on PlatformException catch (e) {
      showGlobalSnackBar("Error: ${e.message}", isError: true);
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
        loadedCount,
        directoryPath,
        isProcessing,
      ]),
      builder: (context, child) {
        final value = selectedFilesPaths.value;

        return LoadingOverlay(
          isLoading: isProcessing.value,
          message: "Removing background...",
          child: Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "Remove Background",
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Convierte tus fotos en PNGs transparentes. Funciona mejor con selfies o personas.",
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
                                        "Toca aquí para seleccionar fotos desde la galería.",
                                    onPressed: selectFiles,
                                  )
                                : FileListHeader(
                                    key: ValueKey("header"),
                                    title: "Images",
                                    amount: value.length,
                                    onPressed: () {
                                      thumbnails.value = [];
                                      loadedCount.value = 0;
                                      selectedFilesPaths.value = [];
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
                                          Icons.person_remove_alt_1_outlined,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text("No hay imágenes seleccionadas"),
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
                            const SizedBox(height: 16),
                            CustomElevatedButton(
                              title: "Eliminar Fondo",
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
