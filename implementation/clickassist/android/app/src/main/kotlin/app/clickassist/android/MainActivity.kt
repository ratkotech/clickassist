package app.clickassist.android

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onResume() {
        super.onResume()
        ClickAssistBridge.setAppInForeground(this, true)
    }

    override fun onPause() {
        ClickAssistBridge.setAppInForeground(this, false)
        super.onPause()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "clickassist/autoclicker",
        ).setMethodCallHandler(::handleMethodCall)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "clickassist/autoclicker_status",
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    ClickAssistBridge.setEventSink(this@MainActivity, events)
                }

                override fun onCancel(arguments: Any?) {
                    ClickAssistBridge.setEventSink(this@MainActivity, null)
                }
            },
        )
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> result.success(ClickAssistBridge.statusMap(this))
            "openAccessibilitySettings" -> {
                ClickAssistBridge.openAccessibilitySettings(this)
                result.success(true)
            }
            "openOverlaySettings" -> {
                FloatingOverlayService.openOverlaySettings(this)
                result.success(true)
            }
            "openBatteryOptimizationSettings" -> {
                ClickAssistBridge.openBatteryOptimizationSettings(this)
                result.success(true)
            }
            "openNotificationSettings" -> {
                ClickAssistBridge.openNotificationSettings(this)
                result.success(true)
            }
            "openExternalUrl" -> {
                val args = call.arguments as? Map<*, *>
                val url = args?.get("url") as? String
                if (url.isNullOrBlank()) {
                    result.error("invalid_args", "Missing URL.", null)
                    return
                }

                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                result.success(true)
            }
            "startOverlay" -> result.success(ClickAssistBridge.startOverlay(this))
            "stopOverlay" -> result.success(ClickAssistBridge.stopOverlay(this))
            "startPointPicker" -> result.success(ClickAssistBridge.startPointPicker(this))
            "stopPointPicker" -> result.success(ClickAssistBridge.stopPointPicker(this))
            "updateConfig" -> {
                val args = call.arguments as? Map<*, *>
                if (args == null) {
                    result.error("invalid_args", "Missing clicker config.", null)
                    return
                }
                ClickAssistBridge.updateConfig(parseConfig(args))
                result.success(true)
            }
            "startClicking" -> {
                val args = call.arguments as? Map<*, *>
                if (args == null) {
                    result.error("invalid_args", "Missing clicker config.", null)
                    return
                }

                result.success(ClickAssistBridge.start(this, parseConfig(args)))
            }
            "stopClicking" -> result.success(ClickAssistBridge.stop(this))
            else -> result.notImplemented()
        }
    }

    private fun parseConfig(arguments: Map<*, *>): AutoClickConfig {
        val rawPoints = arguments["clickPoints"] as? List<*> ?: emptyList<Any>()
        val clickPoints = rawPoints.mapNotNull { point ->
            val value = point as? Map<*, *> ?: return@mapNotNull null
            val id = value["id"] as? String ?: return@mapNotNull null
            val x = (value["x"] as? Number)?.toFloat() ?: return@mapNotNull null
            val y = (value["y"] as? Number)?.toFloat() ?: return@mapNotNull null
            NativeClickPoint(
                id = id,
                x = x,
                y = y,
                xPercent = (value["xPercent"] as? Number)?.toFloat(),
                yPercent = (value["yPercent"] as? Number)?.toFloat(),
            )
        }
        val rawSteps = arguments["clickSteps"] as? List<*> ?: emptyList<Any>()
        val clickSteps = rawSteps.mapNotNull { step ->
            val value = step as? Map<*, *> ?: return@mapNotNull null
            val id = value["id"] as? String ?: return@mapNotNull null
            val pointId = value["pointId"] as? String ?: return@mapNotNull null
            NativeClickStep(
                id = id,
                pointId = pointId,
                actionType = value["actionType"] as? String ?: "tap",
                endPointId = value["endPointId"] as? String,
                delayMs = (value["delayMs"] as? Number)?.toInt() ?: 500,
                pressDurationMs = (value["pressDurationMs"] as? Number)?.toLong() ?: 24L,
            )
        }

        return AutoClickConfig(
            intervalMs = (arguments["intervalMs"] as? Number)?.toInt() ?: 500,
            startDelayMs = (arguments["startDelayMs"] as? Number)?.toInt() ?: 0,
            pattern = arguments["pattern"] as? String ?: "single",
            multiClick = arguments["multiClick"] as? Boolean ?: false,
            pointTimingMode = arguments["pointTimingMode"] as? String ?: "sequential",
            infiniteMode = arguments["infiniteMode"] as? Boolean ?: true,
            targetCycles = (arguments["targetCycles"] as? Number)?.toInt() ?: 50,
            showGestureIndicator = arguments["showGestureIndicator"] as? Boolean ?: true,
            clickPoints = clickPoints,
            clickSteps = clickSteps,
        )
    }
}

