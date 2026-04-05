package com.example.zylix

import android.content.Context
import android.net.Uri
import android.util.Log
import com.itextpdf.text.pdf.PdfName
import com.itextpdf.text.pdf.PdfNumber
import com.itextpdf.text.pdf.PdfReader
import com.itextpdf.text.pdf.PdfStamper
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

object PdfRotateProcessor {
    private const val TAG = "PdfRotate"

    suspend fun rotatePdfs(
        context: Context,
        pdfPaths: List<String>,
        outputDirPath: String,
        angleDegrees: Int,
        pageRange: String? = null,
    ) {
        withContext(Dispatchers.IO) {
            pdfPaths.forEach { inputPath ->
                processSinglePdf(context, inputPath, outputDirPath, angleDegrees, pageRange)
            }
        }
    }

    private fun processSinglePdf(
        context: Context,
        inputPath: String,
        outputDirPath: String,
        angleDegrees: Int,
        pageRange: String?,
    ) {
        var reader: PdfReader? = null
        try {
            Log.d(TAG, "Rotating ($angleDegrees°) PDF: $inputPath")

            val pdfBytes = if (inputPath.startsWith("content://")) {
                val uri = Uri.parse(inputPath)
                context.contentResolver.openInputStream(uri)?.use { it.readBytes() }
                    ?: run { Log.e(TAG, "Cannot open: $inputPath"); return }
            } else {
                java.io.File(inputPath).readBytes()
            }

            reader = PdfReader(pdfBytes)
            val totalPages = reader.numberOfPages

            val pagesToRotate = resolvePageSet(pageRange, totalPages)

            val outputBuffer = ByteArrayOutputStream()
            val stamper = PdfStamper(reader, outputBuffer)

            for (page in pagesToRotate) {
                val pageDict = reader.getPageN(page)
                val currentRotation = reader.getPageRotation(page)
                val newRotation = (currentRotation + angleDegrees) % 360
                pageDict.put(PdfName.ROTATE, PdfNumber(newRotation))
            }

            stamper.close()
            reader.close()
            reader = null

            val originalName = if (inputPath.startsWith("content://")) {
                UriHelper.getFileNameFromUri(context, Uri.parse(inputPath))
                    .substringBeforeLast('.')
            } else {
                java.io.File(inputPath).nameWithoutExtension
            }
            val suffix = when (angleDegrees) {
                90 -> "rot90"
                180 -> "rot180"
                270 -> "rot270"
                else -> "rotated"
            }
            val outputFileName = "${originalName}_$suffix.pdf"

            val fileResult = FileUtils.createOutputFile(
                context, outputDirPath, outputFileName, "application/pdf"
            ) ?: run { Log.e(TAG, "Cannot create output: $outputFileName"); return }

            val (outputStream, outputPath) = fileResult
            outputStream.use { it.write(outputBuffer.toByteArray()) }

            Log.d(TAG, "Saved rotated PDF: $outputPath")

        } catch (e: Exception) {
            Log.e(TAG, "Error rotating PDF: $inputPath", e)
        } finally {
            try { reader?.close() } catch (_: Exception) {}
        }
    }

    private fun resolvePageSet(pageRange: String?, totalPages: Int): Set<Int> {
        if (pageRange.isNullOrBlank()) return (1..totalPages).toSet()

        val pages = mutableSetOf<Int>()
        pageRange.split(",").forEach { part ->
            val trimmed = part.trim()
            if (trimmed.contains("-")) {
                val bounds = trimmed.split("-")
                val from = bounds[0].trim().toIntOrNull() ?: 1
                val to = bounds[1].trim().toIntOrNull() ?: totalPages
                (from.coerceAtLeast(1)..to.coerceAtMost(totalPages)).forEach { pages.add(it) }
            } else {
                trimmed.toIntOrNull()?.let { if (it in 1..totalPages) pages.add(it) }
            }
        }
        return pages
    }
}
