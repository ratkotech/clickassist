package app.clickassist.android

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView

class PointPickerOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var markerView: View? = null
    private var coordinateLabel: TextView? = null
    private var markerCoordinateLabel: TextView? = null
    private var selectedX = 0f
    private var selectedY = 0f

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        if (!Settings.canDrawOverlays(this)) {
            stopSelf()
            return
        }

        showOverlay()
        ClickAssistBridge.setPointPickerActive(this, true)
    }

    override fun onDestroy() {
        removeOverlay()
        ClickAssistBridge.setPointPickerActive(this, false)
        super.onDestroy()
    }

    private fun showOverlay() {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val view = inflater.inflate(R.layout.point_picker_overlay, null)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        bindOverlayActions(view)
        windowManager?.addView(view, params)
        overlayView = view
    }

    private fun bindOverlayActions(view: View) {
        val cancelButton = view.findViewById<TextView>(R.id.pointPickerCancelButton)
        val confirmButton = view.findViewById<TextView>(R.id.pointPickerConfirmButton)
        val captureSurface = view.findViewById<View>(R.id.pointPickerSurface)
        markerView = view.findViewById(R.id.pointPickerMarker)
        coordinateLabel = view.findViewById(R.id.pointPickerCoordinates)
        markerCoordinateLabel = view.findViewById(R.id.pointPickerMarkerCoordinates)

        updateSelection(
            resources.displayMetrics.widthPixels / 2f,
            resources.displayMetrics.heightPixels / 2f,
        )

        cancelButton.setOnClickListener {
            ClickAssistBridge.updateStatus(
                context = this,
                message = "Point picker cancelled.",
            )
            stopSelf()
        }

        confirmButton.setOnClickListener {
            ClickAssistBridge.recordCapturedPoint(
                context = this,
                x = selectedX,
                y = selectedY,
                screenWidth = resources.displayMetrics.widthPixels,
                screenHeight = resources.displayMetrics.heightPixels,
            )
            stopSelf()
        }

        val updateFromTouch = View.OnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN,
                MotionEvent.ACTION_MOVE,
                MotionEvent.ACTION_UP,
                -> {
                    updateSelection(event.rawX, event.rawY)
                    true
                }

                else -> true
            }
        }
        captureSurface.setOnTouchListener(updateFromTouch)
        markerView?.setOnTouchListener(updateFromTouch)
    }

    private fun updateSelection(rawX: Float, rawY: Float) {
        val markerWidth = markerView?.width?.takeIf { it > 0 } ?: dp(112)
        val markerHeight = markerView?.height?.takeIf { it > 0 } ?: dp(112)
        val halfWidth = markerWidth / 2f
        val halfHeight = markerHeight / 2f
        val screenWidth = resources.displayMetrics.widthPixels.toFloat()
        val screenHeight = resources.displayMetrics.heightPixels.toFloat()
        val clampedX = rawX.coerceIn(halfWidth, screenWidth - halfWidth)
        val clampedY = rawY.coerceIn(halfHeight, screenHeight - halfHeight)

        selectedX = clampedX
        selectedY = clampedY
        markerView?.translationX = clampedX - halfWidth
        markerView?.translationY = clampedY - halfHeight
        coordinateLabel?.text = "X: ${selectedX.toInt()}  |  Y: ${selectedY.toInt()}"
        markerCoordinateLabel?.text = "X ${selectedX.toInt()} · Y ${selectedY.toInt()}"
    }

    private fun removeOverlay() {
        overlayView?.let { view ->
            windowManager?.removeView(view)
        }
        overlayView = null
    }

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density).toInt()
    }
}

