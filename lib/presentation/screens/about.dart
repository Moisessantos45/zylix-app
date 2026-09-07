import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zylix/config/config.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/domain/file.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/utils/compare_version.dart';
import 'package:zylix/presentation/widgets/organisms/info_section.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  ValueNotifier<bool> downloading = ValueNotifier(false);
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  ValueNotifier<String> versionCode = ValueNotifier("1.0.0");
  DateTime currentDate = DateTime.now();

  Future<void> _installAPK(String pathFile) async {
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory?.path}/$pathFile';

    NativeBridge.installApk(filePath)
        .then((_) {
          debugPrint("Instalación iniciada");
        })
        .catchError((error) {
          debugPrint("Error al iniciar la instalación");
        })
        .whenComplete(() {
          downloading.value = false;
        });
  }

  Future<void> _initializeVersion() async {
    debugPrint("Obteniendo versión de la aplicación... ${Config.API_URL}");
    if (Config.API_URL.isEmpty) {
      debugPrint("ERROR: API_URL vacío, abortando...");
      return;
    }

    final version = await NativeBridge.getAppVersion();
    debugPrint("Version: $version");
    if (version == null) return;

    versionCode.value = version['version'] ?? versionCode.value;
  }

  Future<void> downloadAPK({
    required String fileId,
    required String fileName,
  }) async {
    downloading.value = true;
    downloadProgress.value = 0.0;

    try {
      final dio = Dio();
      final directory = await getExternalStorageDirectory();
      final savePath = '${directory?.path}/$fileName';

      final response = await dio.download(
        '${Config.API_URL}/download/$fileId',
        savePath,
        options: Options(method: 'GET', responseType: ResponseType.stream),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress.value = progress;
            debugPrint("Progreso: ${(progress * 100).toStringAsFixed(0)}%");
          }
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Error al descargar el APK (Status: ${response.statusCode})",
        );
      }

      debugPrint("APK descargado correctamente en: $savePath");
      await _installAPK(fileName);
    } catch (e) {
      debugPrint("Error al descargar el APK: $e");
      showGlobalSnackBar("Error al descargar la actualización", isError: true);
    } finally {
      downloading.value = false;
    }
  }

  Future<void> checkVersion(String currentVersion) async {
    if (downloading.value) return;
    downloading.value = true;

    bool willDownload = false;
    try {
      final dio = Dio();

      final response = await dio.get(
        '${Config.API_URL}/version/zylix',
        queryParameters: {'platforms': 'android'},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final fileData = response.data['data'];
        final file = FileResponse.fromJson(fileData);

        final remoteVersion = file.lastVersion.isNotEmpty
            ? file.lastVersion
            : extractVersionFromName(file.name);

        debugPrint(
          "Versión remota: $remoteVersion | Versión actual: $currentVersion",
        );

        if (remoteVersion.isNotEmpty &&
            compareVersions(remoteVersion, currentVersion) > 0) {
          showGlobalSnackBar(
            "Nueva versión disponible ($remoteVersion). Descargando...",
          );
          willDownload = true;
          await downloadAPK(fileId: file.id, fileName: file.name);
        } else {
          showGlobalSnackBar("Ya tienes la última versión");
        }
      } else {
        showGlobalSnackBar("No se encontraron actualizaciones");
      }

      debugPrint('Versión verificada correctamente');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        debugPrint(
          'Servidor API con error (${e.response?.statusCode}), usando versión local',
        );
      } else {
        debugPrint('Error de red/API: ${e.message}');
      }
      showGlobalSnackBar("Error al verificar actualizaciones", isError: true);
    } catch (e) {
      debugPrint('Error al verificar la versión: $e');
      showGlobalSnackBar("Error al verificar actualizaciones", isError: true);
    } finally {
      if (mounted && !willDownload) {
        downloading.value = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _initializeVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        versionCode,
        downloading,
        downloadProgress,
      ]),
      builder: (context, child) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppColor.backgroundLight,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Zylix",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double horizontalPadding = constraints.maxWidth > 800
                    ? (constraints.maxWidth - 800) / 2
                    : constraints.maxWidth * 0.05;
                if (horizontalPadding < 24) horizontalPadding = 24.0;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.primaryColor,
                                      AppColor.primaryColor.withAlpha(128),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.primaryColor.withAlpha(
                                        30,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.rocket_launch,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Zylix",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColor.primaryColor.withAlpha(77),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "Versión ${versionCode.value.toString()}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "La aplicación Zylix es una herramienta innovadora diseñada para optimizar y simplificar la gestión de documentos PDF. Con una interfaz intuitiva y funcionalidades avanzadas, Zylix permite a los usuarios dividir, fusionar, comprimir y convertir archivos PDF de manera eficiente. Ya sea para uso personal o profesional, Zylix ofrece una solución completa para todas las necesidades relacionadas con documentos PDF.",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              InfoSection(
                                title: "Información",
                                items: [
                                  InfoItem(
                                    icon: Icons.info_outline,
                                    title: "Versión",
                                    value:
                                        "${versionCode.value.toString()} (Build 7)",
                                  ),
                                  InfoItem(
                                    icon: Icons.code,
                                    title: "Framework",
                                    value: "Flutter 3.x",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              InfoSection(
                                title: "Desarrollador",
                                items: [
                                  InfoItem(
                                    icon: Icons.person_outline,
                                    title: "Creado por",
                                    value: "Moises santos",
                                  ),
                                  InfoItem(
                                    icon: Icons.email_outlined,
                                    title: "Contacto",
                                    value: "moisessantoshdz45@gmail.com",
                                  ),
                                  InfoItem(
                                    icon: Icons.public,
                                    title: "Sitio web",
                                    value: "https://portafolio.mmabitec.uk",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              InfoSection(
                                title: "Legal",
                                items: [
                                  InfoItem(
                                    icon: Icons.gavel,
                                    title: "Licencia",
                                    value: "MIT License",
                                    isLink: true,
                                  ),
                                  InfoItem(
                                    icon: Icons.security,
                                    title: "Política de privacidad",
                                    value: "Ver documento",
                                    isLink: true,
                                  ),
                                  InfoItem(
                                    icon: Icons.description,
                                    title: "Términos de uso",
                                    value: "Ver documento",
                                    isLink: true,
                                    isLast: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.primaryColor,
                                      AppColor.primaryColor.withAlpha(200),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.primaryColor.withAlpha(
                                        30,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: AbsorbPointer(
                                  absorbing: downloading.value,
                                  child: ElevatedButton(
                                    onPressed: downloading.value
                                        ? null
                                        : () => checkVersion(versionCode.value),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        downloading.value
                                            ? SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Icon(
                                                Icons.system_update_alt,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                        const SizedBox(width: 12),
                                        Text(
                                          downloading.value
                                              ? "Descargando... ${(downloadProgress.value * 100).toStringAsFixed(0)}%"
                                              : "Buscar Actualizaciones",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),
                              Text(
                                "© ${currentDate.year} Zylix. Todos los derechos reservados.",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
