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
| v1.0.2 | Android | [⬇️ Descargar](https://rmovevnbyamzdvslzqaq.supabase.co/storage/v1/object/public/apps/Portafolio/zylix-1.0.2.apk) | 2025-12-30 |
| v1.0.1 | Android | [⬇️ Descargar](https://rmovevnbyamzdvslzqaq.supabase.co/storage/v1/object/public/apps/Portafolio/zylix-1.0.1.apk) | 2025-12-23 |

> **Nota**: La aplicación requiere Android 6.0 (API 23) o superior.

### Instalación Rápida (Android)

1. Descarga el archivo `.apk` desde el link anterior
2. Habilita la instalación de aplicaciones de fuentes desconocidas en tu dispositivo
3. Abre el archivo descargado y confirma la instalación
4. ¡Listo! Ya puedes usar Zylix

## ✨ Características

### 📄 Herramientas PDF

- **Comprimir PDF**: Reduce el tamaño de archivos PDF manteniendo la calidad
- **Unir PDFs**: Combina múltiples archivos PDF en un solo documento
- **PDF a Imágenes**: Convierte páginas de PDF a imágenes de alta calidad
- **Imágenes a PDF**: Crea documentos PDF a partir de múltiples imágenes

### 🖼️ Herramientas de Imagen

- **Comprimir Imágenes**: Reduce el tamaño de las imágenes manteniendo la calidad visual
- **Conversión de Formatos**: Soporte para JPG, JPEG, PNG, BMP, TIFF y WEBP
- **Optimización Inteligente**: Compresión adaptativa según el tipo de imagen

## 🛠️ Stack Tecnológico

### Frontend
- **[Flutter](https://flutter.dev)**: Framework multiplataforma para desarrollo móvil
- **[Dart](https://dart.dev)**: Lenguaje de programación principal

### Backend/Nativo
- **[Kotlin](https://kotlinlang.org)**: Código nativo Android para procesamiento eficiente
- **[PDFBox Android](https://github.com/TomRoush/PdfBox-Android)**: Biblioteca para manipulación de PDFs
- **Android ImageDecoder**: Procesamiento nativo de imágenes

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
