package com.example.zylix

import android.content.Context
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.File

/** Utilidades para manejar URIs, conversiones y operaciones relacionadas con URIs. */
object UriHelper {
    private const val TAG = "UriHelper"

    /**
     * Obtiene los bytes de un URI dado.
     * @param context Contexto de la aplicación
     * @param uriString String representando el URI
     * @return ByteArray con el contenido del archivo o null si hay error
     */
    fun getBytesFromUri(context: Context, uriString: String?): ByteArray? {
        return try {
            uriString?.let {
                val uri = Uri.parse(it)
                context.contentResolver.openInputStream(uri)?.use { input -> input.readBytes() }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    /**
     * Obtiene el nombre de archivo desde una ruta (puede ser content:// o file://).
     * @param context Contexto de la aplicación
     * @param path Ruta del archivo
     * @return Nombre del archivo
     */
    fun getFileNameFromPath(context: Context, path: String): String {
        return if (path.startsWith("content://")) {
            val uri = Uri.parse(path)
            var fileName = "image_${System.currentTimeMillis()}"

            try {
                context.contentResolver.query(
                                uri,
                                arrayOf(android.provider.OpenableColumns.DISPLAY_NAME),
                                null,
                                null,
                                null
                        )
                        ?.use { cursor ->
                            if (cursor.moveToFirst()) {
                                val nameIndex =
                                        cursor.getColumnIndex(
                                                android.provider.OpenableColumns.DISPLAY_NAME
                                        )

                                if (nameIndex >= 0) {
                                    fileName = cursor.getString(nameIndex)
                                }
                            }
                        }
            } catch (e: Exception) {
                Log.w(TAG, "Could not get filename from URI, using default")
            }

            fileName
        } else {
            File(path).name
        }
    }

    /**
     * Obtiene el nombre de un archivo PDF desde un URI.
     * @param context Contexto de la aplicación
     * @param uri URI del archivo PDF
     * @return Nombre del archivo con extensión .pdf
     */
    fun getPDFFileName(context: Context, uri: Uri): String {
        context.contentResolver.query(
                        uri,
                        arrayOf(android.provider.OpenableColumns.DISPLAY_NAME),
                        null,
                        null,
                        null
                )
                ?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val nameIndex =
                                cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                        if (nameIndex >= 0) {
                            val displayName = cursor.getString(nameIndex)
                            if (!displayName.isNullOrEmpty()) {
                                return if (displayName.endsWith(".pdf", ignoreCase = true)) {
                                    displayName
                                } else {
                                    "$displayName.pdf"
                                }
                            }
                        }
                    }
                }

        val segments = uri.pathSegments
        val lastSegment = segments.lastOrNull()

        if (!lastSegment.isNullOrEmpty()) {
            val baseName = lastSegment.substringBeforeLast('.')
            return if (baseName.isNotEmpty()) {
                "$baseName.pdf"
            } else {
                "document_$lastSegment.pdf"
            }
        }

        return "document_${System.currentTimeMillis()}.pdf"
    }

    /**
     * Obtiene el nombre de archivo desde un URI genérico.
     * @param context Contexto de la aplicación
     * @param uri URI del archivo
     * @return Nombre del archivo
     */
    fun getFileNameFromUri(context: Context, uri: Uri): String {
        var fileName = "unknown_pdf"

        try {
            context.contentResolver.query(
                            uri,
                            arrayOf(android.provider.OpenableColumns.DISPLAY_NAME),
                            null,
                            null,
                            null
                    )
                    ?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            val nameIndex =
                                    cursor.getColumnIndex(
                                            android.provider.OpenableColumns.DISPLAY_NAME
                                    )

                            if (nameIndex >= 0) {
                                fileName = cursor.getString(nameIndex)
                            }
                        }
                    }
        } catch (e: Exception) {
            Log.w(TAG, "Could not get filename from URI, using default")
        }

        return fileName
    }

    /**
     * Obtiene un ParcelFileDescriptor desde una ruta (content:// o file://).
     * @param context Contexto de la aplicación
     * @param path Ruta del archivo
     * @return ParcelFileDescriptor o null si hay error
     */
    fun getFileDescriptorFromPath(context: Context, path: String): ParcelFileDescriptor? {
        return try {
            if (path.startsWith("content://")) {
                val uri = Uri.parse(path)
                context.contentResolver.openFileDescriptor(uri, "r")
            } else {
                val file = File(path)
                ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error opening file descriptor for: $path", e)
            null
        }
    }
}
