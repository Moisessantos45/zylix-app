import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class CropRotateImageScreen extends StatefulWidget {
  const CropRotateImageScreen({super.key});

  @override
  State<CropRotateImageScreen> createState() => _CropRotateImageScreenState();
}

class _CropRotateImageScreenState extends State<CropRotateImageScreen> {
  final ValueNotifier<bool> _isProcessing = ValueNotifier(false);
  final ValueNotifier<String?> _selectedImageUri = ValueNotifier(null);
  final ValueNotifier<String?> _croppedImagePath = ValueNotifier(null);
  final ValueNotifier<String> _directoryPath = ValueNotifier('');

  Future<void> _pickImage() async {
    try {
      final uris = await NativeBridge.pickMultipleImages();
      if (uris.isEmpty) return;
      _selectedImageUri.value = uris.first;
      _croppedImagePath.value = null;
      await _openCropper(uris.first);
    } on PlatformException catch (e) {
      showGlobalSnackBar('Error: ${e.message}', isError: true);
    }
  }

  Future<void> _openCropper(String imageUri) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageUri.startsWith('content://')
          ? await _resolveContentUri(imageUri)
          : imageUri,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar / Rotar',
          toolbarColor: AppColor.primaryColor,
          toolbarWidgetColor: Colors.white,
          statusBarLight: true,
          activeControlsWidgetColor: AppColor.primaryColor,
          dimmedLayerColor: Colors.black87,
          cropFrameColor: AppColor.primaryColor,
          cropGridColor: AppColor.primaryColor.withAlpha(100),
          showCropGrid: true,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );

    if (croppedFile != null) {
      _croppedImagePath.value = croppedFile.path;
    }
  }

  Future<String> _resolveContentUri(String contentUri) async {
    final bytes = await NativeBridge.getBytesFromUri(contentUri);
    if (bytes.isEmpty) {
      throw Exception('No se pudo leer la imagen seleccionada.');
    }
    final tempFile = File(
      '${Directory.systemTemp.path}/zylix_crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(bytes);
    return tempFile.path;
  }

  Future<void> _pickFolder() async {
    final dir = await NativeBridge.pickFolder();
    if (dir == null) return;
    _directoryPath.value = dir;
  }

  Future<void> _saveImage() async {
    final path = _croppedImagePath.value;
    if (path == null) {
      showGlobalSnackBar('No hay imagen recortada.', isError: true);
      return;
    }
    if (_directoryPath.value.isEmpty) {
      showGlobalSnackBar('Selecciona una carpeta de destino.', isError: true);
      return;
    }

    _isProcessing.value = true;
    try {
      final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await NativeBridge.copyUriToDirectory(
        Uri.file(path).toString(),
        _directoryPath.value,
        fileName,
      );
      if (mounted) {
        showGlobalSnackBar('¡Imagen guardada correctamente!');
        _reset();
      }
    } catch (e) {
      showGlobalSnackBar('Error al guardar: $e', isError: true);
    } finally {
      _isProcessing.value = false;
    }
  }

  void _reset() {
    _selectedImageUri.value = null;
    _croppedImagePath.value = null;
    _directoryPath.value = '';
  }

  @override
  void dispose() {
    _isProcessing.dispose();
    _selectedImageUri.dispose();
    _croppedImagePath.dispose();
    _directoryPath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _isProcessing,
        _selectedImageUri,
        _croppedImagePath,
        _directoryPath,
      ]),
      builder: (context, _) {
        final hasCropped = _croppedImagePath.value != null;

        return LoadingOverlay(
          isLoading: _isProcessing.value,
          message: 'Guardando imagen...',
          child: Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Crop & Rotate',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Selecciona una imagen para recortarla, rotarla y guardarla.',
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    if (!hasCropped)
                      UploadFile(
                        subtitle:
                            'Toca aquí para elegir una foto desde la galería.',
                        onPressed: _pickImage,
                      ),

                    if (hasCropped) ...[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_croppedImagePath.value!),
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: _pickFolder,
                        child: _FolderSelector(
                          hasDir: _directoryPath.value.isNotEmpty,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: CustomOutlinedButton(
                              getDirectoryPath: _pickImage,
                              title: 'Cambiar imagen',
                              icon: Icons.swap_horiz,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomOutlinedButton(
                              getDirectoryPath: () => _openCropper(
                                _selectedImageUri.value ??
                                    _croppedImagePath.value!,
                              ),
                              title: 'Editar de nuevo',
                              icon: Icons.crop,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomElevatedButton(
                        title: 'Guardar Imagen',
                        onPressed: _saveImage,
                        isLoading: _isProcessing,
                      ),
                    ],

                    if (!hasCropped) const Spacer(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FolderSelector extends StatelessWidget {
  final bool hasDir;
  const _FolderSelector({required this.hasDir});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasDir ? Colors.green.shade400 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(10),
        color: hasDir ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder_open,
            color: hasDir ? Colors.green.shade600 : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasDir
                  ? 'Carpeta seleccionada ✓'
                  : 'Selecciona carpeta de destino',
              style: TextStyle(
                color: hasDir ? Colors.green.shade700 : Colors.grey.shade600,
                fontWeight: hasDir ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
