import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/persistence_providers.dart';
import 'profile_color.dart';
import 'profile_repository.dart';

/// The player's display name shown on the account screen. Backed by
/// [ProfileRepository]; the initial value is loaded at startup and seeded via an
/// override in `main`.
class ProfileNameNotifier extends StateNotifier<String> {
  ProfileNameNotifier(this._repo, String initial) : super(initial);

  final ProfileRepository _repo;

  void setName(String name) {
    state = name;
    _repo.saveName(name);
  }
}

final profileNameProvider = StateNotifierProvider<ProfileNameNotifier, String>(
  (ref) => ProfileNameNotifier(ref.watch(profileRepositoryProvider), ''),
);

/// The player's chosen avatar color. Backed by [ProfileRepository]; the initial
/// value is loaded at startup and seeded via an override in `main`.
class ProfileColorNotifier extends StateNotifier<ProfileColor> {
  ProfileColorNotifier(this._repo, ProfileColor initial) : super(initial);

  final ProfileRepository _repo;

  void setColor(ProfileColor color) {
    state = color;
    _repo.saveColor(color.id);
  }
}

final profileColorProvider =
    StateNotifierProvider<ProfileColorNotifier, ProfileColor>(
      (ref) => ProfileColorNotifier(
        ref.watch(profileRepositoryProvider),
        ProfileColor.amber,
      ),
    );
