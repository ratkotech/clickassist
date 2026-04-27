package app.clickassist.android

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.EventChannel

data class NativeClickPoint(
    val id: String,
    val x: Float,
    val y: Float,
    val xPercent: Float? = null,
    val yPercent: Float? = null,
)

data class NativeClickStep(
    val id: String,
    val pointId: String,
    val actionType: String,
    val endPointId: String? = null,
    val delayMs: Int,
    val pressDurationMs: Long,
)

data class AutoClickConfig(
    val intervalMs: Int,
    val startDelayMs: Int,
    val pattern: String,
    val multiClick: Boolean,
    val pointTimingMode: String,
    val infiniteMode: Boolean,
    val targetCycles: Int,
    val showGestureIndicator: Boolean,
    val clickPoints: List<NativeClickPoint>,
    val clickSteps: List<NativeClickStep>,
)

data class ClickAssistStatus(
    val accessibilityEnabled: Boolean,
    val overlayPermissionEnabled: Boolean,
    val overlayEnabled: Boolean,
    val overlayVisible: Boolean,
    val pointPickerActive: Boolean,
    val accessibilityServiceConnected: Boolean,
    val batteryOptimizationIgnored: Boolean,
    val batteryLevelPercent: Int,
    val batteryCharging: Boolean,
    val thermalStatus: Int,
    val notificationsEnabled: Boolean,
    val isRunning: Boolean,
    val totalClicks: Int,
    val captureSequence: Int,
    val capturedPointX: Float? = null,
    val capturedPointY: Float? = null,
    val capturedScreenWidth: Int? = null,
    val capturedScreenHeight: Int? = null,
    val message: String? = null,
)

object ClickAssistBridge {
    private const val PREFS_NAME = "clickassist_prefs"
    private const val KEY_OVERLAY_ENABLED = "overlay_enabled"
    private var service: AutoClickAccessibilityService? = null
    private var eventSink: EventChannel.EventSink? = null
    private var lastConfig: AutoClickConfig? = null
    private var overlayEnabled = false
    private var overlayVisible = false
    private var appInForeground = false
    private var pointPickerActive = false
    private var lastStatus = ClickAssistStatus(
        accessibilityEnabled = false,
        overlayPermissionEnabled = false,
        overlayEnabled = false,
        overlayVisible = false,
        pointPickerActive = false,
        accessibilityServiceConnected = false,
        batteryOptimizationIgnored = false,
        batteryLevelPercent = -1,
        batteryCharging = false,
        thermalStatus = 0,
        notificationsEnabled = true,
        isRunning = false,
        totalClicks = 0,
        captureSequence = 0,
    )

    fun attachService(context: Context, autoClickService: AutoClickAccessibilityService) {
        service = autoClickService
        overlayEnabled = readOverlayEnabled(context)
        updateStatus(
            context = context,
            isRunning = autoClickService.isRunning(),
            totalClicks = autoClickService.totalClicks(),
        )
    }

    fun detachService(context: Context, autoClickService: AutoClickAccessibilityService) {
        if (service == autoClickService) {
            service = null
        }

        updateStatus(
            context = context,
            isRunning = false,
            totalClicks = lastStatus.totalClicks,
        )
    }

    fun setEventSink(context: Context, sink: EventChannel.EventSink?) {
        eventSink = sink
        eventSink?.success(statusMap(context))
    }

