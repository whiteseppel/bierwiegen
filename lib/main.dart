import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/account/account_providers.dart';
import 'features/account/profile_repository.dart';
import 'features/history/game_history_provider.dart';
import 'features/history/game_repository.dart';
import 'features/persistence/app_database.dart';
import 'features/persistence/persistence_providers.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final database = await openAppDatabase();
  final games = await GameRepository(database).loadAll();
  final profileName = await ProfileRepository(database).loadName();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        gameHistoryProvider.overrideWith(
          (ref) =>
              GameHistoryNotifier(ref.watch(gameRepositoryProvider), games),
        ),
        profileNameProvider.overrideWith(
          (ref) => ProfileNameNotifier(
            ref.watch(profileRepositoryProvider),
            profileName,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
