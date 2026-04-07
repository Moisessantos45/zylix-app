import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/utils/uri_image.dart';
import 'package:zylix/presentation/widgets/organisms/scan_upload_card.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  final ValueNotifier<bool> _isScanning = ValueNotifier(false);
  final ValueNotifier<bool> _isSaving = ValueNotifier(false);
  final ValueNotifier<List<String>> _imageUris = ValueNotifier([]);
  final ValueNotifier<String?> _pdfUri = ValueNotifier(null);
  final ValueNotifier<String> _directoryPath = ValueNotifier('');

  Future<void> _startScan() async {
    _isScanning.value = true;
    try {
      final result = await NativeBridge.scanDocument();
      if (result == null) {
        return;
      }
      final images = List<String>.from(result['imageUris'] as List? ?? []);
      final pdf = result['pdfUri'] as String?;

      if (images.isEmpty && pdf == null) {
        if (mounted) {
          showGlobalSnackBar(
            'No se obtuvo ningún resultado del escáner.',
            isError: true,
          );
        }
        return;
      }

      _imageUris.value = images;
      _pdfUri.value = pdf;
    } on PlatformException catch (e) {
      if (mounted) showGlobalSnackBar('Error: ${e.message}', isError: true);
    } catch (e) {
      if (mounted) showGlobalSnackBar('Error: $e', isError: true);
    } finally {
      _isScanning.value = false;
    }
  }

  Future<void> _pickFolder() async {
    final dir = await NativeBridge.pickFolder();
    if (dir == null) return;
    _directoryPath.value = dir;
  }

  Future<void> _saveAsPdf() async {
    final pdfUri = _pdfUri.value;
    if (pdfUri == null) {
      showGlobalSnackBar('No hay PDF disponible.', isError: true);
      return;
    }
    if (_directoryPath.value.isEmpty) {
      showGlobalSnackBar(
        'Selecciona una carpeta de destino primero.',
        isError: true,
      );
      return;
    }
    _isSaving.value = true;
    try {
      await NativeBridge.copyUriToDirectory(
        pdfUri,
        _directoryPath.value,
        'scanned_document.pdf',
      );
      if (mounted) {
        showGlobalSnackBar('¡PDF guardado correctamente!');
        _reset();
      }
    } catch (e) {
      showGlobalSnackBar('Error al guardar PDF: $e', isError: true);
    } finally {
      _isSaving.value = false;
    }
  }

  Future<void> _saveAsImages() async {
    final images = _imageUris.value;
    if (images.isEmpty) {
      showGlobalSnackBar('No hay imágenes disponibles.', isError: true);
      return;
    }
    if (_directoryPath.value.isEmpty) {
      showGlobalSnackBar(
        'Selecciona una carpeta de destino primero.',
        isError: true,
      );
      return;
    }
    _isSaving.value = true;
    try {
      for (int i = 0; i < images.length; i++) {
        await NativeBridge.copyUriToDirectory(
          images[i],
          _directoryPath.value,
          'scanned_page_${(i + 1).toString().padLeft(2, '0')}.jpg',
        );
      }
      if (mounted) {
        showGlobalSnackBar('¡${images.length} imagen(es) guardadas!');
        _reset();
      }
    } catch (e) {
      if (mounted) {
        showGlobalSnackBar('Error al guardar imágenes: $e', isError: true);
      }
    } finally {
      _isSaving.value = false;
    }
  }

  void _reset() {
    _imageUris.value = [];
    _pdfUri.value = null;
    _directoryPath.value = '';
  }

  @override
  void dispose() {
    _isScanning.dispose();
    _isSaving.dispose();
    _imageUris.dispose();
    _pdfUri.dispose();
    _directoryPath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _isScanning,
        _isSaving,
        _imageUris,
        _pdfUri,
        _directoryPath,
      ]),
      builder: (context, _) {
        final hasResult = _imageUris.value.isNotEmpty || _pdfUri.value != null;
        final isBusy = _isScanning.value || _isSaving.value;

        return LoadingOverlay(
          isLoading: isBusy,
          message: _isScanning.value ? 'Abriendo escáner...' : 'Guardando...',
          child: Scaffold(
            backgroundColor: AppColor.backgroundLight,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Document Scanner',
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
                      'Escanea documentos físicos y guárdalos como PDF o imágenes JPG.',
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    if (!hasResult) ScanUploadCard(onPressed: _startScan),

                    const SizedBox(height: 16),

                    if (hasResult) ...[
                      _buildResultHeader(),
                      const SizedBox(height: 12),
                      Expanded(child: _buildPreviewGrid()),
                      const SizedBox(height: 16),
                      _buildFolderSelector(),
                      const SizedBox(height: 16),
                      _buildFormatButtons(),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: isBusy ? null : _startScan,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Escanear de nuevo'),
                      ),
                    ],

                    if (!hasResult) const Spacer(),
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

  Widget _buildResultHeader() {
    final pageCount = _imageUris.value.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$pageCount página(s) escaneada(s)',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        TextButton(
          onPressed: _reset,
          child: const Text('Descartar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildPreviewGrid() {
    final images = _imageUris.value;
    if (images.isEmpty) {
      return const Center(child: Text('Vista previa no disponible (solo PDF)'));
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image(
            image: UriImage(images[index]),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFolderSelector() {
    final dir = _directoryPath.value;
    final hasDir = dir.isNotEmpty;
    return GestureDetector(
      onTap: _pickFolder,
      child: Container(
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
      ),
    );
  }

  Widget _buildFormatButtons() {
    final hasPdf = _pdfUri.value != null;
    final hasImages = _imageUris.value.isNotEmpty;

    return Row(
      children: [
        if (hasPdf)
          Expanded(
            child: CustomElevatedButton(
              title: 'Guardar PDF',
              onPressed: _saveAsPdf,
              isLoading: _isSaving,
            ),
          ),
        if (hasPdf && hasImages) const SizedBox(width: 10),
        if (hasImages)
          Expanded(
            child: CustomOutlinedButton(
              getDirectoryPath: _saveAsImages,
              title: 'Guardar JPG',
              icon: Icons.image_outlined,
            ),
          ),
      ],
    );
  }
}



