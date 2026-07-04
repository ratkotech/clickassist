# ClickAssist Diagrams

This file contains current Mermaid diagrams for the ClickAssist architecture, user flows, overlay lifecycle, safe-zone behavior, theme system, presets, and testing strategy.

## A. High-level app architecture

```mermaid
flowchart TD
    FlutterApp["Flutter app"]
    ThemeSystem["Theme system"]
    ClickerFeature["Clicker feature"]
    Presentation["Presentation/widgets"]
    Controller["Controller/state layer"]
    Storage["Presets/settings/storage"]
    NativeBridge["Native Android bridge"]
    Accessibility["Accessibility service"]
    Overlay["Overlay controls"]
    PointPicker["Point picker overlay"]

    FlutterApp --> ThemeSystem
    FlutterApp --> ClickerFeature
    ClickerFeature --> Presentation
    ClickerFeature --> Controller
    Controller --> Storage
    Controller --> NativeBridge
    NativeBridge --> Accessibility
    NativeBridge --> PointPicker
    Accessibility --> Overlay
    Overlay --> Accessibility
    PointPicker --> Controller
```

## B. Folder/module structure

```mermaid
flowchart TD
    Repo["clickassist repository"]
    Design["design\nLogo and brand assets"]
    Docs["docs\nAnalysis, screenshots, archive"]
    Impl["implementation/clickassist\nFlutter Android app"]
    Lib["lib\nFlutter source"]
    Theme["lib/app/theme\nTheme tokens"]
    Features["lib/features/clicker\nClicker feature"]
    Android["android/app/src/main\nNative Android integration"]
    Tests["test and android/app/src/test\nFlutter and Kotlin tests"]

    Repo --> Design
    Repo --> Docs
    Repo --> Impl
    Impl --> Lib
    Lib --> Theme
    Lib --> Features
    Impl --> Android
    Impl --> Tests
```

## C. User journey flow

```mermaid
flowchart TD
    Open["Open app"]
    Permission["Check accessibility permission"]
    HasPermission{"Permission enabled?"}
    Setup["Show setup guide"]
    AndroidSettings["Open Android settings"]
    Configure["Configure clicker"]
    Pick{"Need screen target?"}
    Picker["Open point picker\nDrag marker\nConfirm or cancel"]
    Preset["Choose preset if needed"]
    Start["Start clicker"]
    Overlay["Overlay appears"]
    Runtime["Use pause/stop controls"]
    Dashboard["Return to dashboard"]

    Open --> Permission
    Permission --> HasPermission
    HasPermission -- "No" --> Setup
    Setup --> AndroidSettings
    AndroidSettings --> Permission
    HasPermission -- "Yes" --> Configure
    Configure --> Pick
    Pick -- "Yes" --> Picker
    Picker --> Configure
    Pick -- "No" --> Preset
    Preset --> Start
    Configure --> Start
    Start --> Overlay
    Overlay --> Runtime
    Runtime --> Dashboard
```

## D. Accessibility permission flow

```mermaid
flowchart TD
    Missing["Accessibility permission missing"]
    Guide["Setup guide shows required step"]
    OpenSettings["User opens Android settings"]
    Enable["User enables ClickAssist service"]
    Refresh["App refreshes permission status"]
    Ready["Start button can be used"]

    Missing --> Guide
    Guide --> OpenSettings
    OpenSettings --> Enable
    Enable --> Refresh
    Refresh --> Ready
```

## E. Clicker start sequence

```mermaid
sequenceDiagram
    participant User
    participant UI as Flutter UI
    participant State as Clicker controller/state
    participant Bridge as Native Android bridge
    participant Service as Accessibility service
    participant Overlay as Overlay

    User->>UI: Configure clicker
    UI->>State: Store selected configuration
    User->>UI: Tap start
    UI->>State: Request start
    State->>Bridge: Send command and config
    Bridge->>Service: Start click loop
    Service->>Overlay: Show overlay controls
    Service->>Service: Check target against overlay safe zone
    Service-->>Bridge: Runtime status
    Bridge-->>State: Status update
    State-->>UI: Reflect running state
```

