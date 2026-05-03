# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # install dependencies
flutter run              # run on connected device/simulator
flutter run -d chrome    # run as web app
flutter build apk        # build Android APK
flutter build ios        # build iOS (requires Mac + Xcode)
flutter test             # run all tests
flutter test test/widget_test.dart  # run a single test file
flutter analyze          # lint / static analysis
```

## Architecture

Single-provider Flutter app. `AppState` (`lib/providers/app_state.dart`) is the sole `ChangeNotifier`, wrapped at the root in `main.dart`. Every screen reads from and writes to it via `context.watch<AppState>()` / `context.read<AppState>()`.

**Navigation flow** (all via `Navigator.pushReplacement` or `push`, no named routes):

```
SplashScreen → CountInputScreen → QuranViewerScreen
                                        └─ push → SelectedAyahsScreen
                                        └─ push → CounterScreen (opened from SelectedAyahsScreen)
```

`CountInputScreen` is the home after the first launch; it sets the "санақ" (recitation count) goal before entering the viewer.

**Data layer** — `QuranService` (`lib/services/quran_service.dart`) fetches from `api.quran.com/api/v4`:
- `GET /chapters?language=ar` — Arabic surah names (loaded once, cached in a static `Map<int, String>`)
- `GET /verses/by_page/{n}?fields=text_uthmani,...` — up to 50 ayahs per mushaf page

Both the service (`_pageCache`) and `AppState` (`_pages`) cache pages in memory; the service cache is static (app lifetime), the state cache lasts the session.

**Ayah selection** — two parallel structures in `AppState`:
- `selectedAyahIds` (`Set<int>`) for O(1) membership checks (used for highlight rendering)
- `selectedAyahs` (`List<Ayah>`) for ordered display in `SelectedAyahsScreen`

Both must be kept in sync; use `toggleAyah`, `removeAyah`, and `clearAllAyahs` rather than mutating directly.

**Persistence** (`shared_preferences`): only three keys — `launched` (bool), `sanaqCount` (int), `counter` (int). No ayah selections are persisted between sessions.

## Key conventions

**RTL page view** — `QuranViewerScreen` uses `PageView` with `reverse: true`. Page numbers are `index + 1`; `_goToPage(n)` calls `jumpToPage(n - 1)`. Pages 1 and 2 (Al-Fatiha / start of Al-Baqara) get a special centered layout via `_SpecialPageContent`; all others use `_LinesContainer` which renders justified RTL `Text.rich`.

**Arabic text** — always use `fontFamily: 'ScheherazadeNew'` (Uthmani script font bundled in `assets/fonts/`). Wrap Arabic text widgets in `Directionality(textDirection: TextDirection.rtl, ...)`.

**Primary color** — `Color(0xFF2E7D5E)` (green). Used for interactive highlights, selected state, and CTA buttons throughout.

**Goal banner** — `goalReached` in `AppState` is a transient UI flag, not a permanent state. It flips to `true` only when `counter == sanaqCount` for the first time, auto-dismisses after 3 seconds, and can be dismissed manually via `dismissGoal()`. Counting beyond the goal never re-shows the banner.

**Surah name mapping** — `_surahPages` in `quran_viewer_screen.dart` is a compile-time list of 114 entries mapping surah number → Arabic name, Kazakh transliteration, and starting mushaf page. Used by the surah picker bottom sheet and for Kazakh display in page headers.
