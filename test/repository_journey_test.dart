import 'package:flutter_test/flutter_test.dart';
import 'package:juego/data/database/database.dart';
import 'package:juego/data/repositories/game_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameRepository & Journey Mode Tests', () {
    late AppDatabase db;
    late GameRepository repo;

    setUp(() {
      db = AppDatabase.forTesting();
      repo = GameRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('saveRunResult con isVictory=false guarda estadísticas sin avanzar etapa', () async {
      final initialProfile = await repo.getPlayerProfile();
      expect(initialProfile.journeyStage, equals(1));
      expect(initialProfile.goldCoins, equals(0));

      await repo.saveRunResult(
        score: 1500,
        survivedSeconds: 120,
        enemiesSlain: 45,
        goldEarned: 50,
        waveReached: 3,
        isVictory: false,
      );

      final updatedProfile = await repo.getPlayerProfile();
      expect(updatedProfile.journeyStage, equals(1)); // No avanza
      expect(updatedProfile.goldCoins, equals(50));
      expect(updatedProfile.totalKills, equals(45));
      expect(updatedProfile.totalRuns, equals(1));
      expect(updatedProfile.completedRuns, equals(0));

      final history = await repo.getHighScores();
      expect(history.length, equals(1));
      expect(history.first.score, equals(1500));
    });

    test('saveRunResult con isVictory=true avanza etapa y suma victorias atómicamente', () async {
      await repo.saveRunResult(
        score: 3000,
        survivedSeconds: 180,
        enemiesSlain: 110,
        goldEarned: 350,
        waveReached: 4,
        isVictory: true,
      );

      final updatedProfile = await repo.getPlayerProfile();
      expect(updatedProfile.journeyStage, equals(2)); // Avanza etapa
      expect(updatedProfile.completedRuns, equals(1)); // Suma victoria
      expect(updatedProfile.goldCoins, equals(350));
      expect(updatedProfile.totalKills, equals(110));
    });
  });
}
