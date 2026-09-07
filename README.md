# Zylix Mobile

<div align="center">

**Una suite completa de herramientas para manipulación de PDFs e imágenes en tu dispositivo móvil**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-6.0+-3DDC84?style=flat-square&logo=android)](https://www.android.com)

</div>

## 📋 Descripción

**Zylix Mobile** es una aplicación móvil para Android que proporciona un conjunto de herramientas profesionales para trabajar con archivos PDF e imágenes directamente desde tu dispositivo. Diseñada con una interfaz moderna e intuitiva, permite realizar operaciones complejas de manera simple y rápida sin necesidad de conexión a internet.

## 📥 Descarga

### Versiones Disponibles

| Versión | Plataforma | Descarga | Fecha |
|---------|-----------|----------|-------|
| **v2.1.0** | Android | [⬇️ Descargar](https://drive.google.com/file/d/1JFA7ebPUTpWaeXLCv5L5ug_DjS4DNbDJ/view?usp=sharing) | 2026-09-06 |
| v2.0.0 | Android | [⬇️ Descargar](https://drive.google.com/file/d/1b91XkW2gnAImwML75av7pqYsKwYLDg7U/view?usp=sharing) | 2026-09-06 |
| v1.9.1 | Android | [⬇️ Descargar](https://drive.google.com/file/d/1XGdSXNJt89PFXazsnLUDZxglUj2RB8op/view?usp=sharing) | 2026-05-22 |
| v1.9.1 | Android | [⬇️ Descargar](https://drive.google.com/file/d/10nuKuxbxuS1BiNVHR6OEKUiFb9s7O1Cf/view?usp=sharing) | 2026-05-09 |
| v1.8.0 | Android | [⬇️ Descargar](https://drive.google.com/file/d/1ur96ZLVEyBtFh060GHc1VttjQUXen5F9/view?usp=sharing) | 2026-04-05 |
| v1.7.1 | Android | [⬇️ Descargar](https://drive.google.com/file/d/1KhjXZY_3xOL0zP7wVk-tZlLe5FdSZICu/view?usp=sharing) | 2026-02-21 |
| v1.7.0 | Android | [⬇️ Descargar](https://drive.google.com/file/d/1Cp8SCh3i2ld_L6t6bwILQ8H9TmNbuw2Q/view?usp=sharing) | 2026-02-21 |
| v1.4.0 | Android | [⬇️ Descargar](https://drive.google.com/file/d/1J_AK8LiAZg_hyDwz6LMyTQaUjqcl2L12/view?usp=sharing) | 2026-01-08 |
| v1.3.0 | Android | [⬇️ Descargar](https://rmovevnbyamzdvslzqaq.supabase.co/storage/v1/object/public/apps/Portafolio/zylix-1.3.0.apk) | 2026-01-03 |
| v1.2.0 | Android | [⬇️ Descargar](https://rmovevnbyamzdvslzqaq.supabase.co/storage/v1/object/public/apps/Portafolio/zylix-1.2.0.apk) | 2026-01-01 |
| v1.0.2 | Android | [⬇️ Descargar](https://rmovevnbyamzdvslzqaq.supabase.co/storage/v1/object/public/apps/Portafolio/zylix-1.0.2.apk) | 2025-12-30 |
| v1.0.1 | Android | [⬇️ Descargar](https://rmovevnbyamzdvslzqaq.supabase.co/storage/v1/object/public/apps/Portafolio/zylix-1.0.1.apk) | 2025-12-23 |

> **Nota**: La aplicación requiere Android 6.0 (API 23) o superior.

### Instalación Rápida (Android)

1. Descarga el archivo `.apk` desde el link anterior
2. Habilita la instalación de aplicaciones de fuentes desconocidas en tu dispositivo
3. Abre el archivo descargado y confirma la instalación
4. ¡Listo! Ya puedes usar Zylix

## 📝 Historial de Cambios

### v2.1.0+21 — 2026-09-06

- **Actualización del README**: Se actualizó la documentación del proyecto (`README.md`) para reflejar todos los cambios introducidos en las versiones `2.0.0` y anteriores, incluyendo la tabla de descargas, el historial de cambios y la descripción de nuevas funcionalidades.
- **Ajuste de versión**: Se incrementó la versión de `2.0.0+20` a `2.1.0+21` en `pubspec.yaml`.

### v2.0.0+20 — 2026-09-06

- **Actualización de versión a 2.0.0**: Se actualizó la versión de la aplicación a `2.0.0+20` en `pubspec.yaml`, marcando una nueva versión mayor con mejoras significativas en rendimiento y arquitectura.
- **Migración a Java 17**: Se actualizó la versión de Java del proyecto Android a la versión 17 (LTS), mejorando la compatibilidad y el rendimiento de compilación.
- **Optimización de propiedades Gradle**: Se ajustaron las propiedades de Gradle para un mejor rendimiento de compilación:
  - Reducción del heap de JVM a `3072M` para evitar consumo excesivo de memoria.
  - Habilitación de compilación paralela (`org.gradle.parallel=true`), caché de Gradle (`org.gradle.caching=true`) y el daemon (`org.gradle.daemon=true`).
  - Activación de `org.gradle.vfs.watch=true` para mayor velocidad en builds incrementales.
  - Habilitación de `android.enableR8.fullMode=true` y `android.nonTransitiveRClass=true` para mayor optimización del APK.
- **Sistema de verificación de versiones**: Se implementó un sistema inteligente de comparación de versiones (`compare_version.dart`) que detecta automáticamente si existe una versión más reciente disponible, usando comparación semántica (`MAJOR.MINOR.PATCH`).
- **Lógica de descarga e instalación de APK mejorada** (`about.dart`):
  - La descarga ahora se realiza vía `GET` al endpoint `/download/{fileId}` con soporte de `ResponseType.stream` para mayor estabilidad.
  - Se creó el modelo `FileResponse` (`domain/file.dart`) para representar la respuesta del servidor con metadatos del archivo (id, nombre, mimeType, tamaño, `lastVersion`).
  - Se refactorizó `downloadAPK()` para recibir `fileId` y `fileName` como parámetros explícitos.
  - Se añadió manejo de errores mejorado con `showGlobalSnackBar` en caso de fallos durante la descarga.
  - El progreso de descarga se inicializa en `0.0` antes de iniciar cada descarga.
- **Actualización de variable de entorno**: La variable de entorno del API cambió de `API_URL` a `API_URL_V3` en `config.dart`.
- **Logo nativo optimizado**: Se reemplazó el logo PNG del splash screen (`mi_logo.png`) por su versión JPG de menor tamaño en `drawable/` y `drawable-v21/`, reduciendo el tamaño del APK.

### v1.9.65+17 — 2026-05-22

- **Ordenamiento Inteligente de Archivos (Procesamiento por Lotes)**: Se implementó un sistema de ordenamiento numérico/alfabético inteligente de archivos en todos los procesadores nativos de imágenes y PDFs para garantizar un flujo lógico y predecible en las operaciones por lotes:
  - **Conversión & Compresión de Imágenes (`ImageProcessor`)**: Las imágenes se ordenan por nombre antes de ser optimizadas o convertidas, garantizando que los archivos de salida numerados secuencialmente (`opt_00.jpg`, `conv_00.webp`, etc.) sigan la secuencia lógica.
  - **Imagen a PDF (`PdfProcessor.imgToPdf`)**: Las imágenes de entrada se ordenan por nombre antes de generar el PDF, asegurando que las páginas del documento resultante sigan el orden secuencial correcto.
  - **Fusión de PDFs (`PdfProcessor.mergePdfs`)**: Los documentos PDF seleccionados se ordenan numéricamente antes de fusionarse, garantizando que se concatenen en la secuencia lógica correcta (ej: `doc_1.pdf` antes de `doc_2.pdf`).
  - **Procesamiento de PDFs (`PdfProcessor.pdfsToImages`, `splitPdfs`, `optimizePdfs`)**: El procesamiento por lotes para convertir PDFs a imágenes, dividirlos u optimizarlos ahora se ejecuta de manera secuencial ordenada.
  - **Rotación y Marcas de Agua (`PdfRotateProcessor`, `PdfWatermarkProcessor`)**: Rotaciones y aplicación de marcas de agua por lotes ahora procesan y guardan los archivos resultantes en orden.
  - **Extracción de Texto (`PdfTextExtractorProcessor`)**: Los textos extraídos se generan secuencialmente de acuerdo al orden de los PDFs de origen.
  - **Eliminación de Fondo con IA (`ImageBgRemoverProcessor`)**: Las imágenes ahora se ordenan de forma secuencial antes de removerles el fondo con ML Kit Selfie Segmentation.
- **Optimización de Hilos y Rendimiento Asíncrono (`MainActivity.kt`)**: Se migraron y estructuraron los métodos del `MethodChannel` para que todo el procesamiento pesado (como la fusión de PDFs, compresión de imágenes y la eliminación de fondos mediante IA) se ejecute asíncronamente en hilos secundarios de fondo (`Dispatchers.IO` o mediante corutinas asíncronas). Esto previene por completo bloqueos en el hilo principal (*Main UI Thread*) de Android, garantizando que la interfaz gráfica de Flutter se mantenga fluida y libre de congelamientos o diálogos de "Application Not Responding" (ANR).

### v1.9.1+10 — 2026-05-09

- **Optimización de Inicio**: Se corrigió el parpadeo de la vista de bienvenida (WelcomeScreen) al iniciar la aplicación, mostrando un indicador de carga nativo y transicionando directamente a Home si el usuario ya había entrado previamente.
- **Navegación Personalizada**: Implementación de una navegación nativa con efecto de desvanecimiento (*fade*) en todas las pantallas (reemplazando transiciones por defecto) sin depender de librerías externas.
- **Splash Screen (Android)**: Se ajustaron las dimensiones del logo (`mi_logo`) en el `launch_background.xml` para mejorar la visualización en la pantalla de carga nativa.

### v1.8.0+8 — 2026-04-05

> **6 nuevas herramientas** de procesamiento offline integradas en esta versión.

- **📷 Document Scanner**: Escanea documentos físicos con la cámara usando Google ML Kit Document Scanner. La UI de captura es nativa de Android. Permite hasta 50 páginas, con vista previa en Flutter antes de guardar y elección de formato: PDF o JPG.
- **💧 Watermark PDF**: Añade texto diagonal semitransparente (marca de agua) a todas las páginas de uno o varios PDFs. El usuario puede personalizar el texto y la opacidad (10%–90%). Procesado nativamente con iTextG.
- **🔄 Rotate PDF**: Rota páginas de PDFs a 90° ↻, 180° o 90° ↺. Permite aplicar la rotación a todas las páginas o solo a un rango específico (ej: `1,3-5`). Procesado con iTextG sin pérdida de calidad.
- **✂️ Crop & Rotate Image**: Recorta y rota imágenes con precisión usando la librería UCrop (integrada vía `image_cropper`). Soporta múltiples proporciones y rotación libre. El resultado se guarda en la carpeta elegida.
- **📝 Extraer Texto de PDF**: Extrae el texto raw de PDFs digitales procesados en hilos separados. Guarda el resultado como archivo `.txt`. Usa iTextG internamente.
- **🧹 Quitar Fondo (Remove Background)**: Elimina el fondo de fotos de personas o selfies usando ML Kit Selfie Segmentation. Exporta como PNG con canal alfa transparente.

### v1.7.0+7

- **Optimización de UI/Estado**: Implementación de `ListenableBuilder` y `ValueNotifier` en todas las pantallas para un mejor rendimiento y reactividad.
- **Refactorización**: Uso de `mixin` en las pantallas de conversión PDF para reutilización de código.
- **Descargas mejoradas**: La descarga de actualizaciones (APK) desde la sección "Acerca de" ahora utiliza conexiones tipo _stream_, optimizando el uso de memoria y la estabilidad de la descarga.

## ✨ Características

### 📄 Herramientas PDF

- **Comprimir PDF**: Reduce el tamaño de archivos PDF manteniendo la calidad
- **Unir PDFs**: Combina múltiples archivos PDF en un solo documento
- **Separar PDF**: Extrae rangos de páginas en documentos independientes
- **PDF a Imágenes**: Convierte páginas de PDF a imágenes de alta calidad
- **Imágenes a PDF**: Crea documentos PDF a partir de múltiples imágenes
- **Extraer Texto**: Extrae el texto original de PDFs digitales a archivos `.txt`
- **Marca de Agua**: Añade texto diagonal semitransparente a cada página del PDF
- **Rotar Páginas**: Rota todas o páginas específicas de un PDF a 90°, 180° o 270°

### 🖼️ Herramientas de Imagen

- **Comprimir Imágenes**: Reduce el tamaño de las imágenes manteniendo la calidad visual
- **Conversión de Formatos**: Soporte para JPG, JPEG, PNG, BMP, TIFF y WEBP
- **Quitar Fondo**: Elimina el fondo de selfies y fotos de personas usando IA (ML Kit)
- **Recortar & Rotar**: Recorta y rota imágenes con herramientas de precisión (UCrop)

### 📷 Utilidades

- **Escáner de Documentos**: Escanea documentos físicos con la cámara, con recorte y corrección de perspectiva automáticos. Exporta como PDF o JPG.

## 🛠️ Stack Tecnológico

### Frontend
- **[Flutter](https://flutter.dev)**: Framework multiplataforma para desarrollo móvil
- **[Dart](https://dart.dev)**: Lenguaje de programación principal
- **[image_cropper](https://pub.dev/packages/image_cropper)**: Recorte y rotación de imágenes (UCrop)

### Backend/Nativo (Android — Kotlin)
- **[iTextG 5.5.10](https://github.com/itext/itextpdf)**: Manipulación avanzada de PDFs (merge, split, compress, watermark, rotate, extract text)
- **[Google ML Kit — Document Scanner](https://developers.google.com/ml-kit)**: Escaneo nativo de documentos con corrección de perspectiva
- **[Google ML Kit — Selfie Segmentation](https://developers.google.com/ml-kit)**: Eliminación de fondos en imágenes de personas
- **[PDFBox Android](https://github.com/TomRoush/PdfBox-Android)**: Renderizado de páginas PDF a imágenes
- **Kotlin Coroutines**: Procesamiento paralelo sin bloquear el hilo principal

## 📦 Requisitos de Desarrollo

- **Flutter SDK** 3.x o superior
- **Dart SDK** 3.x o superior
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Android SDK** (API 23+)
- **Kotlin** 1.9+

## 🚀 Instalación para Desarrollo

### 1. Clonar el repositorio

```bash
git clone https://github.com/Moisessantos45/zylix-app.git
cd zylix
```

### 2. Instalar dependencias

```bash
# Instalar dependencias de Flutter
flutter pub get
```

### 3. Verificar configuración

```bash
# Verificar que Flutter esté configurado correctamente
flutter doctor
```

## 🏃 Desarrollo

### Modo de desarrollo

Ejecuta la aplicación en modo de desarrollo:

```bash
flutter run
```

### Características del modo desarrollo

- ✅ Hot reload para cambios rápidos
- ✅ Hot restart para cambios estructurales
- ✅ DevTools para debugging
- ✅ Logs en tiempo real

### Ejecutar en dispositivo específico

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>
```

## 🔨 Compilación

### Compilar para producción (APK)

```bash
# APK de release
flutter build apk --release

# APK dividido por ABI (recomendado para producción)
flutter build apk --split-per-abi --release
```

### Compilar App Bundle (Para Google Play)

```bash
flutter build appbundle --release
```

Los archivos compilados se generarán en `build/app/outputs/`.

## 📖 Uso

1. **Selecciona la herramienta**: Elige la operación que deseas realizar desde la pantalla principal
2. **Selecciona archivos**: Toca el botón para elegir archivos PDF o imágenes desde tu dispositivo
3. **Configura opciones**: Ajusta parámetros como la calidad de compresión (si aplica)
4. **Selecciona carpeta de salida**: Indica dónde guardar los archivos procesados
5. **Procesa**: ¡Y listo! Tus archivos estarán listos en segundos

## 📁 Estructura del Proyecto

```
zylix/
├── android/                  # Código nativo Android
│   └── app/src/main/
│       └── kotlin/          # Implementaciones nativas (Kotlin)
├── lib/                     # Código Dart/Flutter
│   ├── models/             # Modelos de datos
│   ├── providers/          # Gestión de estado
│   ├── screens/            # Pantallas de la aplicación
│   ├── widgets/            # Widgets reutilizables
│   └── main.dart           # Punto de entrada
├── assets/                  # Recursos (imágenes, fuentes, etc.)
└── pubspec.yaml            # Dependencias y configuración
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**Moisessantos45**
- Email: santosxphdz34@gmail.com
- GitHub: [@Moisessantos45](https://github.com/Moisessantos45)

## 🙏 Agradecimientos

- [Flutter](https://flutter.dev) - Por el increíble framework
- [PDFBox Android](https://github.com/TomRoush/PdfBox-Android) - Por la potente biblioteca de PDF
- [Kotlin](https://kotlinlang.org) - Por el lenguaje moderno y expresivo

---

<div align="center">
Hecho con ❤️ por Moisessantos45 usando Flutter y Kotlin
</div>