    fun statusMap(context: Context): Map<String, Any?> {
        val accessibilityEnabled = isAccessibilityEnabled(context)
        val overlayPermissionEnabled = Settings.canDrawOverlays(context)
        val batteryOptimizationIgnored = isIgnoringBatteryOptimizations(context)
        val batteryLevelPercent = batteryLevelPercent(context)
        val batteryCharging = isBatteryCharging(context)
        val thermalStatus = thermalStatus(context)
        val notificationsEnabled = NotificationManagerCompat.from(context).areNotificationsEnabled()
        if ((!overlayPermissionEnabled || !accessibilityEnabled) && overlayVisible) {
            context.stopService(Intent(context, FloatingOverlayService::class.java))
            overlayVisible = false
        }
        lastStatus = lastStatus.copy(
            accessibilityEnabled = accessibilityEnabled,
            overlayPermissionEnabled = overlayPermissionEnabled,
            overlayEnabled = overlayEnabled,
            overlayVisible = overlayVisible,
            pointPickerActive = pointPickerActive,
            accessibilityServiceConnected = service != null,
            batteryOptimizationIgnored = batteryOptimizationIgnored,
            batteryLevelPercent = batteryLevelPercent,
            batteryCharging = batteryCharging,
            thermalStatus = thermalStatus,
            notificationsEnabled = notificationsEnabled,
        )
        return mapOf(
            "accessibilityEnabled" to accessibilityEnabled,
            "overlayPermissionEnabled" to overlayPermissionEnabled,
            "overlayEnabled" to overlayEnabled,
            "overlayVisible" to overlayVisible,
            "pointPickerActive" to pointPickerActive,
            "accessibilityServiceConnected" to (service != null),
            "batteryOptimizationIgnored" to batteryOptimizationIgnored,
            "batteryLevelPercent" to batteryLevelPercent,
            "batteryCharging" to batteryCharging,
            "thermalStatus" to thermalStatus,
            "notificationsEnabled" to notificationsEnabled,
            "isRunning" to lastStatus.isRunning,
            "totalClicks" to lastStatus.totalClicks,
            "captureSequence" to lastStatus.captureSequence,
            "capturedPointX" to lastStatus.capturedPointX,
            "capturedPointY" to lastStatus.capturedPointY,
            "capturedScreenWidth" to lastStatus.capturedScreenWidth,
            "capturedScreenHeight" to lastStatus.capturedScreenHeight,
            "message" to lastStatus.message,
        )
    }

    fun updateStatus(
        context: Context,
        isRunning: Boolean = lastStatus.isRunning,
        totalClicks: Int = lastStatus.totalClicks,
        message: String? = lastStatus.message,
    ) {
        syncOverlayVisibility(context)

        lastStatus = ClickAssistStatus(
            accessibilityEnabled = isAccessibilityEnabled(context),
            overlayPermissionEnabled = Settings.canDrawOverlays(context),
            overlayEnabled = overlayEnabled,
            overlayVisible = overlayVisible,
            pointPickerActive = pointPickerActive,
            accessibilityServiceConnected = service != null,
            batteryOptimizationIgnored = isIgnoringBatteryOptimizations(context),
            batteryLevelPercent = batteryLevelPercent(context),
            batteryCharging = isBatteryCharging(context),
            thermalStatus = thermalStatus(context),
            notificationsEnabled = NotificationManagerCompat.from(context).areNotificationsEnabled(),
            isRunning = isRunning,
            totalClicks = totalClicks,
            captureSequence = lastStatus.captureSequence,
            capturedPointX = lastStatus.capturedPointX,
            capturedPointY = lastStatus.capturedPointY,
            capturedScreenWidth = lastStatus.capturedScreenWidth,
            capturedScreenHeight = lastStatus.capturedScreenHeight,
            message = message,
        )
        context.sendBroadcast(
            Intent(FloatingOverlayService.ACTION_REFRESH_OVERLAY).setPackage(context.packageName),
        )
        eventSink?.success(statusMap(context))
    }

    fun start(context: Context, config: AutoClickConfig): Map<String, Any?> {
        lastConfig = config
        val currentService = service
        if (!isAccessibilityEnabled(context) || currentService == null) {
            updateStatus(
                context = context,
                isRunning = false,
                message = "Enable ClickAssist in Android Accessibility settings first.",
            )
            return statusMap(context)
        }

        currentService.startClicking(config)
        return statusMap(context)
    }

    fun updateConfig(config: AutoClickConfig) {
        lastConfig = config
    }

    fun startWithLastConfig(context: Context): Map<String, Any?> {
        val config = lastConfig
        if (config == null) {
            updateStatus(
                context = context,
                isRunning = false,
                message = "Open ClickAssist and configure the clicker first.",
            )
            return statusMap(context)
        }

        return start(context, config)
    }

    fun stop(context: Context): Map<String, Any?> {
        service?.stopClicking()
        updateStatus(context = context, isRunning = false, message = "Clicker stopped.")
        return statusMap(context)
    }

