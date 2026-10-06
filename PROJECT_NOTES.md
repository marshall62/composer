
# Composer — Project Notes
 
## What this app does
An iPhone app for artists: pick a photo, crop it to match a physical canvas's aspect ratio, and overlay a reference grid (4x4, 8x8, or a custom real-world square size) to help transfer a composition onto canvas. Optional posterize and black & white filters simplify the photo into flatter shapes for easier reading.
 
## Tech stack
- Swift + SwiftUI, built from scratch (no template)
- `PhotosUI`'s `PhotosPicker` / `.photosPicker(isPresented:)` for photo selection — deliberately chosen because it needs **no library-read permission** at all (post-iOS 14 picker runs out-of-process)
- Core Image (`CIColorPosterize`, `CIColorControls`) for posterize/grayscale
- Core Graphics/UIKit interop for actual pixel-accurate cropping
- Swift Testing (`@Test`/`#expect`, not XCTest) for all pure-logic unit tests
- Built via Xcode on a personal (free) Apple ID — see "Build/deploy notes" below
## Development approach
Built conversationally with Claude, test-driven for every piece of pure logic (geometry, validation): tests written first, then implementation, red before green. UI/gesture wiring was treated as "glue code" and verified manually on-device rather than unit tested. The user writes/pastes the actual code into Xcode and runs it — Claude explains concepts and proposes code, but doesn't have direct access to the Xcode project.
 
## File structure & responsibilities
- **`ComposerApp.swift`** — `@main` entry point → `ContentView()`
- **`ContentView.swift`** — canvas-settings screen: width/height (decimal keypad), grid type picker (4x4/8x8/Custom + square size field), validation (hard-blocking errors vs. soft warnings for a square size that doesn't evenly divide the canvas), "Continue" → `PhotoPickerView`
- **`CanvasSettings.swift`** — `GridType` enum (`.fourByFour`, `.eightByEight`, `.customSquare(size:)`, `Equatable`), `CanvasSettings` struct, `blockingErrors(for:)`, `warnings(for:)` — all pure, all tested
- **`PhotoPickerView.swift`** — photo selection; holds `showPhotoPicker` state so a menu item deep in the view tree (in `GriddedCropView`) can request a new photo via a callback
- **`CropRect.swift`** — `cropRect(from:to:aspectRatio:imageBounds:)` (horizontal-drag-driven sizing only; clamped to image bounds in both axes), `resizeFromTopLeft(anchor:current:aspectRatio:)` (mirror for the opposite corner), `croppedImage(_:to:)` (normalizes EXIF orientation via `UIImage.draw(in:)` before cropping the raw `CGImage` — raw cropping ignores orientation metadata, a common camera-photo gotcha)
- **`TranslateRect.swift`** — `translateRect(_:by:imageBounds:)`, moves the rect without resizing
- **`GridLines.swift`** — `LineSegment`, `evenGridLines(for:columns:rows:)` (4x4/8x8), `squareGridLines(for:canvasWidth:canvasHeight:squareSize:)` (floor + leftover-strip for square sizes that don't evenly divide the canvas)
- **`PixelConversion.swift`** — `convertToImagePixels(_:scale:)`, converts on-screen crop coordinates to the photo's actual pixel coordinates
- **`CropView.swift`** — the interactive crop screen: sweep-to-create, two 44×44-tap-target corner handles (25×25 visible dot), drag-to-translate, "Accept" button positioned *inside* the rectangle (not below — avoids going off-screen near image edges), top padding to reduce accidental Notification Center swipe conflicts in landscape; menu with "Swap Canvas Dimensions" and "Choose Different Photo"
- **`GriddedImageView.swift`** — stateless renderer: image + grid lines via `Canvas`, manual scaledToFit/offset math
- **`GriddedCropView.swift`** — final screen: owns grid color/density/posterize/B&W state; submenu-organized ellipsis menu ("Grid", "Effects", "Choose New Photo"); caches the filtered image via `@State` + `.onChange` so Core Image filters don't re-run on unrelated UI changes
- **`ImageFilters.swift`** — `posterized(_:levels:)`, `desaturated(_:)` (named to avoid colliding with SwiftUI's own `.grayscale()` view modifier — a real naming collision hit during development)
## Key design decisions worth remembering
- Crop sizing is **deliberately horizontal-drag-only** — vertical finger movement never affects size. This was a conscious choice after exploring (and rejecting) two alternatives: "whichever direction moved more" and "project onto the nearest valid ratio line." Both gave smoother multi-directional feel but broke the simple "width tracks my finger exactly" guarantee the user wanted. Known accepted consequence: dragging a handle straight up/down with zero horizontal movement collapses the rect to zero width.
- The lower-right handle reuses `cropRect` directly (same math as initial creation); only the upper-left handle needed distinct mirrored logic.
- The "Accept" button's visibility is gated on `!creatingNewRect`, not a separate historical flag — because iOS can cancel an in-flight SwiftUI gesture (e.g., Notification Center swiping over the app) without firing `.onEnded`. Every gesture's `onEnded` defensively resets `creatingNewRect = false`, so any later-completed gesture self-heals the state if an earlier one was interrupted.
- SwiftUI `Menu` becomes scrollable (not resized) when content exceeds available height — easy to miss, especially in landscape. Solved by grouping items into submenus rather than relying on people discovering the hidden scroll.
- `ColorPicker` and `Slider` embedded directly inside a `Menu` had visibility/interaction issues (translucency, unclear state); both were moved to their own `.sheet` presentations instead.
## Build/deploy notes
- Personal (free) Apple ID — installed apps expire after 7 days and must be renewed by reconnecting to the Mac and re-running from Xcode (not a Settings toggle). A paid $99/year account removes this (profiles last ~1 year) and is required for actual App Store distribution.
- Current Xcode/macOS supports only specific late-model Intel Macs; any Apple Silicon Mac (M1 or later) works with no such restriction. Whether the user's personal Intel MacBook qualifies was left unresolved — check "About This Mac" against Apple's supported list if resuming work on that machine.
- Code is on GitHub: **github.com/marshall62/composer**, pushed via SSH (GitHub no longer accepts password auth for git operations).
## Not yet built / deliberately deferred
- In-app "Save Image" (render the grid+photo composite via `ImageRenderer`, save via `UIImageWriteToSavedPhotosAlbum`) — skipped in favor of the OS's built-in screenshot, judged simpler and good enough for now.
- No "back" navigation from `PhotoPickerView`/`CropView` to the canvas-settings screen — only forward flow, plus "Choose Different Photo" to restart photo selection.
## Resuming in a new session
Share the GitHub repo link and this file. Mention this was built via a TDD-driven, learn-Swift-by-pairing approach — the user writes/pastes code into Xcode themselves and wants to stay in control of what gets typed, with explanations of Swift/SwiftUI concepts along the way rather than just finished code dumps.
