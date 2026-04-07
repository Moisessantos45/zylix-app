import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/shared/pdf_file_selector_mixin.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class WatermarkPdfScreen extends StatefulWidget {
  const WatermarkPdfScreen({super.key});

  @override
  State<WatermarkPdfScreen> createState() => _WatermarkPdfScreenState();
}

class _WatermarkPdfScreenState extends State<WatermarkPdfScreen>
    with PdfFileSelectorMixin<WatermarkPdfScreen> {
  final TextEditingController _watermarkController = TextEditingController(
    text: 'CONFIDENCIAL',
  );
  final ValueNotifier<double> _opacity = ValueNotifier(0.3);

  Future<void> processFiles() async {
    final text = _watermarkController.text.trim();
    if (text.isEmpty) {
      showGlobalSnackBar(
        'Escribe el texto de la marca de agua.',
        isError: true,
      );
      return;
    }
    if (selectedFilesPaths.value.isEmpty) {
      showGlobalSnackBar('No hay archivos seleccionados.', isError: true);
      return;
    }
    if (directoryPath.value.isEmpty) {
      showGlobalSnackBar('Selecciona una carpeta de destino.', isError: true);
      return;
    }

    isProcessing.value = true;
    try {
      await NativeBridge.addWatermarkToPdfs(
        selectedFilesPaths.value,
        directoryPath.value,
        watermarkText: text,
        opacity: _opacity.value,
        fontSize: 48.0,
      );

      if (mounted) {
        showGlobalSnackBar('¡Marca de agua añadida exitosamente!');
        selectedFilesPaths.value = [];
        thumbnails.value = [];
        directoryPath.value = '';
      }
    } on PlatformException catch (e) {
      showGlobalSnackBar('Error: ${e.message}', isError: true);
    } catch (e) {
      showGlobalSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) isProcessing.value = false;
    }
  }

  @override
  void dispose() {
    _watermarkController.dispose();
    _opacity.dispose();
    selectedFilesPaths.value = [];
    thumbnails.value = [];
    directoryPath.value = '';
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
        _opacity,
      ]),
      builder: (context, _) {
        final files = selectedFilesPaths.value;

        return LoadingOverlay(
          isLoading: isProcessing.value,
          message: 'Añadiendo marcas de agua...',
          child: Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Watermark PDF',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            body: SafeArea(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final hp = constraints.maxWidth * 0.05;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: hp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Añade un texto diagonal semitransparente en cada página de tus PDFs.',
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Selector de PDFs
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: files.isEmpty
                                ? UploadFile(
                                    key: const ValueKey('upload'),
                                    subtitle:
                                        'Toca aquí para seleccionar PDFs desde el explorador.',
                                    onPressed: selectFiles,
                                  )
                                : FileListHeader(
                                    key: const ValueKey('header'),
                                    title: 'PDFs',
                                    amount: files.length,
                                    onPressed: () {
                                      selectedFilesPaths.value = [];
                                      thumbnails.value = [];
                                    },
                                  ),
                          ),

                          const SizedBox(height: 16),

                          Expanded(
                            child: files.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.water_drop_outlined,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text('No hay PDFs seleccionados'),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: files.length,
                                    itemBuilder: (context, index) {
                                      final name =
                                          thumbnails.value.length > index
                                          ? thumbnails.value[index]
                                          : '';
                                      return name.isNotEmpty
                                          ? PdfItem(
                                              title: name,
                                              onTap: () => removeFiles(index),
                                            )
                                          : const SizedBox.shrink();
                                    },
                                  ),
                          ),

                          if (files.isNotEmpty) ...[
                            const Text(
                              'Texto de la marca de agua',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _watermarkController,
                              maxLength: 40,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Ej: CONFIDENCIAL, BORRADOR...',
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Opacidad',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${(_opacity.value * 100).round()}%',
                                  style: TextStyle(
                                    color: AppColor.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColor.primaryColor,
                                thumbColor: AppColor.primaryColor,
                                inactiveTrackColor: AppColor.primaryColor
                                    .withAlpha(50),
                                overlayColor: AppColor.primaryColor.withAlpha(
                                  30,
                                ),
                              ),
                              child: Slider(
                                value: _opacity.value,
                                min: 0.1,
                                max: 0.9,
                                divisions: 8,
                                onChanged: (v) => _opacity.value = v,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: CustomOutlinedButton(
                                    getDirectoryPath: selectFiles,
                                    title: 'Añadir más',
                                    icon: Icons.add,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomOutlinedButton(
                                    getDirectoryPath: getDirectoryPath,
                                    title: directoryPath.value.isEmpty
                                        ? 'Carpeta'
                                        : 'Carpeta ✓',
                                    icon: Icons.folder_open,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            CustomElevatedButton(
                              title: 'Añadir Marca de Agua',
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