    fun openAccessibilitySettings(context: Context) {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun openBatteryOptimizationSettings(context: Context) {
        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun openNotificationSettings(context: Context) {
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
            putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun startOverlay(context: Context): Map<String, Any?> {
        if (!isAccessibilityEnabled(context)) {
            updateStatus(
                context = context,
                message = "Enable ClickAssist in Accessibility to use overlay controls.",
            )
            return statusMap(context)
        }

        if (!Settings.canDrawOverlays(context)) {
            updateStatus(
                context = context,
                message = "Allow display over other apps to use the floating controls.",
            )
            return statusMap(context)
        }

        overlayEnabled = true
        persistOverlayEnabled(context, true)
        syncOverlayVisibility(context)
        updateStatus(
            context,
            message = "Overlay is ready. Use it to start automation from any screen.",
        )
        return statusMap(context)
    }

    fun stopOverlay(context: Context): Map<String, Any?> {
        overlayEnabled = false
        persistOverlayEnabled(context, false)
        context.stopService(Intent(context, FloatingOverlayService::class.java))
        overlayVisible = false
        updateStatus(context, message = "Floating overlay disabled.")
        return statusMap(context)
    }

    fun setOverlayVisible(context: Context, visible: Boolean) {
        overlayVisible = visible
        updateStatus(context, message = lastStatus.message)
    }

    fun setAppInForeground(context: Context, inForeground: Boolean) {
        appInForeground = inForeground
        updateStatus(context, message = lastStatus.message)
    }

    fun startPointPicker(context: Context): Map<String, Any?> {
        if (!Settings.canDrawOverlays(context)) {
            updateStatus(
                context = context,
                message = "Allow display over other apps before picking click points.",
            )
            return statusMap(context)
        }

        val intent = Intent(context, PointPickerOverlayService::class.java)
        context.startService(intent)
        pointPickerActive = true
        updateStatus(context, message = "Tap anywhere on screen to capture a click point.")
        return statusMap(context)
    }

    fun stopPointPicker(context: Context): Map<String, Any?> {
        context.stopService(Intent(context, PointPickerOverlayService::class.java))
        pointPickerActive = false
        updateStatus(context, message = "Point picker cancelled.")
        return statusMap(context)
    }

    fun setPointPickerActive(context: Context, active: Boolean) {
        pointPickerActive = active
        updateStatus(context, message = lastStatus.message)
    }

    fun recordCapturedPoint(context: Context, x: Float, y: Float, screenWidth: Int, screenHeight: Int) {
        lastStatus = lastStatus.copy(
            accessibilityEnabled = isAccessibilityEnabled(context),
            overlayPermissionEnabled = Settings.canDrawOverlays(context),
            overlayVisible = overlayVisible,
            pointPickerActive = false,
            batteryLevelPercent = batteryLevelPercent(context),
            batteryCharging = isBatteryCharging(context),
            thermalStatus = thermalStatus(context),
            isRunning = lastStatus.isRunning,
            totalClicks = lastStatus.totalClicks,
            captureSequence = lastStatus.captureSequence + 1,
            capturedPointX = x,
            capturedPointY = y,
            capturedScreenWidth = screenWidth,
            capturedScreenHeight = screenHeight,
            message = "Point captured at ${x.toInt()}, ${y.toInt()}.",
        )
        pointPickerActive = false
        eventSink?.success(statusMap(context))
    }

    fun isRunning(): Boolean = lastStatus.isRunning

    fun shouldRestoreOverlay(context: Context): Boolean {
        return readOverlayEnabled(context) &&
            isAccessibilityEnabled(context) &&
            Settings.canDrawOverlays(context)
    }

    private fun isAccessibilityEnabled(context: Context): Boolean {
        val componentName = ComponentName(context, AutoClickAccessibilityService::class.java)
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false

        return enabledServices.split(':').any { enabledService ->
            ComponentName.unflattenFromString(enabledService) == componentName
        }
    }

    private fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(context.packageName)
    }

    private fun batteryLevelPercent(context: Context): Int {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun isBatteryCharging(context: Context): Boolean {
        val batteryStatus =
            context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                ?: return false
        val status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
        return status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL
    }

    private fun thermalStatus(context: Context): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return PowerManager.THERMAL_STATUS_NONE
        }

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.currentThermalStatus
    }

    private fun persistOverlayEnabled(context: Context, enabled: Boolean) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_OVERLAY_ENABLED, enabled)
            .apply()
    }

    private fun readOverlayEnabled(context: Context): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_OVERLAY_ENABLED, false)
    }

    private fun syncOverlayVisibility(context: Context) {
        val canDrawOverlays = Settings.canDrawOverlays(context)
        val shouldBeVisible =
            overlayEnabled &&
                isAccessibilityEnabled(context) &&
                canDrawOverlays &&
                !appInForeground
        if (shouldBeVisible && !overlayVisible) {
            context.startForegroundService(Intent(context, FloatingOverlayService::class.java))
            overlayVisible = true
            return
        }

        if (!shouldBeVisible && overlayVisible) {
            context.stopService(Intent(context, FloatingOverlayService::class.java))
            overlayVisible = false
        }
    }
}

