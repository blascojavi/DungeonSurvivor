import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// --- TABLAS DE LA BASE DE DATOS LOCAL ---

class PlayerProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playerName => text().withDefault(const Constant('Héroe'))();
  IntColumn get goldCoins => integer().withDefault(const Constant(0))();
  IntColumn get gems => integer().withDefault(const Constant(0))();
  IntColumn get totalKills => integer().withDefault(const Constant(0))();
  IntColumn get totalRuns => integer().withDefault(const Constant(0))();
  IntColumn get totalTimePlayedSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastLogin => dateTime().withDefault(currentDateAndTime)();
}

class PermanentUpgrades extends Table {
  TextColumn get upgradeId => text()(); // ej: 'max_hp', 'attack_speed', 'gold_magnet'
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get currentLevel => integer().withDefault(const Constant(0))();
  IntColumn get maxLevel => integer().withDefault(const Constant(10))();
  IntColumn get baseCost => integer()();
  RealColumn get costMultiplier => real().withDefault(const Constant(1.5))();
  RealColumn get bonusPerLevel => real()();

  @override
  Set<Column> get primaryKey => {upgradeId};
}

class RunHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get score => integer()();
  IntColumn get survivedSeconds => integer()();
  IntColumn get enemiesSlain => integer()();
  IntColumn get goldEarned => integer()();
  IntColumn get waveReached => integer()();
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
}

class GameSettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  RealColumn get musicVolume => real().withDefault(const Constant(0.7))();
  RealColumn get sfxVolume => real().withDefault(const Constant(0.9))();
  BoolColumn get hapticsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get damageNumbers => boolean().withDefault(const Constant(true))();
  TextColumn get languageCode => text().withDefault(const Constant('es'))();
  BoolColumn get isLeftHanded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [PlayerProfiles, PermanentUpgrades, RunHistories, GameSettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting([QueryExecutor? executor]) : super(executor ?? NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insertar valores iniciales por defecto
        await into(playerProfiles).insert(
          PlayerProfilesCompanion.insert(
            playerName: const Value('Héroe'),
            goldCoins: const Value(0),
          ),
        );
        
        await into(gameSettingsTable).insert(
          const GameSettingsTableCompanion(id: Value(1)),
        );

        // Inicializar mejoras permanentes disponibles en la tienda
        await into(permanentUpgrades).insert(
          PermanentUpgradesCompanion.insert(
            upgradeId: 'max_hp',
            name: 'Vitalidad Titánica',
            description: '+10% de salud máxima por nivel',
            baseCost: 100,
            bonusPerLevel: 0.10,
          ),
        );
        await into(permanentUpgrades).insert(
          PermanentUpgradesCompanion.insert(
            upgradeId: 'attack_power',
            name: 'Fuerza Arcana',
            description: '+8% de daño infligido por nivel',
            baseCost: 150,
            bonusPerLevel: 0.08,
          ),
        );
        await into(permanentUpgrades).insert(
          PermanentUpgradesCompanion.insert(
            upgradeId: 'move_speed',
            name: 'Pies Alados',
            description: '+5% de velocidad de movimiento por nivel',
            baseCost: 120,
            bonusPerLevel: 0.05,
          ),
        );
        await into(permanentUpgrades).insert(
          PermanentUpgradesCompanion.insert(
            upgradeId: 'magnet_radius',
            name: 'Magnetismo Áureo',
            description: '+15% de radio de absorción de gemas y oro',
            baseCost: 80,
            bonusPerLevel: 0.15,
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(gameSettingsTable, gameSettingsTable.isLeftHanded);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dungeon_game.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