## F. Point picker target-selection flow

```mermaid
flowchart TD
    Add["User taps Pick On Screen"]
    Flutter["Flutter shows picker active state"]
    Native["Start PointPickerOverlayService"]
    Instructions["Show top instruction card"]
    Marker["Drag bullseye marker"]
    Coordinates["Update saved/clamped coordinates"]
    Decision{"Confirm target?"}
    Save["Record captured point through bridge"]
    Cancel["Close picker without saving"]
    Card["Show confirmed target card"]

    Add --> Flutter
    Flutter --> Native
    Native --> Instructions
    Instructions --> Marker
    Marker --> Coordinates
    Coordinates --> Decision
    Decision -- "Yes" --> Save
    Save --> Card
    Decision -- "No" --> Cancel
    Cancel --> Flutter
```

## G. Overlay lifecycle

```mermaid
flowchart TD
    Start["Clicker starts"]
    Create["Create floating overlay"]
    Display["Display controls"]
    Track["Track overlay bounds"]
    Drag["User drags overlay"]
    Running["Clicker running"]
    Control{"User control action"}
    Pause["Pause or resume"]
    Stop["Stop or close"]
    Remove["Remove overlay"]
    Cleanup["Service cleanup"]

    Start --> Create
    Create --> Display
    Display --> Track
    Track --> Running
    Running --> Drag
    Drag --> Track
    Running --> Control
    Control -- "Pause/resume" --> Pause
    Pause --> Running
    Control -- "Stop/close" --> Stop
    Stop --> Remove
    Remove --> Cleanup
```

## H. Overlay safe-zone protection

```mermaid
flowchart TD
    Target["Planned click coordinate"]
    Bounds["Current overlay bounds"]
    Margin["Apply safe margin"]
    Check{"Coordinate inside protected zone?"}
    Dispatch["Dispatch accessibility gesture"]
    Relocate["Try relocating overlay"]
    Recheck{"Target safe after relocation?"}
    Skip["Skip protected tap and log/status reason"]
    Continue["Continue click loop"]

    Target --> Check
    Bounds --> Margin
    Margin --> Check
    Check -- "No" --> Dispatch
    Dispatch --> Continue
    Check -- "Yes" --> Relocate
    Relocate --> Recheck
    Recheck -- "Yes" --> Dispatch
    Recheck -- "No" --> Skip
    Skip --> Continue
```

## I. Theme and typography dependency

```mermaid
flowchart TD
    TextStyles["app_text_styles.dart"]
    AppTheme["app_theme.dart"]
    ThemeData["Flutter ThemeData"]
    Components["App-wide components"]
    StartButton["clicker_start_button.dart"]
    DashboardCard["dashboard_status_card.dart"]
    SetupGuide["setup_guide_card.dart"]
    Tests["Typography/theme tests"]

    TextStyles --> AppTheme
    AppTheme --> ThemeData
    ThemeData --> Components
    Components --> StartButton
    Components --> DashboardCard
    Components --> SetupGuide
    TextStyles --> Tests
    AppTheme --> Tests
```

## J. Preset/configuration flow

```mermaid
flowchart TD
    Edit["User edits configuration"]
    Validate["Validate clicker settings"]
    Save["Save preset/settings locally"]
    Load["Load preset"]
    Apply["Apply selected configuration"]
    Start["Start clicker with selected config"]
    Native["Send config to native service"]

    Edit --> Validate
    Validate --> Save
    Save --> Load
    Load --> Apply
    Apply --> Start
    Start --> Native
```

## K. Testing strategy

```mermaid
flowchart TD
    Strategy["Testing strategy"]
    Unit["Unit tests"]
    Widget["Widget tests"]
    Theme["Theme consistency tests"]
    Overlay["Overlay logic tests"]
    Manual["Manual Android device tests"]
    Screenshots["Screenshot refresh workflow"]

    Strategy --> Unit
    Strategy --> Widget
    Strategy --> Theme
    Strategy --> Overlay
    Strategy --> Manual
    Strategy --> Screenshots
```
