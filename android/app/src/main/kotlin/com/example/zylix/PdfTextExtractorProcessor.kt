package com.example.zylix

import android.content.Context
import android.net.Uri
import android.util.Log
import com.itextpdf.text.pdf.PdfReader
import com.itextpdf.text.pdf.parser.PdfTextExtractor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.InputStream

object PdfTextExtractorProcessor {
    private const val TAG = "PdfTextExtractor"

    suspend fun extractTextFromPdfs(context: Context, pdfPaths: List<String>, outputDirPath: String) {
        withContext(Dispatchers.IO) {
            pdfPaths.forEach { pdfPath ->
                 processPdfFile(context, pdfPath, outputDirPath)
            }
        }
    }

    private fun processPdfFile(context: Context, inputPath: String, outputDirPath: String) {
        var inputStream: InputStream? = null
        try {
            val pdfName =
                    if (inputPath.startsWith("content://")) {
                        UriHelper.getFileNameFromUri(context, Uri.parse(inputPath))
                                .substringBeforeLast('.')
                    } else {
                        File(inputPath).nameWithoutExtension
                    }

            Log.d(TAG, "Extracting text from: $pdfName")

            inputStream =
                    if (inputPath.startsWith("content://")) {
                        context.contentResolver.openInputStream(Uri.parse(inputPath))
                    } else {
                        File(inputPath).inputStream()
                    }

            if (inputStream == null) {
                Log.w(TAG, "Cannot open input stream for: $inputPath")
                return
            }

            var extractedText = ""
            try {
                val reader = PdfReader(inputStream)
                val numPages = reader.numberOfPages
                val stringBuilder = StringBuilder()

                for (i in 1..numPages) {
                    val pageText = PdfTextExtractor.getTextFromPage(reader, i)
                    if (pageText != null) {
                        stringBuilder.append(pageText.trim()).append("\n")
                    }
                }
                reader.close()
                extractedText = stringBuilder.toString()
            } catch (e: Exception) {
                Log.e(TAG, "Error reading PDF or it might be password protected: $pdfName", e)
                extractedText = "Error al extraer texto o el archivo está protegido.\nDetalles: ${e.message}"
            }

            val outputFileName = "${pdfName}_extraido.txt"
            
            val (outputStream, outputPath) = FileUtils.createOutputFile(
                context,
                outputDirPath,
                outputFileName,
                "text/plain"
            ) ?: run {
                Log.e(TAG, "Could not create output TXT file for: $pdfName")
                return
            }

            outputStream.use { out ->
                out.write(extractedText.toByteArray(Charsets.UTF_8))
                Log.d(TAG, "Text successfully saved: $outputFileName")
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error processing PDF for text extraction: $inputPath", e)
        } finally {
            try {
                inputStream?.close()
            } catch (e: Exception) {
                Log.w(TAG, "Failed to close input stream", e)
            }
        }
    }
}
