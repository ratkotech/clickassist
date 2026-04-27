package app.clickassist.android

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PointF
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import kotlin.math.hypot
import kotlin.math.max

class GestureIndicatorOverlay(
    private val context: Context,
) {
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    fun showTap(point: NativeClickPoint) {
        val view = TapIndicatorView(context)
        val size = 124
        val params = WindowManager.LayoutParams(
            size,
            size,
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            android.graphics.PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (point.x - size / 2f).toInt()
            y = (point.y - size / 2f).toInt()
        }
        showTemporary(view, params, 320L) { indicator ->
            indicator.animate()
                .alpha(0f)
                .scaleX(1.18f)
                .scaleY(1.18f)
                .setDuration(320L)
                .start()
        }
    }

    fun showSwipe(start: NativeClickPoint, end: NativeClickPoint) {
        val left = minOf(start.x, end.x)
        val top = minOf(start.y, end.y)
        val width = max(120f, kotlin.math.abs(end.x - start.x) + 120f)
        val height = max(120f, kotlin.math.abs(end.y - start.y) + 120f)
        val view = SwipeIndicatorView(
            context = context,
            start = PointF(start.x - left + 60f, start.y - top + 60f),
            end = PointF(end.x - left + 60f, end.y - top + 60f),
        )
        val params = WindowManager.LayoutParams(
            width.toInt(),
            height.toInt(),
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            android.graphics.PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = left.toInt() - 60
            y = top.toInt() - 60
        }

        showTemporary(view, params, 420L) { indicator ->
            indicator.animate()
                .alpha(0f)
                .setDuration(420L)
                .start()
        }
    }

    private fun showTemporary(
        view: View,
        params: WindowManager.LayoutParams,
        durationMs: Long,
        animate: (View) -> Unit,
    ) {
        runCatching {
            view.alpha = 1f
            windowManager.addView(view, params)
            animate(view)
            view.animate().setListener(
                object : AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: Animator) {
                        runCatching { windowManager.removeView(view) }
                    }
                },
            )
            view.postDelayed({
                runCatching { windowManager.removeView(view) }
            }, durationMs + 100L)
        }
    }
}

private class TapIndicatorView(context: Context) : View(context) {
    private val ringPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#24C8FF")
        style = Paint.Style.STROKE
        strokeWidth = 8f
    }
    private val centerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#B324C8FF")
        style = Paint.Style.FILL
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val centerX = width / 2f
        val centerY = height / 2f
        canvas.drawCircle(centerX, centerY, 16f, centerPaint)
        canvas.drawCircle(centerX, centerY, 38f, ringPaint)
        ringPaint.alpha = 110
        canvas.drawCircle(centerX, centerY, 52f, ringPaint)
    }
}

private class SwipeIndicatorView(
    context: Context,
    private val start: PointF,
    private val end: PointF,
) : View(context) {
    private val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#24C8FF")
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
        strokeWidth = 10f
    }
    private val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#7A24C8FF")
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
        strokeWidth = 22f
    }
    private val pointPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.FILL
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val path = Path().apply {
            moveTo(start.x, start.y)
            lineTo(end.x, end.y)
        }
        canvas.drawPath(path, glowPaint)
        canvas.drawPath(path, strokePaint)
        canvas.drawCircle(start.x, start.y, 10f, pointPaint)
        canvas.drawCircle(end.x, end.y, 12f, pointPaint)
        drawArrowHead(canvas)
    }

    private fun drawArrowHead(canvas: Canvas) {
        val dx = end.x - start.x
        val dy = end.y - start.y
        val length = max(1f, hypot(dx, dy))
        val unitX = dx / length
        val unitY = dy / length
        val arrowLength = 28f
        val arrowWidth = 14f
        val tip = PointF(end.x, end.y)
        val base = PointF(end.x - unitX * arrowLength, end.y - unitY * arrowLength)
        val normalX = -unitY
        val normalY = unitX
        val left = PointF(base.x + normalX * arrowWidth, base.y + normalY * arrowWidth)
        val right = PointF(base.x - normalX * arrowWidth, base.y - normalY * arrowWidth)
        val arrowPath = Path().apply {
            moveTo(tip.x, tip.y)
            lineTo(left.x, left.y)
            lineTo(right.x, right.y)
            close()
        }
        canvas.drawPath(arrowPath, pointPaint)
    }
}

