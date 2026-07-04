package app.clickassist.android

object OverlayProtection {
    data class Bounds(
        val left: Int,
        val top: Int,
        val right: Int,
        val bottom: Int,
    )

    data class Size(
        val width: Int,
        val height: Int,
    )

    data class Position(
        val x: Int,
        val y: Int,
    )

    fun intersectsProtectedZone(
        bounds: Bounds,
        x: Float,
        y: Float,
        safeMarginPx: Int,
    ): Boolean {
        return x >= bounds.left - safeMarginPx &&
            x <= bounds.right + safeMarginPx &&
            y >= bounds.top - safeMarginPx &&
            y <= bounds.bottom + safeMarginPx
    }

    fun boundsFor(
        position: Position,
        size: Size,
    ): Bounds {
        return Bounds(
            left = position.x,
            top = position.y,
            right = position.x + size.width,
            bottom = position.y + size.height,
        )
    }

    fun chooseRelocation(
        targetX: Float,
        targetY: Float,
        overlaySize: Size,
        screenSize: Size,
        safeMarginPx: Int,
        edgePaddingPx: Int,
        minTopPx: Int,
        lastUserPosition: Position?,
    ): Position {
        val maxX = (screenSize.width - overlaySize.width - edgePaddingPx).coerceAtLeast(edgePaddingPx)
        val maxY = (screenSize.height - overlaySize.height - edgePaddingPx * 3).coerceAtLeast(minTopPx)
        val minY = minTopPx.coerceAtMost(maxY)

        fun clamp(position: Position): Position {
            return Position(
                x = position.x.coerceIn(edgePaddingPx, maxX),
                y = position.y.coerceIn(minY, maxY),
            )
        }

        fun isSafe(position: Position): Boolean {
            return !intersectsProtectedZone(
                bounds = boundsFor(position, overlaySize),
                x = targetX,
                y = targetY,
                safeMarginPx = safeMarginPx,
            )
        }

        val preferredHorizontal =
            if (targetX < screenSize.width / 2f) {
                maxX
            } else {
                edgePaddingPx
            }
        val preferredVertical =
            if (targetY < screenSize.height / 2f) {
                maxY
            } else {
                minY
            }

        val candidates =
            buildList {
                lastUserPosition?.let { add(clamp(it)) }
                add(clamp(Position(preferredHorizontal, preferredVertical)))
                add(clamp(Position(edgePaddingPx, minY)))
                add(clamp(Position(maxX, minY)))
                add(clamp(Position(edgePaddingPx, maxY)))
                add(clamp(Position(maxX, maxY)))
            }.distinct()

        return candidates.firstOrNull(::isSafe) ?: candidates.first()
    }
}
