package com.example.zylix

import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.util.Log
import com.itextpdf.text.BaseColor
import com.itextpdf.text.Element
import com.itextpdf.text.Font
import com.itextpdf.text.Phrase
import com.itextpdf.text.pdf.BaseFont
import com.itextpdf.text.pdf.ColumnText
import com.itextpdf.text.pdf.PdfGState
import com.itextpdf.text.pdf.PdfReader
import com.itextpdf.text.pdf.PdfStamper
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

object PdfWatermarkProcessor {
    private const val TAG = "PdfWatermark"

    suspend fun addWatermark(
        context: Context,
        pdfPaths: List<String>,
        outputDirPath: String,
        watermarkText: String,
        opacity: Float = 0.3f,
        fontSize: Float = 48f,
    ) {
        withContext(Dispatchers.IO) {
            pdfPaths.forEach { inputPath ->
                processSinglePdf(
                    context = context,
                    inputPath = inputPath,
                    outputDirPath = outputDirPath,
                    watermarkText = watermarkText,
                    opacity = opacity,
                    fontSize = fontSize,
                )
            }
        }
    }

    private fun processSinglePdf(
        context: Context,
        inputPath: String,
        outputDirPath: String,
        watermarkText: String,
        opacity: Float,
        fontSize: Float,
    ) {
        var reader: PdfReader? = null
        try {
            Log.d(TAG, "Adding watermark to: $inputPath")

            val pdfBytes = if (inputPath.startsWith("content://")) {
                val uri = Uri.parse(inputPath)
                context.contentResolver.openInputStream(uri)?.use { it.readBytes() }
                    ?: run {
                        Log.e(TAG, "Cannot open input: $inputPath")
                        return
                    }
            } else {
                java.io.File(inputPath).readBytes()
            }

            reader = PdfReader(pdfBytes)
            val outputBuffer = ByteArrayOutputStream()
            val stamper = PdfStamper(reader, outputBuffer)

            val baseFont = BaseFont.createFont(
                BaseFont.HELVETICA_BOLD,
                BaseFont.WINANSI,
                BaseFont.NOT_EMBEDDED
            )
            val font = Font(baseFont, fontSize, Font.BOLD, BaseColor(128, 128, 128))

            val gState = PdfGState().apply {
                setFillOpacity(opacity)
                setStrokeOpacity(opacity)
            }

            val numPages = reader.numberOfPages
            for (page in 1..numPages) {
                val pageSize = reader.getPageSizeWithRotation(page)
                val centerX = (pageSize.left + pageSize.right) / 2f
                val centerY = (pageSize.bottom + pageSize.top) / 2f

                val canvas = stamper.getOverContent(page)
                canvas.saveState()
                canvas.setGState(gState)
                canvas.beginText()

                ColumnText.showTextAligned(
                    canvas,
                    Element.ALIGN_CENTER,
                    Phrase(watermarkText, font),
                    centerX,
                    centerY,
                    45f
                )

                canvas.endText()
                canvas.restoreState()
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
            val outputFileName = "${originalName}_watermark.pdf"

            val fileResult = FileUtils.createOutputFile(
                context, outputDirPath, outputFileName, "application/pdf"
            )
            if (fileResult == null) {
                Log.e(TAG, "Cannot create output file: $outputFileName")
                return
            }

            val (outputStream, outputPath) = fileResult
            outputStream.use { out ->
                out.write(outputBuffer.toByteArray())
            }

            Log.d(TAG, "Watermark added and saved: $outputPath")

        } catch (e: Exception) {
            Log.e(TAG, "Error adding watermark to $inputPath", e)
        } finally {
            try { reader?.close() } catch (_: Exception) {}
        }
    }
}
