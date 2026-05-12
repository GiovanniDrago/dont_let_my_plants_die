import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main/main_screen.dart';
import 'screens/onboarding/location_setup_screen.dart';
import 'services/cache_service.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Don\'t Let My Plants Die',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('it'),
      ],
      locale: locale,
      theme: FlexThemeData.light(
        scheme: FlexScheme.green,
        useMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.green,
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: FutureBuilder<bool>(
        future: CacheService.hasMainLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final hasLocation = snapshot.data ?? false;
          if (!hasLocation) {
            return const LocationSetupScreen();
          }
          return const MainScreen();
        },
      ),
    );
  }
}
