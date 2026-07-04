package app.clickassist.android

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class OverlayProtectionTest {
    @Test
    fun pointInsideOverlayBoundsIsProtected() {
        val bounds = OverlayProtection.Bounds(left = 100, top = 200, right = 300, bottom = 360)

        assertTrue(OverlayProtection.intersectsProtectedZone(bounds, x = 160f, y = 240f, safeMarginPx = 12))
    }

    @Test
    fun pointOutsideOverlayBoundsIsAllowed() {
        val bounds = OverlayProtection.Bounds(left = 100, top = 200, right = 300, bottom = 360)

        assertFalse(OverlayProtection.intersectsProtectedZone(bounds, x = 40f, y = 160f, safeMarginPx = 12))
    }

    @Test
    fun safeMarginExpandsProtectedBounds() {
        val bounds = OverlayProtection.Bounds(left = 100, top = 200, right = 300, bottom = 360)

        assertTrue(OverlayProtection.intersectsProtectedZone(bounds, x = 92f, y = 205f, safeMarginPx = 12))
        assertFalse(OverlayProtection.intersectsProtectedZone(bounds, x = 87f, y = 205f, safeMarginPx = 12))
    }

    @Test
    fun relocationChoosesPositionAwayFromTarget() {
        val relocation =
            OverlayProtection.chooseRelocation(
                targetX = 160f,
                targetY = 240f,
                overlaySize = OverlayProtection.Size(width = 180, height = 100),
                screenSize = OverlayProtection.Size(width = 420, height = 800),
                safeMarginPx = 12,
                edgePaddingPx = 16,
                minTopPx = 32,
                lastUserPosition = null,
            )

        val relocatedBounds =
            OverlayProtection.Bounds(
                left = relocation.x,
                top = relocation.y,
                right = relocation.x + 180,
                bottom = relocation.y + 100,
            )

        assertFalse(
            OverlayProtection.intersectsProtectedZone(
                relocatedBounds,
                x = 160f,
                y = 240f,
                safeMarginPx = 12,
            ),
        )
    }

    @Test
    fun relocationStaysInsideScreenBounds() {
        val relocation =
            OverlayProtection.chooseRelocation(
                targetX = 390f,
                targetY = 760f,
                overlaySize = OverlayProtection.Size(width = 180, height = 100),
                screenSize = OverlayProtection.Size(width = 420, height = 800),
                safeMarginPx = 12,
                edgePaddingPx = 16,
                minTopPx = 32,
                lastUserPosition = OverlayProtection.Position(x = 999, y = -50),
            )

        assertTrue(relocation.x in 16..224)
        assertTrue(relocation.y in 32..652)
    }

    @Test
    fun safeLastUserPositionIsPreferred() {
        val relocation =
            OverlayProtection.chooseRelocation(
                targetX = 390f,
                targetY = 760f,
                overlaySize = OverlayProtection.Size(width = 120, height = 80),
                screenSize = OverlayProtection.Size(width = 420, height = 800),
                safeMarginPx = 12,
                edgePaddingPx = 16,
                minTopPx = 32,
                lastUserPosition = OverlayProtection.Position(x = 24, y = 120),
            )

        assertEquals(OverlayProtection.Position(x = 24, y = 120), relocation)
    }
}
