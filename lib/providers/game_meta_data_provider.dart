import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_meta_data.dart';
import '../widgets/confetti_widget.dart';

class GameMetaDataNotifier extends StateNotifier<GameMetaData?> {
  GameMetaDataNotifier(this.ref) : super(null) {
    // ref.listen<List<Player>>(playerProvider, (previous, next) {
    //   _updateScores(next, ref.read(gameRoundProvider));
    // });
    //
    // ref.listen<List<GameRound>>(gameRoundProvider, (previous, next) {
    //   _updateScores(ref.read(playerProvider), next);
    // });
  }

  void createNewGame() {
    final GameMetaData meta = GameMetaData(createdAt: DateTime.now());
    state = meta;
  }

  void finishGame() {
    final GameMetaData? meta = state?.copyWith(finishedAt: DateTime.now());

    if (meta == null) {
      print('');
      return;
    }

    WinnerConfetti.globalKey.currentState?.playConfetti();

    state = meta;
  }

  final Ref ref;

  updateMetaData(GameMetaData meta) {
    state = meta;
  }

  void forceRefresh() {
    state = state;
  }
}

final gameMetaDataProvider =
    StateNotifierProvider<GameMetaDataNotifier, GameMetaData?>(
      (ref) => GameMetaDataNotifier(ref),
    );
