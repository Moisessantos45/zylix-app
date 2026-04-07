import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/shared/pdf_file_selector_mixin.dart';
import 'package:zylix/presentation/widgets/molecules/angle_selector.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class RotatePdfScreen extends StatefulWidget {
  const RotatePdfScreen({super.key});

  @override
  State<RotatePdfScreen> createState() => _RotatePdfScreenState();
}

class _RotatePdfScreenState extends State<RotatePdfScreen>
    with PdfFileSelectorMixin<RotatePdfScreen> {
  final ValueNotifier<int> _selectedAngle = ValueNotifier(90);
  final TextEditingController _pageRangeController = TextEditingController();
  final ValueNotifier<bool> _allPages = ValueNotifier(true);

  Future<void> processFiles() async {
    if (selectedFilesPaths.value.isEmpty) {
      showGlobalSnackBar('No hay PDFs seleccionados.', isError: true);
      return;
    }
    if (directoryPath.value.isEmpty) {
      showGlobalSnackBar('Selecciona una carpeta de destino.', isError: true);
      return;
    }

    final range = _allPages.value
        ? null
        : _pageRangeController.text.trim().isEmpty
        ? null
        : _pageRangeController.text.trim();

    isProcessing.value = true;
    try {
      await NativeBridge.rotatePdfs(
        selectedFilesPaths.value,
        directoryPath.value,
        angle: _selectedAngle.value,
        pageRange: range,
      );
      if (mounted) {
        showGlobalSnackBar('¡PDF(s) rotados exitosamente!');
        selectedFilesPaths.value = [];
        thumbnails.value = [];
        directoryPath.value = '';
        _pageRangeController.clear();
        _allPages.value = true;
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
    _selectedAngle.dispose();
    _pageRangeController.dispose();
    _allPages.dispose();
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
        _selectedAngle,
        _allPages,
      ]),
      builder: (context, _) {
        final files = selectedFilesPaths.value;

        return LoadingOverlay(
          isLoading: isProcessing.value,
          message: 'Rotando páginas...',
          child: Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Rotate PDF',
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
                            'Rota las páginas de uno o varios PDFs en el ángulo que necesites.',
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

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
                                          Icons.rotate_right_outlined,
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
                              'Ángulo de rotación',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AngleSelector(
                              selected: _selectedAngle.value,
                              onChanged: (v) => _selectedAngle.value = v,
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                const Text(
                                  'Páginas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Text(
                                      'Todas',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    Switch(
                                      value: _allPages.value,
                                      activeThumbColor: AppColor.primaryColor,
                                      onChanged: (v) => _allPages.value = v,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!_allPages.value) ...[
                              const SizedBox(height: 4),
                              TextField(
                                controller: _pageRangeController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Ej: 1, 3-5, 7  (vacío = todas)',
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
                            ],
                            const SizedBox(height: 14),

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
                              title: 'Rotar PDF(s)',
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
