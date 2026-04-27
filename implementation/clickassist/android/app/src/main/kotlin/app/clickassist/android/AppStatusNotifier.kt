package app.clickassist.android

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object AppStatusNotifier {
    private const val CHANNEL_ID = "clickassist_status"
    private const val NOTIFICATION_ID = 5501

    fun showClickerStarted(context: Context, startDelayMs: Int) {
        ensureChannel(context)
        val contentText = if (startDelayMs > 0) {
            "Auto-click will begin in ${startDelayMs / 1000}s."
        } else {
            "Auto-click is now running in the background."
        }

        NotificationManagerCompat.from(context).notify(
            NOTIFICATION_ID,
            NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_clickassist)
                .setContentTitle("ClickAssist started")
                .setContentText(contentText)
                .setStyle(NotificationCompat.BigTextStyle().bigText(contentText))
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(openAppPendingIntent(context))
                .build(),
        )
    }

    fun showClickerStopped(context: Context, message: String) {
        ensureChannel(context)
        NotificationManagerCompat.from(context).notify(
            NOTIFICATION_ID,
            NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_clickassist)
                .setContentTitle("ClickAssist stopped")
                .setContentText(message)
                .setStyle(NotificationCompat.BigTextStyle().bigText(message))
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(openAppPendingIntent(context))
                .build(),
        )
    }

    private fun openAppPendingIntent(context: Context): PendingIntent {
        val openIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)

        openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)

        return PendingIntent.getActivity(
            context,
            41,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val manager = context.getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "ClickAssist Status",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Start and stop updates for the ClickAssist auto-clicker."
        }
        manager.createNotificationChannel(channel)
    }
}

