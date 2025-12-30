package com.example.zylix

import android.content.Context
import android.graphics.Bitmap
import android.graphics.pdf.PdfDocument
import android.graphics.pdf.PdfRenderer
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Log
import com.tom_roush.pdfbox.multipdf.PDFMergerUtility
import com.tom_roush.pdfbox.pdmodel.PDDocument
import java.io.File

/** Procesador de PDFs para conversión, fusión y optimización. */
object PdfProcessor {
    private const val TAG = "PdfProcessor"

    /**
     * Convierte imágenes a PDF.
     * @param context Contexto de la aplicación
     * @param imagePaths Lista de rutas de imágenes
     * @param pdfName Nombre del archivo PDF de salida (sin extensión)
     * @param outputPath Ruta de salida del PDF
     */
    fun imgToPdf(context: Context, imagePaths: List<String>, pdfName: String, outputPath: String) {
        val document = PdfDocument()
        val pageWidth = 595

        try {
            imagePaths.forEachIndexed { index, imagePath ->
                val bitmap =
                        ImageProcessor.loadBitmapFromPath(context, imagePath)
                                ?: return@forEachIndexed

                if (bitmap.width <= 0) {
                    bitmap.recycle()
                    return@forEachIndexed
                }

                val scaled =
                        Bitmap.createScaledBitmap(
                                bitmap,
                                pageWidth,
                                (bitmap.height * (pageWidth.toFloat() / bitmap.width)).toInt(),
                                true
                        )

                val pageHeight = scaled.height + 50

                val pageInfo =
                        PdfDocument.PageInfo.Builder(pageWidth, pageHeight, index + 1).create()

                val page = document.startPage(pageInfo)

                val canvas = page.canvas

                canvas.drawBitmap(scaled, 0f, 0f, null)

                document.finishPage(page)

                bitmap.recycle()

                if (scaled != bitmap) scaled.recycle()
            }

            if (outputPath.startsWith("content://")) {
                if (outputPath.contains("/tree/")) {
                    val dirUri = Uri.parse(outputPath)

                    val docFile =
                            androidx.documentfile.provider.DocumentFile.fromTreeUri(context, dirUri)
                                    ?: throw IllegalArgumentException(
                                            "Cannot access directory URI: $outputPath"
                                    )

                    val fileName = "$pdfName.pdf"

                    val newFile =
                            docFile.createFile("application/pdf", fileName)
                                    ?: throw IllegalArgumentException("Cannot create PDF file")

                    context.contentResolver.openOutputStream(newFile.uri)?.use { out ->
                        document.writeTo(out)
                    }
                } else {
                    val uri = Uri.parse(outputPath)

                    context.contentResolver.openOutputStream(uri)?.use { out ->
                        document.writeTo(out)
                    }
                }
            } else {
                java.io.FileOutputStream(outputPath).use { out -> document.writeTo(out) }
            }
        } finally {
            document.close()
        }
    }

