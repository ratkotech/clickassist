package app.clickassist.android

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import kotlin.math.max

class AutoClickAccessibilityService : AccessibilityService() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var gestureIndicatorOverlay: GestureIndicatorOverlay
    private var activeConfig: AutoClickConfig? = null
    private var isClicking = false
    private var totalClicks = 0
    private var completedCycles = 0
    private var currentStepIndex = 0

    private val clickRunnable = object : Runnable {
        override fun run() {
            val config = activeConfig ?: return
            val activeSteps = activeSteps(config)
            if (!isClicking || activeSteps.isEmpty()) {
                return
            }

            val shouldRunSimultaneous =
                config.multiClick &&
                    config.pointTimingMode == "simultaneous" &&
                    activeSteps.size > 1

            if (shouldRunSimultaneous) {
                runSimultaneousCycle(config, activeSteps)
                return
            }

            runSequentialStep(config, activeSteps)
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        gestureIndicatorOverlay = GestureIndicatorOverlay(this)
        ClickAssistBridge.attachService(this, this)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit

    override fun onInterrupt() {
        stopClicking("Accessibility service interrupted.")
    }

    override fun onDestroy() {
        stopClicking("Accessibility service disconnected.")
        ClickAssistBridge.detachService(this, this)
        super.onDestroy()
    }

    fun startClicking(config: AutoClickConfig) {
        activeConfig = config
        totalClicks = 0
        completedCycles = 0
        currentStepIndex = 0
        isClicking = true
        handler.removeCallbacks(clickRunnable)

        ClickAssistBridge.updateStatus(
            context = this,
            isRunning = true,
            totalClicks = totalClicks,
            message =
                if (config.startDelayMs > 0) {
                    "Starting in ${config.startDelayMs / 1000}s."
                } else {
                    "Clicker running."
                },
        )

        AppStatusNotifier.showClickerStarted(this, config.startDelayMs)
        handler.postDelayed(clickRunnable, config.startDelayMs.toLong())
    }

    fun stopClicking(message: String = "Clicker stopped.") {
        val wasRunning = isClicking
        isClicking = false
        handler.removeCallbacks(clickRunnable)
        activeConfig = null
        ClickAssistBridge.updateStatus(
            context = this,
            isRunning = false,
            totalClicks = totalClicks,
            message = message,
        )
        if (wasRunning) {
            AppStatusNotifier.showClickerStopped(this, message)
        }
    }

    fun isRunning(): Boolean = isClicking

    fun totalClicks(): Int = totalClicks

    private fun runSequentialStep(
        config: AutoClickConfig,
        activeSteps: List<NativeClickStep>,
    ) {
        val step = activeSteps[currentStepIndex % activeSteps.size]
        val startPoint =
            resolvePoint(config, step.pointId)
                ?: run {
                    advancePastInvalidStep(config, activeSteps)
                    return
                }
        val endPoint =
            if (step.actionType == "swipe") {
                resolvePoint(config, step.endPointId)
            } else {
                null
            }
        val offsets =
            if (step.actionType == "swipe") listOf(0L) else patternOffsets(config.pattern)
        val completedActionCount = if (step.actionType == "swipe") 1 else offsets.size
        showIndicators(config, startPoint, endPoint, offsets, step.actionType)

        val gesture =
            buildGesture(
                listOf(
                    GestureStroke(
                        startPoint = startPoint,
                        endPoint = endPoint,
                        offsets = offsets,
                        pressDurationMs = step.pressDurationMs,
                    ),
                ),
            )

        dispatchGesture(
            gesture,
            object : GestureResultCallback() {
                override fun onCompleted(gestureDescription: GestureDescription?) {
                    totalClicks += completedActionCount
                    val stepWasLastInCycle = currentStepIndex == activeSteps.lastIndex
                    currentStepIndex = (currentStepIndex + 1) % activeSteps.size

                    if (stepWasLastInCycle) {
                        completedCycles += 1
                    }

                    ClickAssistBridge.updateStatus(
                        context = this@AutoClickAccessibilityService,
                        isRunning = true,
                        totalClicks = totalClicks,
                        message =
                            if (config.multiClick && activeSteps.size > 1) {
                                "${if (step.actionType == "swipe") "Swipe" else "Tap"} step ${currentStepIndex + 1} queued."
                            } else {
                                if (step.actionType == "swipe") "Swipe running." else "Clicker running."
                            },
                    )

                    if (!config.infiniteMode && completedCycles >= config.targetCycles) {
                        stopClicking("Target cycle count reached.")
                        return
                    }

                    scheduleNextStep(step, offsets)
                }

                override fun onCancelled(gestureDescription: GestureDescription?) {
                    if (isClicking) {
                        scheduleNextStep(step, offsets)
                    }
                }
            },
            null,
        )
    }

    private fun runSimultaneousCycle(
        config: AutoClickConfig,
        activeSteps: List<NativeClickStep>,
    ) {
        val strokes =
            activeSteps.mapNotNull { step ->
                val startPoint = resolvePoint(config, step.pointId) ?: return@mapNotNull null
                val endPoint =
                    if (step.actionType == "swipe") {
                        resolvePoint(config, step.endPointId)
                    } else {
                        null
                    }
                val offsets =
                    if (step.actionType == "swipe") listOf(0L) else patternOffsets(config.pattern)

                showIndicators(config, startPoint, endPoint, offsets, step.actionType)

                GestureStroke(
                    startPoint = startPoint,
                    endPoint = endPoint,
                    offsets = offsets,
                    pressDurationMs = step.pressDurationMs,
                )
            }

        if (strokes.isEmpty()) {
            stopClicking("No valid points available for simultaneous mode.")
            return
        }

        val completedActionCount =
            strokes.sumOf { stroke ->
                if (stroke.endPoint != null) 1 else stroke.offsets.size
            }
        val gesture = buildGesture(strokes)
        val nextDelay = simultaneousCycleDelay(activeSteps, strokes)

        dispatchGesture(
            gesture,
            object : GestureResultCallback() {
                override fun onCompleted(gestureDescription: GestureDescription?) {
                    totalClicks += completedActionCount
                    completedCycles += 1

                    ClickAssistBridge.updateStatus(
                        context = this@AutoClickAccessibilityService,
                        isRunning = true,
                        totalClicks = totalClicks,
                        message = "Simultaneous cycle running.",
                    )

                    if (!config.infiniteMode && completedCycles >= config.targetCycles) {
                        stopClicking("Target cycle count reached.")
                        return
                    }

                    handler.postDelayed(clickRunnable, nextDelay)
                }

                override fun onCancelled(gestureDescription: GestureDescription?) {
                    if (isClicking) {
                        handler.postDelayed(clickRunnable, nextDelay)
                    }
                }
            },
            null,
        )
    }

    private fun activeSteps(config: AutoClickConfig): List<NativeClickStep> {
        val mappedSteps =
            config.clickSteps.filter { step ->
                val hasStartPoint = config.clickPoints.any { point -> point.id == step.pointId }
                val hasValidEndPoint =
                    step.actionType != "swipe" ||
                        (
                            step.endPointId != null &&
                                step.endPointId != step.pointId &&
                                config.clickPoints.any { point -> point.id == step.endPointId }
                            )
                hasStartPoint && hasValidEndPoint
            }

        return if (config.multiClick && mappedSteps.isNotEmpty()) {
            mappedSteps
        } else if (mappedSteps.isNotEmpty()) {
            listOf(mappedSteps.first())
        } else {
            config.clickPoints.take(1).mapIndexed { index, point ->
                NativeClickStep(
                    id = "fallback-$index",
                    pointId = point.id,
                    actionType = "tap",
                    endPointId = null,
                    delayMs = config.intervalMs,
                    pressDurationMs = 24L,
                )
            }
        }
    }

    private fun resolvePoint(config: AutoClickConfig, pointId: String?): NativeClickPoint? {
        val point =
            config.clickPoints.firstOrNull { it.id == pointId }
                ?: config.clickPoints.firstOrNull()
                ?: return null
        val metrics = resources.displayMetrics
        val resolvedX = point.xPercent?.let { it * metrics.widthPixels } ?: point.x
        val resolvedY = point.yPercent?.let { it * metrics.heightPixels } ?: point.y
        return point.copy(x = resolvedX, y = resolvedY)
    }

    private fun buildGesture(strokes: List<GestureStroke>): GestureDescription {
        val builder = GestureDescription.Builder()
        strokes.forEach { stroke ->
            stroke.offsets.forEach { offset ->
                val path =
                    Path().apply {
                        moveTo(stroke.startPoint.x, stroke.startPoint.y)
                        if (stroke.endPoint != null) {
                            lineTo(stroke.endPoint.x, stroke.endPoint.y)
                        }
                    }
                builder.addStroke(
                    GestureDescription.StrokeDescription(
                        path,
                        offset,
                        stroke.pressDurationMs.coerceIn(1L, 1200L),
                    ),
                )
            }
        }
        return builder.build()
    }

    private fun showIndicators(
        config: AutoClickConfig,
        startPoint: NativeClickPoint,
        endPoint: NativeClickPoint?,
        offsets: List<Long>,
        actionType: String,
    ) {
        if (!config.showGestureIndicator) {
            return
        }

        if (actionType == "swipe" && endPoint != null) {
            gestureIndicatorOverlay.showSwipe(startPoint, endPoint)
            return
        }

        offsets.forEachIndexed { index, offset ->
            handler.postDelayed(
                { gestureIndicatorOverlay.showTap(startPoint) },
                offset + (index * 12L),
            )
        }
    }

    private fun patternOffsets(pattern: String): List<Long> {
        return when (pattern) {
            "double" -> listOf(0L, 90L)
            "triple" -> listOf(0L, 90L, 180L)
            "burst" -> listOf(0L, 70L, 140L, 210L, 280L)
            "wave" -> listOf(0L, 80L, 190L, 340L)
            "heart" -> listOf(0L, 110L)
            else -> listOf(0L)
        }
    }

    private fun cycleDelay(step: NativeClickStep, offsets: List<Long>): Long {
        val finalOffset = offsets.lastOrNull() ?: 0L
        return max(step.delayMs.toLong(), finalOffset + step.pressDurationMs + 12L)
    }

    private fun simultaneousCycleDelay(
        steps: List<NativeClickStep>,
        strokes: List<GestureStroke>,
    ): Long {
        var maxDelay = 10L
        steps.forEachIndexed { index, step ->
            val stroke = strokes.getOrNull(index) ?: return@forEachIndexed
            val finalOffset = stroke.offsets.lastOrNull() ?: 0L
            val candidate =
                max(step.delayMs.toLong(), finalOffset + stroke.pressDurationMs + 12L)
            if (candidate > maxDelay) {
                maxDelay = candidate
            }
        }
        return maxDelay
    }

    private fun scheduleNextStep(step: NativeClickStep, offsets: List<Long>) {
        handler.postDelayed(clickRunnable, cycleDelay(step, offsets))
    }

    private fun advancePastInvalidStep(
        config: AutoClickConfig,
        activeSteps: List<NativeClickStep>,
    ) {
        currentStepIndex = (currentStepIndex + 1) % activeSteps.size
        if (currentStepIndex == 0) {
            completedCycles += 1
        }

        if (!config.infiniteMode && completedCycles >= config.targetCycles) {
            stopClicking("Target cycle count reached.")
            return
        }

        handler.postDelayed(clickRunnable, config.intervalMs.toLong().coerceAtLeast(50L))
    }

    private data class GestureStroke(
        val startPoint: NativeClickPoint,
        val endPoint: NativeClickPoint?,
        val offsets: List<Long>,
        val pressDurationMs: Long,
    )
}

