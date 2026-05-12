# Don't Let My Plants Die

A Flutter Android application that delivers weather forecasts and lets you configure alarms and memo notes based on weather conditions. Perfect for keeping your plants (and yourself) happy.

## Features

- **Weather Forecasts**: Hourly and daily forecasts powered by [Open-Meteo](https://open-meteo.com/)
- **Location Search**: City search with autocomplete using Open-Meteo geocoding
- **Interactive Map**: Draw custom areas on an EU-focused map to get localized weather
- **Weather Alarms**: Set notifications for specific weather conditions (e.g., notify me 2 hours before it reaches 24°C in Collegno)
- **Background Sync**: Alarms are evaluated every 3 hours with local caching
- **Themes**: Light and dark themes via `flex_color_scheme`
- **Localization**: English and Italian support

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
- Android SDK / Android Studio
- A physical device or emulator

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Build release APK

```bash
flutter build apk --release
```

## Release workflow

This project includes a tag-driven GitHub Actions workflow that builds a signed release APK.

### Required GitHub secrets

- `KEYSTORE_BASE64` — Base64-encoded Android release keystore
- `KEYSTORE_PASSWORD` — Keystore password
- `KEY_PASSWORD` — Key password
- `KEY_ALIAS` — Key alias

### Creating a release

```bash
./scripts/tag-release.sh v1.0.0
```

Pushing the tag triggers the workflow, which publishes the APK as a GitHub Release asset.

## Project structure

```
lib/
├── main.dart
├── app.dart
├── models/           # Data models (Location, Weather, Alarm, MapArea)
├── providers/        # Riverpod state providers
├── services/         # API, cache, notifications, background tasks
├── screens/          # UI screens
├── widgets/          # Reusable widgets
└── l10n/             # Localization ARB files
```

## License

This project is open source. See [LICENSE](LICENSE) for details.