    /**
     * Convierte páginas de PDFs a imágenes.
     * @param context Contexto de la aplicación
     * @param pdfPaths Lista de rutas de PDFs
     * @param outputDirPath Directorio de salida para las imágenes
     */
    fun pdfsToImages(context: Context, pdfPaths: List<String>, outputDirPath: String) {
        pdfPaths.forEach { pdfPath ->
            var fileDescriptor: ParcelFileDescriptor? = null
            var pdfRenderer: PdfRenderer? = null

            try {
                fileDescriptor = UriHelper.getFileDescriptorFromPath(context, pdfPath)

                if (fileDescriptor == null) {
                    Log.w(TAG, "Could not open file descriptor for: $pdfPath")
                    return@forEach
                }

                val pdfName =
                        if (pdfPath.startsWith("content://")) {
                            UriHelper.getFileNameFromUri(context, Uri.parse(pdfPath))
                                    .substringBeforeLast('.')
                        } else {
                            File(pdfPath).nameWithoutExtension
                        }
                val pdfSubfolderPath =
                        FileUtils.createSubfolder(context, outputDirPath, pdfName)
                                ?: run {
                                    Log.e(TAG, "Could not create subfolder for: $pdfName")
                                    return@forEach
                                }

                Log.d(TAG, "Processing PDF: $pdfName, subfolder path: $pdfSubfolderPath")

                pdfRenderer = PdfRenderer(fileDescriptor)

                repeat(pdfRenderer.pageCount) { pageIndex ->
                    var page: PdfRenderer.Page? = null
                    var bitmap: Bitmap? = null

                    try {
                        page = pdfRenderer.openPage(pageIndex)

                        bitmap =
                                Bitmap.createBitmap(
                                        page.width,
                                        page.height,
                                        Bitmap.Config.ARGB_8888
                                )

                        page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)

                        val fileName = "${pdfName}_page_${pageIndex + 1}.png"

                        val (outputStream, outputPath) =
                                FileUtils.createOutputFile(
                                        context,
                                        pdfSubfolderPath,
                                        fileName,
                                        "image/png"
                                )
                                        ?: return@repeat

                        Log.d(TAG, "Saving image: $fileName to path: $outputPath")

                        outputStream.use { out ->
                            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                        }

                        Log.d(TAG, "Successfully saved: $fileName")
                    } finally {
                        bitmap?.recycle()
                        page?.close()
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error converting PDF to images: $pdfPath", e)
            } finally {
                try {
                    pdfRenderer?.close()
                } catch (e: Exception) {
                    Log.e(TAG, "Error closing pdfRenderer", e)
                }

                try {
                    fileDescriptor?.close()
                } catch (e: Exception) {
                    Log.e(TAG, "Error closing fileDescriptor", e)
                }
            }
        }
    }

    /**
     * Fusiona múltiples PDFs en uno solo.
     * @param context Contexto de la aplicación
     * @param pdfPaths Lista de rutas de PDFs a fusionar
     * @param outputName Nombre del archivo PDF de salida (sin extensión)
     * @param outputDirPath Directorio de salida
     */
    fun mergePdfs(
            context: Context,
            pdfPaths: List<String>,
            outputName: String,
            outputDirPath: String
    ) {
        val merger = PDFMergerUtility()
        val inputStreams = mutableListOf<java.io.InputStream>()

        var (outputStream, outputPath) =
                FileUtils.createOutputFile(
                        context,
                        outputDirPath,
                        "$outputName.pdf",
                        "application/pdf"
                )
                        ?: throw Exception("Could not create output file")

        try {
            pdfPaths.forEach { pdfPath ->
                val inputStream =
                        if (pdfPath.startsWith("content://")) {
                            context.contentResolver.openInputStream(Uri.parse(pdfPath))
                        } else {
                            File(pdfPath).inputStream()
                        }

                if (inputStream != null) {
                    merger.addSource(inputStream)
                    inputStreams.add(inputStream)
                    Log.d(TAG, "Added: $pdfPath")
                } else {
                    Log.w(TAG, "File not found or could not be opened: $pdfPath")
                }
            }

            if (inputStreams.isEmpty()) {
                throw IllegalArgumentException("No valid PDF files to merge")
            }

            merger.destinationStream = outputStream

            merger.mergeDocuments(null)

            Log.d(TAG, "PDFs merged successfully to: $outputPath")
        } catch (e: Exception) {
            Log.e(TAG, "Error merging PDFs", e)
            throw e
        } finally {
            inputStreams.forEach {
                try {
                    it.close()
                } catch (e: Exception) {
                    Log.e(TAG, "Error closing input stream", e)
                }
            }

            try {
                outputStream.close()
            } catch (e: Exception) {
                Log.e(TAG, "Error closing output stream", e)
            }
        }
    }

    /**
     * Optimiza PDFs removiendo metadata.
     * @param context Contexto de la aplicación
     * @param pdfPaths Lista de rutas de PDFs a optimizar
     * @param outputDirPath Directorio de salida
     * @param quality Parámetro de calidad (actualmente no utilizado, reservado para futuras
     * mejoras)
     */
    fun optimizePdfs(
            context: Context,
            pdfPaths: List<String>,
            outputDirPath: String,
            quality: Int = 75
    ) {
        pdfPaths.forEach { inputPath ->
            var inputStream: java.io.InputStream? = null

            try {
                val pdfName =
                        if (inputPath.startsWith("content://")) {
                            UriHelper.getFileNameFromUri(context, Uri.parse(inputPath))
                                    .substringBeforeLast('.')
                        } else {
                            File(inputPath).nameWithoutExtension
                        }

                val outputFileName = "${pdfName}_optimizado.pdf"

                inputStream =
                        if (inputPath.startsWith("content://")) {
                            context.contentResolver.openInputStream(Uri.parse(inputPath))
                        } else {
                            File(inputPath).inputStream()
                        }
                val (outputStream, finalOutputPath) =
                        FileUtils.createOutputFile(
                                context,
                                outputDirPath,
                                outputFileName,
                                "application/pdf"
                        )
                                ?: run {
                                    Log.e(TAG, "Could not create output file for: $pdfName")
                                    return@forEach
                                }
                inputStream =
                        if (inputPath.startsWith("content://")) {
                            context.contentResolver.openInputStream(Uri.parse(inputPath))
                        } else {
                            File(inputPath).inputStream()
                        }
                inputStream?.use { input ->
                    PDDocument.load(input).use { document ->
                        document.documentInformation.apply {
                            author = null
                            creator = null
                            producer = null
                            subject = null
                            title = null
                            keywords = null
                        }

                        document.save(outputStream)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error optimizing PDF: $inputPath", e)
            } finally {
                inputStream?.close()
            }
        }
    }
}
