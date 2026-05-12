import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/background_service.dart';
import 'services/cache_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await CacheService.init();
  await NotificationService.init();
  await BackgroundService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
