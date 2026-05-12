import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class WeatherConditionHelper {
  static (IconData, String) getWeatherInfo(BuildContext context, int wmoCode) {
    final l10n = AppLocalizations.of(context)!;
    switch (wmoCode) {
      case 0:
        return (Icons.wb_sunny, l10n.sunny);
      case 1:
      case 2:
        return (Icons.wb_cloudy, l10n.partlyCloudy);
      case 3:
        return (Icons.cloud, l10n.cloudy);
      case 45:
      case 48:
        return (Icons.foggy, l10n.foggy);
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return (Icons.water_drop, l10n.rainy);
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return (Icons.ac_unit, l10n.snowy);
      case 95:
        return (Icons.thunderstorm, l10n.thunderstorm);
      case 96:
      case 99:
        return (Icons.flash_on, l10n.hail);
      default:
        return (Icons.cloud, l10n.cloudy);
    }
  }
}
