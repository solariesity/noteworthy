# Noteworthy（词弦）

A dual-module lightweight learning tool that turns idle moments into active learning. Build vocabulary through random flashcard encounters and train your ear by identifying randomly generated chords — all in sessions as short as 30 seconds.

**Noteworthy** is a deliberate double entendre: **note** refers both to a lexical entry worth remembering and a musical tone worth hearing. The suffix **-worthy** signals that every encounter — word or chord — is deserving of your attention.

## Modules

| Module | Name | Experience |
|--------|------|------------|
| 词 | Word | Random flashcards with definitions, examples, root analysis, and collocations |
| 弦 | Chord | Listen to a randomly generated chord and identify its quality from 12 types |

## Design Principles

- **Lightweight** — No curriculum, no progress pressure. Open, practice, close.
- **Random** — Every encounter is unpredictable, keeping curiosity alive.
- **Fragment-friendly** — Sessions as short as 30 seconds fit any gap in your day.
- **Active** — Random exposure is the entry point; recognition and thinking are the core.
- **Unified** — Two domains, one interaction rhythm.

## Tech Stack

- **Flutter** (Windows + Android + Web) — Single codebase, native performance
- **Provider** — Lightweight state management
- **MIDI synthesis** — Windows via win32 FFI, Android via MethodChannel, web via noop stub
- **Material 3** — Clean card-based UI with custom theme

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.5
- Android SDK (for Android builds)
- Visual Studio 2022 with Desktop C++ (for Windows builds)
- Windows Developer Mode enabled (for Windows native plugin builds)

### Run

```bash
# Install dependencies
flutter pub get

# Run on web (both modules work; MIDI is silent on web)
flutter run -d chrome

# Run on Windows (full MIDI support)
flutter run -d windows

# Run on Android (full MIDI support)
flutter run -d <android-device-id>
```

### Analyze

```bash
flutter analyze
```

## English Description

Noteworthy is a dual-module micro-learning application built with Flutter, designed for spontaneous, fragment-friendly study sessions. The Word module presents randomly selected vocabulary flashcards enriched with definitions, example sentences, root analysis, and collocations — enabling incidental acquisition through repeated exposure. The Chord module randomly generates chords spanning twelve chord types, plays them via MIDI synthesis, and challenges users to identify the chord quality by ear. Both modules share a unified interaction pattern — random input triggers active recognition — turning otherwise idle moments into deliberate practice. Lightweight, curriculum-free, and intentionally unpredictable, Noteworthy transforms learning from a scheduled task into a natural daily ritual.
