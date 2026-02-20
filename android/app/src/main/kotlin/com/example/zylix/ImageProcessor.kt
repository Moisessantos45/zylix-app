package com.example.zylix

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull

/** Procesador de imágenes para optimización, conversión y manipulación. */
object ImageProcessor {
    private const val TAG = "ImageProcessor"

    /**
     * Carga un bitmap desde una ruta (content:// o file://).
     * @param context Contexto de la aplicación
     * @param path Ruta de la imagen
     * @return Bitmap o null si hay error
     */
    fun loadBitmapFromPath(context: Context, path: String): Bitmap? {
        return try {
            if (path.startsWith("content://")) {
                val uri = Uri.parse(path)
                context.contentResolver.openInputStream(uri)?.use { input ->
                    BitmapFactory.decodeStream(input)
                }
            } else {
                BitmapFactory.decodeFile(path)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error loading bitmap from: $path", e)
            null
        }
    }

    /**
     * Carga un bitmap de forma segura con muestreo para evitar OutOfMemoryError.
     * @param context Contexto de la aplicación
     * @param path Ruta de la imagen
     * @return Bitmap o null si hay error
     */
    fun loadBitmapFromPathSafe(context: Context, path: String): Bitmap? {
        return try {
            val uri = Uri.parse(path)
            val options =
                    BitmapFactory.Options().apply {
                        inJustDecodeBounds = true
                        context.contentResolver.openInputStream(uri)?.use {
                            BitmapFactory.decodeStream(it, null, this)
                        }
                        inJustDecodeBounds = false

                        inSampleSize = calculateInSampleSize(this, 2048, 2048)
                        inPreferredConfig = Bitmap.Config.ARGB_8888
                    }

            context.contentResolver.openInputStream(uri)?.use {
                BitmapFactory.decodeStream(it, null, options)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Safe load failed: $path", e)
            null
        }
    }

    /**
     * Decodifica una miniatura desde un InputStream.
     * @param inputStream Stream de entrada
     * @param maxSize Tamaño máximo de la miniatura
     * @return Bitmap miniatura o null si hay error
     */
    fun decodeThumbnail(inputStream: InputStream, maxSize: Int): Bitmap? {
        val options =
                BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                    BitmapFactory.decodeStream(inputStream, null, this)
                    inputStream.reset()

                    inSampleSize = calculateInSampleSize(this, maxSize, maxSize)
                    inJustDecodeBounds = false
                }
        return BitmapFactory.decodeStream(inputStream, null, options)
    }

    /**
     * Calcula el factor de muestreo adecuado para redimensionar una imagen.
     * @param options Opciones del BitmapFactory con dimensiones originales
     * @param reqWidth Ancho requerido
     * @param reqHeight Alto requerido
     * @return Factor de muestreo (inSampleSize)
     */
    fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2

            while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }

