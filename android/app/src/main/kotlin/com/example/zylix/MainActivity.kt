package com.example.zylix

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.content.FileProvider
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult
import com.jakewharton.processphoenix.ProcessPhoenix
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "com.example.zylix/channel"

    private lateinit var versionManager: AppVersionManager

    private val PICK_IMAGES = 1001
    private val PICK_PDFS = 1002
    private val PICK_FOLDER = 1003
    private val SCAN_DOCUMENT = 1004
    private var pendingResult: MethodChannel.Result? = null
    private var pendingRequestCode: Int? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        versionManager = AppVersionManager(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (!filePath.isNullOrEmpty()) {
                        installApk(filePath)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is null or empty", null)
                    }
                }
                "get-app-version" -> {
                    val updateInfo = versionManager.checkForUpdate()
                    when (updateInfo) {
                        is UpdateInfo.FirstInstall -> {
                            result.success(
                                    mapOf(
                                            "status" to "first_install",
                                            "version" to updateInfo.version,
                                            "versionCode" to updateInfo.versionCode
                                    )
                            )
                        }
                        is UpdateInfo.Updated -> {
                            result.success(
                                    mapOf(
                                            "status" to "updated",
                                            "version" to updateInfo.version,
                                            "versionCode" to updateInfo.versionCode,
                                            "oldVersionCode" to updateInfo.oldVersionCode
                                    )
                            )
                        }
                        is UpdateInfo.SameVersion -> {
                            result.success(
                                    mapOf(
                                            "status" to "same_version",
                                            "version" to updateInfo.version,
                                            "versionCode" to updateInfo.versionCode
                                    )
                            )
                        }
                    }
                }
                "restart_app" -> {
                    ProcessPhoenix.triggerRebirth(context)
                    result.success(null)
                }
                "save-key-value" -> {
                    val argumentKey = call.argument<String>("key")
                    val value = call.argument<Boolean>("value")

                    if (!argumentKey.isNullOrEmpty() && value != null) {
                        val sharedPref = getSharedPreferences("zylix", Context.MODE_PRIVATE)
                        with(sharedPref.edit()) {
                            putBoolean(argumentKey, value)
                            apply()
                        }
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Key or value is null or empty", null)
                    }
                }
                "get-key-value" -> {
                    val argumentKey = call.argument<String>("key")

                    if (!argumentKey.isNullOrEmpty()) {
                        val sharedPref = getSharedPreferences("zylix", Context.MODE_PRIVATE)
                        val value = sharedPref.getBoolean(argumentKey, false)
                        result.success(value)
                    } else {
                        result.error("INVALID_ARGUMENT", "Key is null or empty", null)
                    }
                }
                "showNotification" -> {
                    try {
                        val title = call.argument<String>("title") ?: "Zylix"
                        val message = call.argument<String>("message") ?: ""
                        val channelId = call.argument<String>("channelId") ?: "default_channel_id"
                        val success =
                                NotificationHelper.showNotification(this, title, message, channelId)
                        if (success) {
                            result.success(null)
                        } else {
                            result.error(
                                    "NOTIFICATION_ERROR",
                                    "No se pudo mostrar la notificación (posible falta de permiso)",
                                    null
                            )
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error showing notification", e)
                        result.error("NOTIFICATION_ERROR", e.message ?: "Unknown error", null)
                    }
                }
                "pickMultipleImages" -> {
                    pendingResult = result
                    pendingRequestCode = PICK_IMAGES
                    pickMultipleImagesFromGallery()
                }
                "pickMultiplePDFs" -> {
                    pendingResult = result
                    pendingRequestCode = PICK_PDFS
                    pickMultiplePDFsFromStorage()
                }
                "setExecutable" -> {
                    val filePath = call.argument<String>("path")
                    val success = FileUtils.setExecutable(filePath)
                    result.success(success)
                }
                "pickFolder" -> {
                    pendingResult = result
                    pendingRequestCode = PICK_FOLDER
                    pickFolder()
                }
                "getBytesFromUri" -> {
                    val uriString = call.argument<String>("uri")
                    val bytes = UriHelper.getBytesFromUri(this, uriString)
                    result.success(bytes)
                }
                "loadThumbnailsBatch" -> {
                    val uriList = call.argument<List<String>>("uris") ?: emptyList()
                    val configs =
                            call.argument<List<Map<String, Any>>>("configs")
                                    ?: uriList.map { mapOf("maxSize" to 200, "quality" to 80) }

                    val byteArrays = mutableListOf<ByteArray>()

                    uriList.forEachIndexed { index, uriString ->
                        try {
                            val config =
                                    configs.getOrNull(index)
                                            ?: mapOf("maxSize" to 200, "quality" to 80)
                            val maxSize = (config["maxSize"] as? Int) ?: 200
                            val quality = (config["quality"] as? Int) ?: 80

                            val imageUri = Uri.parse(uriString)

                            val imageBytes =
                                    contentResolver.openInputStream(imageUri)?.use {
                                        it.readBytes()
                                    }

                            if (imageBytes != null && imageBytes.isNotEmpty()) {
                                val options =
                                        BitmapFactory.Options().apply {
                                            inJustDecodeBounds = true
                                            BitmapFactory.decodeByteArray(
                                                    imageBytes,
                                                    0,
                                                    imageBytes.size,
                                                    this
                                            )
                                            inSampleSize =
                                                    ImageProcessor.calculateInSampleSize(
                                                            this,
                                                            maxSize,
                                                            maxSize
                                                    )
                                            inJustDecodeBounds = false
                                        }

                                val bitmap =
                                        BitmapFactory.decodeByteArray(
                                                imageBytes,
                                                0,
                                                imageBytes.size,
                                                options
                                        )
                                if (bitmap != null) {
                                    val stream = ByteArrayOutputStream()
                                    bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
                                    byteArrays.add(stream.toByteArray())
                                    bitmap.recycle()
                                } else {
                                    byteArrays.add(ByteArray(0))
                                }
                            } else {
                                byteArrays.add(ByteArray(0))
                            }
                        } catch (e: Exception) {
                            Log.e("THUMBNAIL", "Error loading thumbnail for $uriString", e)
                            byteArrays.add(ByteArray(0))
                        }
                    }
                    result.success(byteArrays.map { it.toList() })
                }
                "getFileNamesBatch" -> getFileNamesBatch(call, result)
                "imgToPdf" -> {
                    val imagePaths = call.argument<List<String>>("imagePaths")
                    val pdfName = call.argument<String>("pdfName") ?: "output"
                    val outputPath = call.argument<String>("outputPath")
                    if (imagePaths != null && outputPath != null) {
                        try {
                            PdfProcessor.imgToPdf(this, imagePaths, pdfName, outputPath)
                            result.success(null)
                        } catch (e: Exception) {
                            Log.e("PDF", "Error in imgToPdf", e)
                            result.error("PDF_ERROR", e.message ?: "Unknown error", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Image paths or output path is null", null)
                    }
                }
                "pdfsToImages" -> {
                    val pdfPaths = call.argument<List<String>>("pdfPaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    if (pdfPaths != null && outputDirPath != null) {
                        try {
                            PdfProcessor.pdfsToImages(this, pdfPaths, outputDirPath)
                            result.success(null)
                        } catch (e: Exception) {
                            Log.e("PDF", "Error in pdfsToImages", e)
                            result.error("PDF_ERROR", e.message ?: "Unknown error", null)
                        }
                    } else {
                        result.error(
                                "INVALID_ARGUMENT",
                                "PDF paths or output dir path is null",
                                null
                        )
                    }
                }
                "mergePdfs" -> {
                    val pdfPaths = call.argument<List<String>>("pdfPaths")
                    val outputName = call.argument<String>("outputName") ?: "output"
                    val outputDirPath = call.argument<String>("outputDirPath")
                    if (pdfPaths != null && outputDirPath != null) {
                        PdfProcessor.mergePdfs(this, pdfPaths, outputName, outputDirPath)
                        result.success(null)
                    } else {
                        result.error(
                                "INVALID_ARGUMENT",
                                "PDF paths, output name or output dir path is null",
                                null
                        )
                    }
                }
                "optimizePdfPdf" -> {
                    val pdfPaths = call.argument<List<String>>("pdfPaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    val quality = call.argument<Int>("quality") ?: 75
                    if (pdfPaths != null && outputDirPath != null) {
                        try {
                            PdfProcessor.optimizePdfs(this, pdfPaths, outputDirPath, quality)
                            result.success(null)
                        } catch (e: Exception) {
                            Log.e("PDF", "Error in optimizePdfs", e)
                            result.error("PDF_ERROR", e.message ?: "Unknown error", null)
                        }
                    } else {
                        result.error(
                                "INVALID_ARGUMENT",
                                "PDF paths or output dir path is null",
                                null
                        )
                    }
                }
                "optimizeImages" -> {
                    val imagePaths = call.argument<List<String>>("imagePaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    val quality = call.argument<Int>("quality") ?: 80
                    val maxWidth = call.argument<Int>("maxWidth") ?: 1920
                    val maxHeight = call.argument<Int>("maxHeight") ?: 2560
                    if (imagePaths != null && outputDirPath != null) {
                        try {
                            ImageProcessor.optimizeImages(
                                    this,
                                    imagePaths,
                                    outputDirPath,
                                    quality,
                                    maxWidth,
                                    maxHeight
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            Log.e("IMG", "Error in optimizeImages", e)
                            result.error("IMG_ERROR", e.message ?: "Unknown error", null)
                        }
                    } else {
                        result.error(
                                "INVALID_ARGUMENT",
                                "Image paths or output dir path is null",
                                null
                        )
                    }
                }
                "convertImagesToFormat" -> {
                    val imagePaths = call.argument<List<String>>("imagePaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    val targetFormat = call.argument<String>("targetFormat") ?: "WEBP_LOSSY"
                    if (imagePaths != null && outputDirPath != null) {
                        try {
                            ImageProcessor.convertImagesToFormat(
                                    this,
                                    imagePaths,
                                    outputDirPath,
                                    targetFormat
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            Log.e("IMG", "Error in convertImagesToFormat", e)
                            result.error("IMG_ERROR", e.message ?: "Unknown error", null)
                        }
                    } else {
                        result.error(
                                "INVALID_ARGUMENT",
                                "Image paths or output dir path is null",
                                null
                        )
                    }
                }
                "splitPdfs" -> {
                    val pdfPaths = call.argument<List<String>>("pdfPaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    val startPage = call.argument<Int>("startPage") ?: 1
                    val endPage = call.argument<Int>("endPage") ?: -1
                    val splitAt = call.argument<Int>("splitAt") ?: 1
                    if (pdfPaths != null && outputDirPath != null) {
                        try {
                            PdfProcessor.splitPdfs(
                                    this,
                                    pdfPaths,
                                    outputDirPath,
                                    startPage,
                                    endPage,
                                    splitAt
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            Log.e("PDF", "Error in splitPdfs", e)
                            result.error("PDF_ERROR", e.message ?: "Unknown error", null)
                        }
                    } else {
                        result.error(
                                "INVALID_ARGUMENT",
                                "PDF paths or output dir path is null",
                                null
                        )
                    }
                }
                "extractTextFromPdfs" -> {
                    val pdfPaths = call.argument<List<String>>("pdfPaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    if (pdfPaths != null && outputDirPath != null) {
                        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main).launch {
                            try {
                                PdfTextExtractorProcessor.extractTextFromPdfs(
                                        this@MainActivity,
                                        pdfPaths,
                                        outputDirPath
                                )
                                result.success(null)
                            } catch (e: Exception) {
                                Log.e("PDF", "Error in extractTextFromPdfs", e)
                                result.error("PDF_ERROR", e.message ?: "Unknown error", null)
                            }
                        }
                    } else {
                        result.error(
                                "INVALID_ARGUMENT",
                                "PDF paths or output dir path is null",
                                null
                        )
                    }
                }
                "removeImageBackground" -> {
                    val imagePaths = call.argument<List<String>>("imagePaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    if (imagePaths != null && outputDirPath != null) {
                        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main).launch {
                            try {
                                ImageBgRemoverProcessor.removeBackground(
                                        this@MainActivity,
                                        imagePaths,
                                        outputDirPath
                                )
                                result.success(null)
                            } catch (e: Exception) {
                                Log.e("IMG", "Error in removeImageBackground", e)
                                result.error("IMG_ERROR", e.message ?: "Unknown error", null)
                            }
                        }
                    } else {
                        result.error(
                                "INVALID_ARGUMENT",
                                "Image paths or output dir path is null",
                                null
                        )
                    }
                }
                "startDocumentScanner" -> {
                    pendingResult = result
                    pendingRequestCode = SCAN_DOCUMENT
                    startDocumentScanner(result)
                }
                "rotatePdfs" -> {
                    val pdfPaths = call.argument<List<String>>("pdfPaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    val angle = call.argument<Int>("angle") ?: 90
                    val pageRange = call.argument<String>("pageRange")
                    if (pdfPaths != null && outputDirPath != null) {
                        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main).launch {
                            try {
                                PdfRotateProcessor.rotatePdfs(
                                    this@MainActivity,
                                    pdfPaths,
                                    outputDirPath,
                                    angle,
                                    pageRange,
                                )
                                result.success(null)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error in rotatePdfs", e)
                                result.error("PDF_ERROR", e.message ?: "Unknown error", null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "PDF paths or output dir is null", null)
                    }
                }
                "addWatermarkToPdfs" -> {
                    val pdfPaths = call.argument<List<String>>("pdfPaths")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    val watermarkText = call.argument<String>("watermarkText") ?: "CONFIDENTIAL"
                    val opacity = (call.argument<Double>("opacity") ?: 0.3).toFloat()
                    val fontSize = (call.argument<Double>("fontSize") ?: 48.0).toFloat()
                    if (pdfPaths != null && outputDirPath != null) {
                        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main).launch {
                            try {
                                PdfWatermarkProcessor.addWatermark(
                                    this@MainActivity,
                                    pdfPaths,
                                    outputDirPath,
                                    watermarkText,
                                    opacity,
                                    fontSize,
                                )
                                result.success(null)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error in addWatermarkToPdfs", e)
                                result.error("PDF_ERROR", e.message ?: "Unknown error", null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "PDF paths or output dir path is null", null)
                    }
                }
                "copyUriToDirectory" -> {
                    val sourceUri = call.argument<String>("sourceUri")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    val fileName = call.argument<String>("fileName")
                    if (sourceUri != null && outputDirPath != null && fileName != null) {
                        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO).launch {
                            try {
                                val uri = android.net.Uri.parse(sourceUri)
                                val inputStream = contentResolver.openInputStream(uri)
                                    ?: throw Exception("Cannot open stream for $sourceUri")
                                val (outputStream, _) = FileUtils.createOutputFile(
                                    this@MainActivity, outputDirPath, fileName,
                                    if (fileName.endsWith(".pdf")) "application/pdf" else "image/jpeg"
                                ) ?: throw Exception("Cannot create output file")
                                inputStream.use { inp -> outputStream.use { out -> inp.copyTo(out) } }
                                kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                                    result.success(null)
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error in copyUriToDirectory", e)
                                kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                                    result.error("COPY_ERROR", e.message ?: "Unknown error", null)
                                }
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing arguments", null)
                    }
                }
                "clearCache" -> {
                    kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO).launch {
                        clearAppCache()
                        kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Main) {
                            result.success(null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startDocumentScanner(result: MethodChannel.Result) {
        val options = GmsDocumentScannerOptions.Builder()
            .setGalleryImportAllowed(true)
            .setPageLimit(50)
            .setResultFormats(
                GmsDocumentScannerOptions.RESULT_FORMAT_JPEG,
                GmsDocumentScannerOptions.RESULT_FORMAT_PDF
            )
            .setScannerMode(GmsDocumentScannerOptions.SCANNER_MODE_FULL)
            .build()

        val scanner = GmsDocumentScanning.getClient(options)
        scanner.getStartScanIntent(this)
            .addOnSuccessListener { intentSender ->
                try {
                    startIntentSenderForResult(
                        intentSender,
                        SCAN_DOCUMENT,
                        null, 0, 0, 0
                    )
                } catch (e: IntentSender.SendIntentException) {
                    Log.e(TAG, "Error launching document scanner", e)
                    pendingResult?.error("SCANNER_ERROR", e.message ?: "SendIntentException", null)
                    pendingResult = null
                    pendingRequestCode = null
                }
            }
            .addOnFailureListener { e ->
                Log.e(TAG, "Scanner not available", e)
                pendingResult?.error("SCANNER_UNAVAILABLE", e.message ?: "Scanner unavailable", null)
                pendingResult = null
                pendingRequestCode = null
            }
    }

    private fun pickMultipleImagesFromGallery() {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "image/*"
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivityForResult(Intent.createChooser(intent, "Seleccionar imágenes"), PICK_IMAGES)
    }

    private fun pickMultiplePDFsFromStorage() {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "application/pdf"
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivityForResult(Intent.createChooser(intent, "Seleccionar PDFs"), PICK_PDFS)
    }

    private fun pickFolder() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        startActivityForResult(intent, PICK_FOLDER)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Unit {
        super.onActivityResult(requestCode, resultCode, data)

        val result = pendingResult
        val expectedCode = pendingRequestCode

        if (result == null || expectedCode == null || requestCode != expectedCode) {
            return
        }

        when (requestCode) {
            PICK_IMAGES, PICK_PDFS -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val uris = mutableListOf<String>()
                    val clipData = data.clipData

                    if (clipData != null) {
                        for (i in 0 until clipData.itemCount) {
                            val uri = clipData.getItemAt(i).uri
                            uris.add(uri.toString())
                        }
                    } else {
                        val uri = data.data
                        if (uri != null) uris.add(uri.toString())
                    }

                    result.success(uris)
                } else {
                    result.success(emptyList<String>())
                }
            }
            SCAN_DOCUMENT -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val scanResult = GmsDocumentScanningResult.fromActivityResultIntent(data)
                    val imageUris = scanResult?.pages?.map { it.imageUri.toString() } ?: emptyList()
                    val pdfUri = scanResult?.pdf?.uri?.toString()
                    val pageCount = scanResult?.pdf?.pageCount ?: 0
                    result.success(mapOf(
                        "imageUris" to imageUris,
                        "pdfUri" to pdfUri,
                        "pageCount" to pageCount
                    ))
                } else {
                    // Usuario canceló el escaneo
                    result.success(null)
                }
            }
            PICK_FOLDER -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val folderUri: Uri? = data.data

                    if (folderUri != null) {
                        contentResolver.takePersistableUriPermission(
                                folderUri,
                                Intent.FLAG_GRANT_READ_URI_PERMISSION
                        )

                        result.success(folderUri.toString())
                    } else {
                        result.success(null)
                    }
                } else {
                    result.success(null)
                }
            }
        }

        pendingResult = null
        pendingRequestCode = null
    }

    private fun installApk(filePath: String) {
        val apkFile = File(filePath)

        if (!apkFile.exists()) {
            return
        }

        val intent = Intent(Intent.ACTION_VIEW)

        val apkUri: Uri =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    FileProvider.getUriForFile(this, "$packageName.fileprovider", apkFile).also {
                        intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                    }
                } else {
                    Uri.fromFile(apkFile)
                }

        intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun getFileNamesBatch(call: MethodCall, result: MethodChannel.Result) {
        val uriList = call.argument<List<String>>("uris") ?: emptyList<String>()
        val fileNames = mutableListOf<String>()

        try {
            uriList.forEachIndexed { index, uriString ->
                try {
                    val pdfUri = Uri.parse(uriString)
                    val fileName = UriHelper.getPDFFileName(this, pdfUri)
                    fileNames.add(fileName)
                } catch (e: Exception) {
                    Log.w(TAG, "Error getting name for URI: $uriString", e)
                    fileNames.add("document_${index + 1}.pdf")
                }
            }
            Log.d(TAG, "Nombres de PDFs: ${fileNames.size}")
            result.success(fileNames)
        } catch (e: Exception) {
            Log.e(TAG, "PDF names error", e)
            result.error("NAMES_ERROR", e.message, null)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        clearAppCache()
    }

    private fun clearAppCache() {
        try {
            val cacheDir = context.cacheDir
            if (cacheDir != null && cacheDir.isDirectory) {
                deleteDir(cacheDir)
            }
            val externalCacheDir = context.externalCacheDir
            if (externalCacheDir != null && externalCacheDir.isDirectory) {
                deleteDir(externalCacheDir)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing cache", e)
        }
    }

    private fun deleteDir(dir: File?): Boolean {
        if (dir != null && dir.isDirectory) {
            val children = dir.list()
            if (children != null) {
                for (i in children.indices) {
                    val success = deleteDir(File(dir, children[i]))
                    if (!success) {
                        return false
                    }
                }
            }
        }
        return dir?.delete() ?: false
    }
}
