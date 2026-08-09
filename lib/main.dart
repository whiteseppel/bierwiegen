import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'features/account/account_providers.dart';
import 'features/account/profile_color.dart';
import 'features/account/profile_repository.dart';
import 'features/history/game_history_provider.dart';
import 'features/history/game_repository.dart';
import 'features/persistence/app_database.dart';
import 'features/persistence/persistence_providers.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('de_DE');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final database = await openAppDatabase();
  final games = await GameRepository(database).loadAll();
  final profileRepository = ProfileRepository(database);
  final profileName = await profileRepository.loadName();
  final profileColor = await profileRepository.loadColor();

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
        profileColorProvider.overrideWith(
          (ref) => ProfileColorNotifier(
            ref.watch(profileRepositoryProvider),
            ProfileColor.fromId(profileColor),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
