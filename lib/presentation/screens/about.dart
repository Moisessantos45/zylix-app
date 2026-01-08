import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zylix/config/config.dart';
import 'package:zylix/config/service/native_bridge.dart';
import 'package:zylix/config/utils/snackbar_helper.dart';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/info_section.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool downloading = false;
  String versionCode = "1.0.0";
  DateTime currentDate = DateTime.now();

  Future<void> _initializeVersion() async {
    debugPrint("Obteniendo versión de la aplicación... ${Config.API_URL}");
    if (Config.API_URL.isEmpty) {
      debugPrint("ERROR: API_URL vacío, abortando...");
      return;
    }

    final version = await NativeBridge.getAppVersion();
    debugPrint("Version: $version");
    if (version == null) return;
    setState(() {
      versionCode = version['version'] ?? versionCode;
    });
  }

  Future<void> downloadAPK() async {
    setState(() => downloading = true);
    try {
      final dio = Dio();
      final response = await dio.post(
        Config.API_URL,
        queryParameters: {'app': 'zylix-$versionCode'},
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) {
        throw Exception("Error al descargar el APK");
      }

      final appName =
          response.headers.value('x-app-name') ?? 'zylix-$versionCode.apk';

      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/$appName';
      final file = File(filePath);

      await file.writeAsBytes(response.data);
      debugPrint("APK descargado correctamente");
      await _installAPK(appName);
    } catch (e) {
      debugPrint("Error al descargar el APK");
    } finally {
      setState(() => downloading = false);
    }
  }

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
          setState(() => downloading = false);
        });
  }

  Future<void> checkVersion(String versionCode) async {
    setState(() {
      downloading = true;
    });

    try {
      final dio = Dio();

      final response = await dio.get(
        '${Config.API_URL}/version-check',
        queryParameters: {'app': 'zylix-$versionCode'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("Version: $data");
        if (data['data'] != null && data['data']['codeVersion'] != null) {
          if (data['data']['codeVersion'] != versionCode) {
            showGlobalSnackBar("Nueva versión disponible. Descargando...");
            await downloadAPK();
          }
        } else {
          showGlobalSnackBar("Ya tienes la última versión");
        }
      }
      debugPrint('Versión verificada correctamente');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        debugPrint(
          'Servidor API caído (${e.response?.statusCode}), usando versión local',
        );
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint('Error al verificar la versión: $e');
      showGlobalSnackBar("Error al verificar actualizaciones", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          downloading = false;
        });
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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding = constraints.maxWidth * 0.05;

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
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.primaryColor,
                                    AppColor.primaryColor.withAlpha(128),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primaryColor.withAlpha(100),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.rocket_launch,
                                size: 60,
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
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColor.primaryColor.withAlpha(77),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "Versión $versionCode",
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
                              textAlign: TextAlign.center,
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
                                  value: "$versionCode (Build 1)",
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
                                  value: "https://www.mmabitec.me",
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
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primaryColor.withAlpha(77),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: downloading
                                    ? null
                                    : () => checkVersion(versionCode),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: downloading
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "Verificando...",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.system_update_alt,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Buscar Actualizaciones",
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

                            const SizedBox(height: 32),
                            Text(
                              "© ${currentDate.year} Zylix. Todos los derechos reservados.",
                              textAlign: TextAlign.center,
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
      ),
    );
  }
}
