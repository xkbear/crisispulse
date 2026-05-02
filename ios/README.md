# Crisis Pulse — iOS

Native SwiftUI port of [crisispulse.org](https://crisispulse.org). Same backend
(Netlify Functions), same data, same conflicts — wrapped in a real iOS app
with MapKit, CoreLocation, and UserNotifications.

## Features (parity with web + iOS-native extras)

- 🗺  **MapKit world map** with conflict hotspots, color-coded by intensity
- 🆕 **NEW badges** for newly added or news-spiking conflicts
- 📰 **Bottom-sheet news panel** highlighting today's #1 top story (BREAKING / ESCALATING / HIGH ATTENTION)
- 📋 **Personalized supply calculator** — multi-step questionnaire → tailored checklist
- 🔔 **Native push notifications** when a tracked conflict's intensity jumps ≥ 1.0
- 📧 **Email subscribe** via the existing Resend pipeline (welcome + daily brief)
- 🌐 **Bilingual** EN / 中文 — toggleable in Settings, applied app-wide instantly
- 📍 **CoreLocation** to position your dot and pick country-specific guidance
- 🌙 Force dark scheme (matches web aesthetic)
- 📤 ShareLink for both conflict pages and the generated supply plan

## Project layout

```
ios/
├─ project.yml              # XcodeGen spec — generates .xcodeproj
├─ Makefile                 # `make setup`, `make project`, `make open`
├─ CrisisPulse/
│  ├─ CrisisPulseApp.swift  # @main + AppState
│  ├─ Info.plist
│  ├─ Models/               # Conflict, NewsItem, VisitorResponse, Calculator types
│  ├─ Services/             # APIClient, LocationManager, NotificationService
│  ├─ ViewModels/           # SupplyEngine
│  ├─ Views/                # ContentView, MapTabView, NewsPanelView,
│  │                        # ConflictDetailView, CalculatorView, SettingsView
│  ├─ Localization/         # L10n.swift (EN+ZH dictionary)
│  ├─ Utilities/            # Color+Intensity
│  └─ Resources/Assets.xcassets/  (AppIcon, AccentColor, LaunchBackground)
└─ README.md
```

## Build instructions

### Prerequisites

- macOS 14+
- Xcode 15+ (for iOS 17 SDK)
- Apple Developer account (any tier, free works for personal device)
- [Homebrew](https://brew.sh) — used to install XcodeGen

### One-time setup

```bash
cd ios
make setup        # installs xcodegen if missing, then generates CrisisPulse.xcodeproj
make open         # launches Xcode
```

In Xcode:

1. Select the `CrisisPulse` target → **Signing & Capabilities** tab
2. Pick your Apple Team in the dropdown (or fill in `DEVELOPMENT_TEAM` in `project.yml`)
3. Make sure **Bundle Identifier** is unique to you (default: `org.crisispulse.app`)

### Run on simulator

```bash
xcodebuild -project CrisisPulse.xcodeproj \
           -scheme CrisisPulse \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
           build
```

Or just press **⌘R** in Xcode after picking a simulator.

### Run on a real device

1. Plug iPhone in via USB (must be running iOS 17+)
2. Trust the computer if prompted
3. In Xcode toolbar, pick your device from the destination dropdown
4. Press **⌘R**
5. On the iPhone, go to **Settings → General → VPN & Device Management** and trust your developer profile

### Submit to App Store

1. In Xcode: **Product → Archive**
2. Window → Organizer → select the archive → **Distribute App → App Store Connect**
3. Fill in metadata in [App Store Connect](https://appstoreconnect.apple.com):
   - **Privacy nutrition label**: only "Location" data type is collected, used solely on-device
   - **Age rating**: 12+ (news/political content per Apple guidelines)
   - **Category**: News (primary), Reference (secondary)
   - **Keywords**: crisis map, conflict tracker, war news, emergency preparedness, OSINT, geopolitics
4. Add screenshots for 6.7" and 6.1" devices (use the simulator + ⌘S)
5. Submit for review (typically 24-48h)

## API contract (no auth, all CORS-enabled)

All endpoints live at `https://crisispulse.org/api/*` and are the same ones
the web app calls — see `netlify/functions/` in the repo root.

| Endpoint | Method | Used by |
|----------|--------|---------|
| `/api/conflicts` | GET | `APIClient.fetchConflicts()` — populates the map |
| `/api/visitor`   | POST | `APIClient.recordVisit()` — visitor counter |
| `/api/subscribe` | POST | `APIClient.subscribe()` — email signup, triggers Resend welcome email |
| `/api/notify`    | POST | (server-side only — daily brief / escalation alerts to subscribers) |

## Why no Capacitor / WKWebView?

The web app is a single 100 KB HTML file — wrapping it in a webview would have
been faster, but loses native iOS niceties:

- **Real Map gestures** (pinch, rotate, satellite toggle) via MapKit
- **System share sheet** (`ShareLink`) for conflict pages and supply plans
- **Local notifications** without needing a push server
- **Proper iOS dark mode**, Dynamic Type, VoiceOver
- **App Store discoverability** with the right keyword anchors

The Swift port took ~14 files, most of them under 200 lines.

## Versioning

Bump both in `project.yml`:

```yaml
settings:
  base:
    MARKETING_VERSION: "0.3.0"
    CURRENT_PROJECT_VERSION: "2"
```

Then `make project` to regenerate the Xcode project.

## License

Same as the parent repo. Free for personal and non-commercial use.
