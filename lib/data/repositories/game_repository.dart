import 'package:drift/drift.dart';
import '../database/database.dart';

class GameRepository {
  final AppDatabase db;

  GameRepository(this.db);

  Stream<PlayerProfile> watchPlayerProfile() {
    return (db.select(db.playerProfiles)..where((tbl) => tbl.id.equals(1))).watchSingle();
  }

  Future<PlayerProfile> getPlayerProfile() async {
    final list = await (db.select(db.playerProfiles)..where((tbl) => tbl.id.equals(1))).get();
    if (list.isNotEmpty) return list.first;
    // En caso de que aún no exista, se crea
    final id = await db.into(db.playerProfiles).insert(
      PlayerProfilesCompanion.insert(playerName: const Value('Héroe')),
    );
    return (await (db.select(db.playerProfiles)..where((tbl) => tbl.id.equals(id))).get()).first;
  }

  Stream<List<PermanentUpgrade>> watchUpgrades() {
    return db.select(db.permanentUpgrades).watch();
  }

  Future<List<PermanentUpgrade>> getUpgrades() {
    return db.select(db.permanentUpgrades).get();
  }

  Future<bool> purchaseUpgrade(PermanentUpgrade upgrade) async {
    final profile = await getPlayerProfile();
    final cost = (upgrade.baseCost * (upgrade.currentLevel == 0 ? 1 : (upgrade.costMultiplier * upgrade.currentLevel))).round();

    if (profile.goldCoins < cost || upgrade.currentLevel >= upgrade.maxLevel) {
      return false;
    }

    return db.transaction(() async {
      // Restar monedas
      await (db.update(db.playerProfiles)..where((tbl) => tbl.id.equals(1))).write(
        PlayerProfilesCompanion(
          goldCoins: Value(profile.goldCoins - cost),
        ),
      );

      // Aumentar nivel de la mejora
      await (db.update(db.permanentUpgrades)..where((tbl) => tbl.upgradeId.equals(upgrade.upgradeId))).write(
        PermanentUpgradesCompanion(
          currentLevel: Value(upgrade.currentLevel + 1),
        ),
      );

      return true;
    });
  }

  Future<void> saveRunResult({
    required int score,
    required int survivedSeconds,
    required int enemiesSlain,
    required int goldEarned,
    required int waveReached,
  }) async {
    final profile = await getPlayerProfile();

    await db.transaction(() async {
      // Registrar en el historial local
      await db.into(db.runHistories).insert(
        RunHistoriesCompanion.insert(
          score: score,
          survivedSeconds: survivedSeconds,
          enemiesSlain: enemiesSlain,
          goldEarned: goldEarned,
          waveReached: waveReached,
        ),
      );

      // Sumar oro y estadísticas al perfil permanente
      await (db.update(db.playerProfiles)..where((tbl) => tbl.id.equals(1))).write(
        PlayerProfilesCompanion(
          goldCoins: Value(profile.goldCoins + goldEarned),
          totalKills: Value(profile.totalKills + enemiesSlain),
          totalRuns: Value(profile.totalRuns + 1),
          totalTimePlayedSeconds: Value(profile.totalTimePlayedSeconds + survivedSeconds),
          lastLogin: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<List<RunHistory>> getHighScores() async {
    return (db.select(db.runHistories)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.score)])
      ..limit(10)).get();
  }

  Stream<GameSettingsTableData> watchSettings() {
    return (db.select(db.gameSettingsTable)..where((tbl) => tbl.id.equals(1))).watchSingle();
  }

  Future<GameSettingsTableData> getSettings() async {
    final list = await (db.select(db.gameSettingsTable)..where((tbl) => tbl.id.equals(1))).get();
    if (list.isNotEmpty) return list.first;
    await db.into(db.gameSettingsTable).insert(const GameSettingsTableCompanion(id: Value(1)));
    return (await (db.select(db.gameSettingsTable)..where((tbl) => tbl.id.equals(1))).get()).first;
  }

  Future<void> setLeftHanded(bool isLeftHanded) async {
    await (db.update(db.gameSettingsTable)..where((tbl) => tbl.id.equals(1))).write(
      GameSettingsTableCompanion(
        isLeftHanded: Value(isLeftHanded),
      ),
    );
  }

  Future<void> setMusicVolume(double volume) async {
    await (db.update(db.gameSettingsTable)..where((tbl) => tbl.id.equals(1))).write(
      GameSettingsTableCompanion(
        musicVolume: Value(volume),
      ),
    );
  }

  Future<void> setSfxVolume(double volume) async {
    await (db.update(db.gameSettingsTable)..where((tbl) => tbl.id.equals(1))).write(
      GameSettingsTableCompanion(
        sfxVolume: Value(volume),
      ),
    );
  }

  Future<void> setDifficultyMode(String mode) async {
    await (db.update(db.gameSettingsTable)..where((tbl) => tbl.id.equals(1))).write(
      GameSettingsTableCompanion(
        difficultyMode: Value(mode),
      ),
    );
  }
}
