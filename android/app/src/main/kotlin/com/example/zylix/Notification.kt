package com.example.zylix

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

object NotificationHelper {
    private const val TAG = "NotificationHelper"

    fun showNotification(
            context: Context,
            title: String,
            body: String,
            channelId: String = "default_channel_id"
    ): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                val hasPermission =
                        ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.POST_NOTIFICATIONS
                        ) == PackageManager.PERMISSION_GRANTED

                if (!hasPermission) {
                    Log.w(TAG, "No tiene permiso POST_NOTIFICATIONS")
                    return false
                }
            }

            val notificationId = System.currentTimeMillis().toInt()

            val manager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            if (manager == null) {
                Log.e(TAG, "No se pudo obtener NotificationManager")
                return false
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel =
                        NotificationChannel(
                                        channelId,
                                        "Canal de Notificaciones",
                                        NotificationManager.IMPORTANCE_HIGH
                                )
                                .apply { description = "Canal para notificaciones nativas" }
                manager.createNotificationChannel(channel)
            }

            val notification =
                    NotificationCompat.Builder(context, channelId)
                            .setSmallIcon(android.R.drawable.ic_dialog_info)
                            .setContentTitle(title)
                            .setContentText(body)
                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                            .setAutoCancel(true)
                            .build()

            NotificationManagerCompat.from(context).notify(notificationId, notification)
            Log.d(TAG, "Notificación mostrada: $title")
            true
        } catch (e: SecurityException) {
            Log.e(TAG, "Error de seguridad al mostrar notificación", e)
            false
        } catch (e: Exception) {
            Log.e(TAG, "Error inesperado al mostrar notificación", e)
            false
        }
    }
}