    /**
     * Optimiza imágenes reduciendo calidad y tamaño.
     * @param context Contexto de la aplicación
     * @param imagePaths Lista de rutas de imágenes
     * @param outputDirPath Directorio de salida
     * @param quality Calidad de compresión (0-100)
     * @param maxWidth Ancho máximo
     * @param maxHeight Alto máximo
     */
    fun optimizeImages(
            context: Context,
            imagePaths: List<String>,
            outputDirPath: String,
            quality: Int = 80,
            maxWidth: Int = 1920,
            maxHeight: Int = 2560
    ) {
        imagePaths.forEach { inputPath ->
            try {
                Log.d(TAG, "Optimizing: $inputPath")

                val originalBitmap = loadBitmapFromPath(context, inputPath) ?: return@forEach

                if (originalBitmap.width <= 0 || originalBitmap.height <= 0) {
                    originalBitmap.recycle()
                    return@forEach
                }

                val scaledBitmap =
                        if (originalBitmap.width > maxWidth || originalBitmap.height > maxHeight) {
                            val scale =
                                    minOf(
                                            maxWidth.toFloat() / originalBitmap.width,
                                            maxHeight.toFloat() / originalBitmap.height
                                    )

                            Bitmap.createScaledBitmap(
                                    originalBitmap,
                                    (originalBitmap.width * scale).toInt(),
                                    (originalBitmap.height * scale).toInt(),
                                    true
                            )
                        } else originalBitmap

                val fileName = "opt_${UriHelper.getFileNameFromPath(context, inputPath)}"

                val (outputStream, outputPath) =
                        FileUtils.createOutputFile(context, outputDirPath, fileName, "image/jpeg")
                                ?: run {
                                    originalBitmap.recycle()
                                    if (scaledBitmap != originalBitmap) scaledBitmap.recycle()
                                    return@forEach
                                }

                try {
                    outputStream.use { out ->
                        scaledBitmap.compress(Bitmap.CompressFormat.JPEG, quality, out)
                    }

                    Log.d(TAG, "Saved: $fileName")
                } finally {
                    if (scaledBitmap != originalBitmap) scaledBitmap.recycle()
                    originalBitmap.recycle()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error optimizing image: $inputPath", e)
            }
        }
    }

    /**
     * Convierte imágenes a un formato específico.
     * @param context Contexto de la aplicación
     * @param imagePaths Lista de rutas de imágenes
     * @param outputDirPath Directorio de salida
     * @param targetFormat Formato destino (JPEG, PNG, WEBP_LOSSY, WEBP_LOSSLESS)
     */
    fun convertImagesToFormat(
            context: Context,
            imagePaths: List<String>,
            outputDirPath: String,
            targetFormat: String = "WEBP_LOSSY"
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            imagePaths.forEach { inputPath ->
                var bitmap: Bitmap? = null
                var tempFile: File? = null

                try {
                    Log.d(TAG, "Converting: $inputPath → $targetFormat")

                    bitmap =
                            loadBitmapFromPathSafe(context, inputPath)
                                    ?: run {
                                        Log.e(TAG, "Failed to load: $inputPath")
                                        return@forEach
                                    }

                    if (bitmap.width <= 0 || bitmap.height <= 0) {
                        Log.e(TAG, "Invalid bitmap: ${bitmap.width}x${bitmap.height}")
                        return@forEach
                    }

                    Log.d(TAG, "Bitmap loaded: ${bitmap.width}x${bitmap.height}")

                    val (extension, compressFormat, quality, mimeType) =
                            when (targetFormat.uppercase()) {
                                "JPEG" ->
                                        Quadruple(
                                                "jpg",
                                                Bitmap.CompressFormat.JPEG,
                                                85,
                                                "image/jpeg"
                                        )
                                "PNG" ->
                                        Quadruple(
                                                "png",
                                                Bitmap.CompressFormat.PNG,
                                                100,
                                                "image/png"
                                        )
                                "WEBP_LOSSY" ->
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                            Quadruple(
                                                    "webp",
                                                    Bitmap.CompressFormat.WEBP_LOSSY,
                                                    85,
                                                    "image/webp"
                                            )
                                        } else {
                                            @Suppress("DEPRECATION")
                                            Quadruple(
                                                    "webp",
                                                    Bitmap.CompressFormat.WEBP,
                                                    85,
                                                    "image/webp"
                                            )
                                        }
                                "WEBP_LOSSLESS" ->
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                            Quadruple(
                                                    "webp",
                                                    Bitmap.CompressFormat.WEBP_LOSSLESS,
                                                    100,
                                                    "image/webp"
                                            )
                                        } else {
                                            @Suppress("DEPRECATION")
                                            Quadruple(
                                                    "webp",
                                                    Bitmap.CompressFormat.WEBP,
                                                    100,
                                                    "image/webp"
                                            )
                                        }
                                else ->
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                            Quadruple(
                                                    "webp",
                                                    Bitmap.CompressFormat.WEBP_LOSSY,
                                                    85,
                                                    "image/webp"
                                            )
                                        } else {
                                            @Suppress("DEPRECATION")
                                            Quadruple(
                                                    "webp",
                                                    Bitmap.CompressFormat.WEBP,
                                                    85,
                                                    "image/webp"
                                            )
                                        }
                            }

                    val baseName =
                            UriHelper.getFileNameFromPath(context, inputPath)
                                    .substringBeforeLast('.')
                    val fileName = "$baseName.$extension"

                    tempFile =
                            File(context.cacheDir, "temp_${System.currentTimeMillis()}_$extension")

                    withTimeoutOrNull(5000) {
                        FileOutputStream(tempFile).use { out ->
                            val success = bitmap.compress(compressFormat, quality, out)
                            if (!success) throw Exception("Compress failed")
                            out.flush()
                        }
                    }
                            ?: throw Exception("Compress timeout")

                    val result =
                            FileUtils.createOutputFile(context, outputDirPath, fileName, mimeType)
                    if (result == null) {
                        Log.e(TAG, "No output: $fileName")
                        return@forEach
                    }

                    val (outputStream, outputPath) = result
                    tempFile.inputStream().use { tempInput ->
                        outputStream.use { out ->
                            tempInput.copyTo(out)
                            out.flush()
                        }
                    }

                    Log.d(TAG, "$fileName → $outputPath (${tempFile.length()} bytes)")
                } catch (e: Exception) {
                    Log.e(TAG, "Error $inputPath: ${e.message}", e)
                } finally {
                    bitmap?.recycle()
                    tempFile?.deleteSafely()
                }
            }
        }
    }
}

/** Data class para tuplas de 4 elementos. */
data class Quadruple<A, B, C, D>(val first: A, val second: B, val third: C, val fourth: D)

/** Enumeración de formatos de imagen soportados. */
enum class ImageFormat {
    JPEG,
    PNG,
    WEBP,
    HEIF
}
