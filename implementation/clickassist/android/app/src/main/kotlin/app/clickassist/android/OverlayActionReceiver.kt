package app.clickassist.android

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class OverlayActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            FloatingOverlayService.ACTION_TOGGLE_CLICKING -> {
                if (ClickAssistBridge.isRunning()) {
                    ClickAssistBridge.stop(context)
                } else {
                    ClickAssistBridge.startWithLastConfig(context)
                }
            }

            FloatingOverlayService.ACTION_OPEN_APP -> {
                val launchIntent = context.packageManager
                    .getLaunchIntentForPackage(context.packageName)
                    ?.apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    }
                if (launchIntent != null) {
                    context.startActivity(launchIntent)
                }
            }

            FloatingOverlayService.ACTION_STOP_OVERLAY -> {
                ClickAssistBridge.stopOverlay(context)
            }
        }
    }
}

