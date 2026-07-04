package app.clickassist.android

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.view.animation.OvershootInterpolator
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat

class FloatingOverlayService : Service() {
    private val actionReceiver: BroadcastReceiver =
        object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    ACTION_TOGGLE_CLICKING -> {
                        if (ClickAssistBridge.isRunning()) {
                            ClickAssistBridge.stop(context)
                        } else {
                            ClickAssistBridge.startWithLastConfig(context)
                        }
                        updateOverlayAppearance()
                    }

                    ACTION_OPEN_APP -> {
                        openApp()
                    }

                    ACTION_STOP_OVERLAY -> {
                        ClickAssistBridge.stopOverlay(context)
                    }

                    ACTION_REFRESH_OVERLAY -> {
                        updateOverlayAppearance()
                    }
                }
            }
        }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var dismissView: View? = null
    private var overlayParams: WindowManager.LayoutParams? = null
    private var dismissParams: WindowManager.LayoutParams? = null
    private var pulseAnimator: ValueAnimator? = null

    private var compactButton: View? = null
    private var compactIcon: ImageView? = null
    private var expandedBar: LinearLayout? = null
    private var toggleIcon: ImageView? = null
    private var stopButton: ImageView? = null
    private var settingsButton: ImageView? = null
    private var statusLabel: TextView? = null
    private var modeLabel: TextView? = null
    private var speedLabel: TextView? = null
    private var pickerLabel: TextView? = null
    private var toggleButtonContainer: View? = null
    private var stopButtonContainer: View? = null
    private var settingsButtonContainer: View? = null

    private var isExpanded = false
    private var currentOverlayBounds: OverlayProtection.Bounds? = null
    private var lastUserSelectedOverlayPosition: OverlayProtection.Position? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        activeService = this
        Log.d(TAG, "service created; canDrawOverlays=${Settings.canDrawOverlays(this)}")
        if (!Settings.canDrawOverlays(this)) {
            Log.d(TAG, "stopping overlay service because draw-over-apps permission is missing")
            stopSelf()
            return
        }

        startForeground(NOTIFICATION_ID, createNotification())
        val filter = IntentFilter().apply {
            addAction(ACTION_TOGGLE_CLICKING)
            addAction(ACTION_OPEN_APP)
            addAction(ACTION_STOP_OVERLAY)
            addAction(ACTION_REFRESH_OVERLAY)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(actionReceiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(actionReceiver, filter)
        }

        showOverlay()
        ClickAssistBridge.setOverlayVisible(this, true)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "start command received; overlayView=${overlayView != null}; visible=${overlayView?.visibility}")
        updateOverlayAppearance()
        return START_STICKY
    }

    override fun onDestroy() {
        runCatching { unregisterReceiver(actionReceiver) }
        stopPulseAnimation()
        removeDismissLayer()
        removeOverlay()
        ClickAssistBridge.setOverlayVisible(this, false)
        if (activeService === this) {
            activeService = null
        }
        super.onDestroy()
    }

    private fun showOverlay() {
        Log.d(TAG, "creating control overlay")
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val view = inflater.inflate(R.layout.overlay_controls, null)
        val params =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = dp(24)
                y = dp(220)
            }

        overlayParams = params
        bindOverlayViews(view)
        bindOverlayActions()
        runCatching {
            windowManager?.addView(view, params)
            Log.d(
                TAG,
                "control overlay addView success; type=${params.type}; flags=${params.flags}; x=${params.x}; y=${params.y}; width=${params.width}; height=${params.height}",
            )
        }.onFailure { error ->
            Log.e(TAG, "control overlay addView failed", error)
            stopSelf()
            return
        }
        overlayView = view
        setExpanded(false, animate = false)
        updateOverlayAppearance()
        view.post {
            Log.d(
                TAG,
                "control overlay laid out; visibility=${view.visibility}; alpha=${view.alpha}; width=${view.width}; height=${view.height}; x=${params.x}; y=${params.y}",
            )
            updateCurrentOverlayBounds()
        }
    }

    private fun bindOverlayViews(view: View) {
        compactButton = view.findViewById(R.id.overlayCompactButton)
        compactIcon = view.findViewById(R.id.overlayCompactIcon)
        expandedBar = view.findViewById(R.id.overlayExpandedBar)
        toggleIcon = view.findViewById(R.id.overlayToggleIcon)
        stopButton = view.findViewById(R.id.overlayStopButton)
        settingsButton = view.findViewById(R.id.overlaySettingsButton)
        statusLabel = view.findViewById(R.id.overlayStatusLabel)
        modeLabel = view.findViewById(R.id.overlayModeLabel)
        speedLabel = view.findViewById(R.id.overlaySpeedLabel)
        pickerLabel = view.findViewById(R.id.overlayPickerLabel)
        toggleButtonContainer = view.findViewById(R.id.overlayToggleButtonContainer)
        stopButtonContainer = view.findViewById(R.id.overlayStopButtonContainer)
        settingsButtonContainer = view.findViewById(R.id.overlaySettingsButtonContainer)
        Log.d(
            TAG,
            "control overlay views bound; compact=${compactButton != null}; expanded=${expandedBar != null}; toggle=${toggleButtonContainer != null}; stop=${stopButtonContainer != null}; settings=${settingsButtonContainer != null}",
        )
    }

    private fun bindOverlayActions() {
        compactButton?.setOnClickListener {
            if (ClickAssistBridge.isRunning()) {
                ClickAssistBridge.stop(this)
                updateOverlayAppearance()
                setExpanded(false, animate = true)
                return@setOnClickListener
            }
            if (!isExpanded) {
                setExpanded(true, animate = true)
            }
        }

        toggleButtonContainer?.setOnClickListener {
            if (ClickAssistBridge.isRunning()) {
                ClickAssistBridge.stop(this)
            } else {
                ClickAssistBridge.startWithLastConfig(this)
            }
            updateOverlayAppearance()
        }

        stopButtonContainer?.setOnClickListener {
            ClickAssistBridge.stop(this)
            updateOverlayAppearance()
            setExpanded(false, animate = true)
        }

        settingsButtonContainer?.setOnClickListener {
            openApp()
            setExpanded(false, animate = true)
        }

        attachDragTarget(compactButton)
        attachDragTarget(expandedBar)
    }

    private fun attachDragTarget(target: View?) {
        val params = overlayParams ?: return
        target?.setOnTouchListener(
            object : View.OnTouchListener {
                private val touchSlop = ViewConfiguration.get(this@FloatingOverlayService).scaledTouchSlop
                private var initialX = 0
                private var initialY = 0
                private var initialTouchX = 0f
                private var initialTouchY = 0f
                private var dragging = false

                override fun onTouch(v: View, event: MotionEvent): Boolean {
                    when (event.actionMasked) {
                        MotionEvent.ACTION_DOWN -> {
                            initialX = params.x
                            initialY = params.y
                            initialTouchX = event.rawX
                            initialTouchY = event.rawY
                            dragging = false
                            return false
                        }

                        MotionEvent.ACTION_MOVE -> {
                            val deltaX = (event.rawX - initialTouchX).toInt()
                            val deltaY = (event.rawY - initialTouchY).toInt()
                            if (!dragging &&
                                (kotlin.math.abs(deltaX) > touchSlop ||
                                    kotlin.math.abs(deltaY) > touchSlop)
                            ) {
                                dragging = true
                            }
                            if (!dragging) {
                                return false
                            }

                            params.x = (initialX + deltaX).coerceIn(0, maxOverlayX())
                            params.y = (initialY + deltaY).coerceIn(dp(32), maxOverlayY())
                            windowManager?.updateViewLayout(overlayView, params)
                            updateCurrentOverlayBounds()
                            return true
                        }

                        MotionEvent.ACTION_UP,
                        MotionEvent.ACTION_CANCEL,
                        -> {
                            if (dragging) {
                                snapToNearestEdge(userInitiated = true)
                                return true
                            }
                        }
                    }
                    return false
                }
            },
        )
    }

    private fun setExpanded(expanded: Boolean, animate: Boolean) {
        val compact = compactButton ?: return
        val bar = expandedBar ?: return
        isExpanded = expanded
        Log.d(TAG, "setExpanded expanded=$expanded animate=$animate")

        if (expanded) {
            showDismissLayer()
            bar.visibility = View.VISIBLE
            bar.post { updateCurrentOverlayBounds() }
            if (animate) {
                bar.alpha = 0f
                bar.scaleX = 0.92f
                bar.scaleY = 0.92f
                bar.animate()
                    .alpha(1f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(220)
                    .setInterpolator(OvershootInterpolator(0.75f))
                    .start()
            }
            compact.animate()
                .alpha(0f)
                .scaleX(0.88f)
                .scaleY(0.88f)
                .setDuration(if (animate) 180 else 0)
                .withEndAction { compact.visibility = View.GONE }
                .start()
        } else {
            removeDismissLayer()
            compact.visibility = View.VISIBLE
            compact.post { updateCurrentOverlayBounds() }
            compact.animate()
                .alpha(1f)
                .scaleX(1f)
                .scaleY(1f)
                .setDuration(if (animate) 180 else 0)
                .start()
            bar.animate()
                .alpha(0f)
                .scaleX(0.92f)
                .scaleY(0.92f)
                .setDuration(if (animate) 160 else 0)
                .withEndAction {
                    bar.visibility = View.GONE
                    bar.alpha = 1f
                    bar.scaleX = 1f
                    bar.scaleY = 1f
                }
                .start()
        }
    }

    private fun showDismissLayer() {
        if (dismissView != null) {
            return
        }

        val view =
            View(this).apply {
                setBackgroundColor(0x01000000)
                setOnClickListener {
                    setExpanded(false, animate = true)
                }
            }
        val params =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
            }

        dismissParams = params
        dismissView = view
        windowManager?.addView(view, params)
        val existingOverlay = overlayView
        val existingParams = overlayParams
        if (existingOverlay != null && existingParams != null) {
            runCatching { windowManager?.removeView(existingOverlay) }
            windowManager?.addView(existingOverlay, existingParams)
        }
    }

    private fun removeDismissLayer() {
        dismissView?.let { view ->
            Log.d(TAG, "removeView dismiss layer")
            runCatching { windowManager?.removeView(view) }
        }
        dismissView = null
        dismissParams = null
    }

    private fun updateOverlayAppearance() {
        val running = ClickAssistBridge.isRunning()
        val pointPickerActive = ClickAssistBridge.isPointPickerActive()
        val summary = ClickAssistBridge.overlaySummary()
        val statusText = when {
            pointPickerActive -> "Picking target"
            running -> "Running"
            else -> "Ready"
        }
        val statusColor = when {
            pointPickerActive -> COLOR_WARNING
            running -> COLOR_SUCCESS
            else -> COLOR_PRIMARY
        }

        compactButton?.contentDescription = "ClickAssist overlay: $statusText. Tap for controls."
        statusLabel?.apply {
            text = statusText
            setTextColor(statusColor)
        }
        modeLabel?.text = summary.modeLabel
        speedLabel?.text = summary.speedLabel
        pickerLabel?.apply {
            text = summary.pickerLabel
            setTextColor(if (pointPickerActive) COLOR_WARNING else COLOR_MUTED)
        }

        compactIcon?.setImageResource(R.drawable.clickassist_overlay_logo)
        toggleIcon?.setImageResource(if (running) R.drawable.ic_overlay_pause else R.drawable.ic_overlay_play)
        stopButton?.setImageResource(android.R.drawable.ic_menu_close_clear_cancel)
        val playDescription = if (running) "Pause automation" else "Start automation"
        toggleIcon?.contentDescription = playDescription
        toggleButtonContainer?.contentDescription = playDescription
        stopButton?.contentDescription = "Stop automation"
        stopButtonContainer?.contentDescription = "Stop automation"
        settingsButton?.contentDescription = "Open ClickAssist"
        settingsButtonContainer?.contentDescription = "Open ClickAssist"

        if (running) {
            startPulseAnimation()
        } else {
            stopPulseAnimation()
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(NOTIFICATION_ID, createNotification())
    }

    private fun startPulseAnimation() {
        val compact = compactButton ?: return
        val play = toggleButtonContainer ?: return
        if (pulseAnimator?.isRunning == true) {
            return
        }

        pulseAnimator =
            ValueAnimator.ofFloat(1f, 1.08f, 1f).apply {
                duration = 1250
                repeatCount = ValueAnimator.INFINITE
                addUpdateListener { animator ->
                    val value = animator.animatedValue as Float
                    compact.scaleX = value
                    compact.scaleY = value
                    play.scaleX = value
                    play.scaleY = value
                    val alpha = 0.88f + ((value - 1f) * 1.2f)
                    compact.alpha = alpha.coerceIn(0.88f, 1f)
                    play.alpha = alpha.coerceIn(0.88f, 1f)
                }
                start()
            }
    }

    private fun stopPulseAnimation() {
        pulseAnimator?.cancel()
        pulseAnimator = null
        compactButton?.apply {
            alpha = 1f
            scaleX = 1f
            scaleY = 1f
        }
        toggleButtonContainer?.apply {
            alpha = 1f
            scaleX = 1f
            scaleY = 1f
        }
    }

    private fun snapToNearestEdge(userInitiated: Boolean) {
        val params = overlayParams ?: return
        val startX = params.x
        val targetX = if (startX + currentOverlayWidth() / 2 < screenWidth() / 2) dp(16) else maxOverlayX()

        ValueAnimator.ofInt(startX, targetX).apply {
            duration = 220
            addUpdateListener { animator ->
                params.x = animator.animatedValue as Int
                windowManager?.updateViewLayout(overlayView, params)
                updateCurrentOverlayBounds()
            }
            addListener(
                object : AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: Animator) {
                        updateCurrentOverlayBounds()
                        if (userInitiated) {
                            lastUserSelectedOverlayPosition =
                                OverlayProtection.Position(params.x, params.y)
                        }
                    }
                },
            )
            start()
        }
    }

    private fun prepareForClickTarget(x: Float, y: Float): Boolean {
        val params = overlayParams ?: run {
            Log.d(TAG, "prepareForClickTarget allowed; overlay params unavailable for ${x.toInt()},${y.toInt()}")
            return true
        }
        val overlay = overlayView ?: run {
            Log.d(TAG, "prepareForClickTarget allowed; overlay view unavailable for ${x.toInt()},${y.toInt()}")
            return true
        }
        val bounds = currentOverlayBounds ?: updateCurrentOverlayBounds()
        val safeMargin = dp(12)
        Log.d(TAG, "prepareForClickTarget target=${x.toInt()},${y.toInt()}; bounds=$bounds; safeMargin=$safeMargin")

        if (bounds == null ||
            !OverlayProtection.intersectsProtectedZone(
                bounds = bounds,
                x = x,
                y = y,
                safeMarginPx = safeMargin,
            )
        ) {
            return true
        }

        val relocation =
            OverlayProtection.chooseRelocation(
                targetX = x,
                targetY = y,
                overlaySize = OverlayProtection.Size(currentOverlayWidth(), currentOverlayHeight()),
                screenSize = OverlayProtection.Size(screenWidth(), screenHeight()),
                safeMarginPx = safeMargin,
                edgePaddingPx = dp(16),
                minTopPx = dp(32),
                lastUserPosition = lastUserSelectedOverlayPosition,
            )

        params.x = relocation.x
        params.y = relocation.y
        Log.d(
            TAG,
            "relocating overlay for protected target=${x.toInt()},${y.toInt()}; oldBounds=$bounds; newX=${params.x}; newY=${params.y}",
        )
        windowManager?.updateViewLayout(overlay, params)
        val updatedBounds = updateCurrentOverlayBounds()
        statusLabel?.text = "Overlay moved"
        Log.d(TAG, "Overlay moved to avoid protected auto-click target at ${x.toInt()},${y.toInt()}.")

        val safeAfterMove =
            updatedBounds != null &&
                !OverlayProtection.intersectsProtectedZone(
                    bounds = updatedBounds,
                    x = x,
                    y = y,
                    safeMarginPx = safeMargin,
                )
        if (!safeAfterMove) {
            Log.d(
                TAG,
                "Auto-click target skipped because overlay safe zone still overlaps ${x.toInt()},${y.toInt()}.",
            )
        }
        return safeAfterMove
    }

    private fun updateCurrentOverlayBounds(): OverlayProtection.Bounds? {
        val params = overlayParams ?: return null
        val bounds =
            OverlayProtection.Bounds(
                left = params.x,
                top = params.y,
                right = params.x + currentOverlayWidth(),
                bottom = params.y + currentOverlayHeight(),
            )
        currentOverlayBounds = bounds
        Log.d(TAG, "control overlay bounds updated: $bounds")
        return bounds
    }

    private fun currentOverlayWidth(): Int {
        val view = if (isExpanded) expandedBar else compactButton
        return view?.width?.takeIf { it > 0 } ?: dp(72)
    }

    private fun currentOverlayHeight(): Int {
        val view = if (isExpanded) expandedBar else compactButton
        return view?.height?.takeIf { it > 0 } ?: dp(72)
    }

    private fun maxOverlayX(): Int {
        return (screenWidth() - currentOverlayWidth() - dp(16)).coerceAtLeast(0)
    }

    private fun maxOverlayY(): Int {
        return (screenHeight() - currentOverlayHeight() - dp(48)).coerceAtLeast(dp(32))
    }

    private fun screenWidth(): Int = resources.displayMetrics.widthPixels

    private fun screenHeight(): Int = resources.displayMetrics.heightPixels

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density).toInt()
    }

    private fun openApp() {
        val launchIntent =
            packageManager.getLaunchIntentForPackage(packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
        if (launchIntent != null) {
            startActivity(launchIntent)
        }
    }

    private fun removeOverlay() {
        overlayView?.let { view ->
            Log.d(TAG, "removeView control overlay")
            runCatching { windowManager?.removeView(view) }
        }
        overlayView = null
        overlayParams = null
        currentOverlayBounds = null
    }

    private fun createNotification(): Notification {
        ensureNotificationChannel()

        val openIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent =
            PendingIntent.getActivity(
                this,
                11,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(
                when {
                    ClickAssistBridge.isPointPickerActive() -> "ClickAssist point picker active"
                    ClickAssistBridge.isRunning() -> "ClickAssist is running"
                    else -> "ClickAssist overlay ready"
                },
            )
            .setContentText(ClickAssistBridge.overlaySummary().speedLabel)
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .addAction(
                0,
                if (ClickAssistBridge.isRunning()) "Pause" else "Start",
                actionPendingIntent(ACTION_TOGGLE_CLICKING, 21),
            )
            .addAction(
                0,
                "Open",
                actionPendingIntent(ACTION_OPEN_APP, 22),
            )
            .addAction(
                0,
                "Hide Overlay",
                actionPendingIntent(ACTION_STOP_OVERLAY, 23),
            )
            .build()
    }

    private fun actionPendingIntent(action: String, requestCode: Int): PendingIntent {
        val intent = Intent(action).setPackage(packageName)
        return PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val manager = getSystemService(NotificationManager::class.java)
        val channel =
            NotificationChannel(
                CHANNEL_ID,
                "ClickAssist Overlay",
                NotificationManager.IMPORTANCE_LOW,
            )
        manager.createNotificationChannel(channel)
    }

    companion object {
        @Volatile
        private var activeService: FloatingOverlayService? = null

        private val COLOR_PRIMARY = 0xFF12C8FF.toInt()
        private val COLOR_SUCCESS = 0xFF2EE59D.toInt()
        private val COLOR_WARNING = 0xFFFFC857.toInt()
        private val COLOR_MUTED = 0xFF93A4C8.toInt()
        private const val TAG = "ClickAssistOverlay"
        private const val CHANNEL_ID = "clickassist_overlay"
        private const val NOTIFICATION_ID = 4401
        const val ACTION_TOGGLE_CLICKING = "clickassist.action.TOGGLE_CLICKING"
        const val ACTION_OPEN_APP = "clickassist.action.OPEN_APP"
        const val ACTION_STOP_OVERLAY = "clickassist.action.STOP_OVERLAY"
        const val ACTION_REFRESH_OVERLAY = "clickassist.action.REFRESH_OVERLAY"

        fun prepareForClickTarget(x: Float, y: Float): Boolean {
            return activeService?.prepareForClickTarget(x, y) ?: true
        }

        fun avoidClickTarget(x: Float, y: Float): Boolean {
            return prepareForClickTarget(x, y)
        }

        fun openOverlaySettings(context: Context) {
            val intent =
                Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${context.packageName}"),
                ).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            context.startActivity(intent)
        }
    }

}

