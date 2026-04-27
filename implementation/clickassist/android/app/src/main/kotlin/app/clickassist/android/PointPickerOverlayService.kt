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
import android.widget.ImageView
import android.widget.TextView

class PointPickerOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var markerView: View? = null
    private var coordinateLabel: TextView? = null
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
        val hint = view.findViewById<TextView>(R.id.pointPickerHint)
        val closeButton = view.findViewById<ImageView>(R.id.pointPickerCloseButton)
        val confirmButton = view.findViewById<TextView>(R.id.pointPickerConfirmButton)
        val captureSurface = view.findViewById<View>(R.id.pointPickerSurface)
        markerView = view.findViewById(R.id.pointPickerMarker)
        coordinateLabel = view.findViewById(R.id.pointPickerCoordinates)

        hint.text = "Place the target marker, then press Confirm"
        updateSelection(
            resources.displayMetrics.widthPixels / 2f,
            resources.displayMetrics.heightPixels / 2f,
        )

        closeButton.setOnClickListener {
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

        captureSurface.setOnTouchListener { _, event ->
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
    }

    private fun updateSelection(rawX: Float, rawY: Float) {
        selectedX = rawX
        selectedY = rawY
        markerView?.translationX = rawX - ((markerView?.width ?: 0) / 2f)
        markerView?.translationY = rawY - ((markerView?.height ?: 0) / 2f)
        coordinateLabel?.text = "X ${rawX.toInt()}  |  Y ${rawY.toInt()}"
    }

    private fun removeOverlay() {
        overlayView?.let { view ->
            windowManager?.removeView(view)
        }
        overlayView = null
    }
}

