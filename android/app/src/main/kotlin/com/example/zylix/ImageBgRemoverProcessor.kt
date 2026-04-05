package com.example.zylix

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.net.Uri
import android.util.Log
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.segmentation.Segmentation
import com.google.mlkit.vision.segmentation.selfie.SelfieSegmenterOptions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import java.io.File

object ImageBgRemoverProcessor {
    private const val TAG = "ImageBgRemover"

    suspend fun removeBackground(context: Context, imagePaths: List<String>, outputDirPath: String) {
        withContext(Dispatchers.IO) {
            val options = SelfieSegmenterOptions.Builder()
                .setDetectorMode(SelfieSegmenterOptions.SINGLE_IMAGE_MODE)
                .enableRawSizeMask()
                .build()

            val segmenter = Segmentation.getClient(options)
            
            try {
                imagePaths.forEach { inputPath ->
                    processSingleImage(context, segmenter, inputPath, outputDirPath)
                }
            } finally {
                segmenter.close()
            }
        }
    }

    private suspend fun processSingleImage(
        context: Context,
        segmenter: com.google.mlkit.vision.segmentation.Segmenter,
        inputPath: String,
        outputDirPath: String
    ) {
        var originalBitmap: Bitmap? = null
        try {
            val imageName = if (inputPath.startsWith("content://")) {
                UriHelper.getFileNameFromUri(context, Uri.parse(inputPath)).substringBeforeLast('.')
            } else {
                File(inputPath).nameWithoutExtension
            }

            Log.d(TAG, "Removing background for: $imageName")

            originalBitmap = ImageProcessor.loadBitmapFromPath(context, inputPath)
            if (originalBitmap == null || originalBitmap.width <= 0 || originalBitmap.height <= 0) {
                Log.w(TAG, "Cannot load valid bitmap from: $inputPath")
                return
            }

            val inputImage = InputImage.fromBitmap(originalBitmap, 0)
            
            val mask = segmenter.process(inputImage).await()
            val maskBuffer = mask.buffer
            val width = mask.width
            val height = mask.height

            val workingBitmap = if (originalBitmap.width != width || originalBitmap.height != height) {
                Log.w(TAG, "Mask bounds ($width x $height) don't match bitmap (${originalBitmap.width} x ${originalBitmap.height}). Scaling bitmap.")
                Bitmap.createScaledBitmap(originalBitmap, width, height, true)
            } else {
                originalBitmap
            }

            val pixels = IntArray(width * height)
            workingBitmap.getPixels(pixels, 0, width, 0, 0, width, height)

            maskBuffer.rewind()
            
            for (i in 0 until (width * height)) {
                val fgConfidence = maskBuffer.float
                if (fgConfidence < 0.5f) {
                    pixels[i] = Color.TRANSPARENT
                }
            }

            val outputBitmap = Bitmap.createBitmap(pixels, width, height, Bitmap.Config.ARGB_8888)

            if (workingBitmap != originalBitmap) {
                workingBitmap.recycle()
            }

            val outputFileName = "${imageName}_no_bg.png"
            val fileCreationResult = FileUtils.createOutputFile(
                context,
                outputDirPath,
                outputFileName,
                "image/png"
            )

            if (fileCreationResult == null) {
                Log.e(TAG, "Could not create output file for: $outputFileName")
                outputBitmap.recycle()
                return
            }

            val (outputStream, outputPath) = fileCreationResult
            outputStream.use { out ->
                outputBitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                Log.d(TAG, "Successfully extracted foreground and saved: $outputFileName")
            }

            outputBitmap.recycle()

        } catch (e: Exception) {
            Log.e(TAG, "Error processing image background for $inputPath", e)
        } finally {
            originalBitmap?.recycle()
        }
    }
}
