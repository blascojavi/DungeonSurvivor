// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayerProfilesTable extends PlayerProfiles
    with TableInfo<$PlayerProfilesTable, PlayerProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playerNameMeta = const VerificationMeta(
    'playerName',
  );
  @override
  late final GeneratedColumn<String> playerName = GeneratedColumn<String>(
    'player_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Héroe'),
  );
  static const VerificationMeta _goldCoinsMeta = const VerificationMeta(
    'goldCoins',
  );
  @override
  late final GeneratedColumn<int> goldCoins = GeneratedColumn<int>(
    'gold_coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gemsMeta = const VerificationMeta('gems');
  @override
  late final GeneratedColumn<int> gems = GeneratedColumn<int>(
    'gems',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalKillsMeta = const VerificationMeta(
    'totalKills',
  );
  @override
  late final GeneratedColumn<int> totalKills = GeneratedColumn<int>(
    'total_kills',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalRunsMeta = const VerificationMeta(
    'totalRuns',
  );
  @override
  late final GeneratedColumn<int> totalRuns = GeneratedColumn<int>(
    'total_runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalTimePlayedSecondsMeta =
      const VerificationMeta('totalTimePlayedSeconds');
  @override
  late final GeneratedColumn<int> totalTimePlayedSeconds = GeneratedColumn<int>(
    'total_time_played_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastLoginMeta = const VerificationMeta(
    'lastLogin',
  );
  @override
  late final GeneratedColumn<DateTime> lastLogin = GeneratedColumn<DateTime>(
    'last_login',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playerName,
    goldCoins,
    gems,
    totalKills,
    totalRuns,
    totalTimePlayedSeconds,
    createdAt,
    lastLogin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player_name')) {
      context.handle(
        _playerNameMeta,
        playerName.isAcceptableOrUnknown(data['player_name']!, _playerNameMeta),
      );
    }
    if (data.containsKey('gold_coins')) {
      context.handle(
        _goldCoinsMeta,
        goldCoins.isAcceptableOrUnknown(data['gold_coins']!, _goldCoinsMeta),
      );
    }
    if (data.containsKey('gems')) {
      context.handle(
        _gemsMeta,
        gems.isAcceptableOrUnknown(data['gems']!, _gemsMeta),
      );
    }
    if (data.containsKey('total_kills')) {
      context.handle(
        _totalKillsMeta,
        totalKills.isAcceptableOrUnknown(data['total_kills']!, _totalKillsMeta),
      );
    }
    if (data.containsKey('total_runs')) {
      context.handle(
        _totalRunsMeta,
        totalRuns.isAcceptableOrUnknown(data['total_runs']!, _totalRunsMeta),
      );
    }
    if (data.containsKey('total_time_played_seconds')) {
      context.handle(
        _totalTimePlayedSecondsMeta,
        totalTimePlayedSeconds.isAcceptableOrUnknown(
          data['total_time_played_seconds']!,
          _totalTimePlayedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_login')) {
      context.handle(
        _lastLoginMeta,
        lastLogin.isAcceptableOrUnknown(data['last_login']!, _lastLoginMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_name'],
      )!,
      goldCoins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gold_coins'],
      )!,
      gems: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gems'],
      )!,
      totalKills: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_kills'],
      )!,
      totalRuns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_runs'],
      )!,
      totalTimePlayedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_time_played_seconds'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastLogin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login'],
      )!,
    );
  }

  @override
  $PlayerProfilesTable createAlias(String alias) {
    return $PlayerProfilesTable(attachedDatabase, alias);
  }
}

class PlayerProfile extends DataClass implements Insertable<PlayerProfile> {
  final int id;
  final String playerName;
  final int goldCoins;
  final int gems;
  final int totalKills;
  final int totalRuns;
  final int totalTimePlayedSeconds;
  final DateTime createdAt;
  final DateTime lastLogin;
  const PlayerProfile({
    required this.id,
    required this.playerName,
    required this.goldCoins,
    required this.gems,
    required this.totalKills,
    required this.totalRuns,
    required this.totalTimePlayedSeconds,
    required this.createdAt,
    required this.lastLogin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['player_name'] = Variable<String>(playerName);
    map['gold_coins'] = Variable<int>(goldCoins);
    map['gems'] = Variable<int>(gems);
    map['total_kills'] = Variable<int>(totalKills);
    map['total_runs'] = Variable<int>(totalRuns);
    map['total_time_played_seconds'] = Variable<int>(totalTimePlayedSeconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_login'] = Variable<DateTime>(lastLogin);
    return map;
  }

  PlayerProfilesCompanion toCompanion(bool nullToAbsent) {
    return PlayerProfilesCompanion(
      id: Value(id),
      playerName: Value(playerName),
      goldCoins: Value(goldCoins),
      gems: Value(gems),
      totalKills: Value(totalKills),
      totalRuns: Value(totalRuns),
      totalTimePlayedSeconds: Value(totalTimePlayedSeconds),
      createdAt: Value(createdAt),
      lastLogin: Value(lastLogin),
    );
  }

  factory PlayerProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerProfile(
      id: serializer.fromJson<int>(json['id']),
      playerName: serializer.fromJson<String>(json['playerName']),
      goldCoins: serializer.fromJson<int>(json['goldCoins']),
      gems: serializer.fromJson<int>(json['gems']),
      totalKills: serializer.fromJson<int>(json['totalKills']),
      totalRuns: serializer.fromJson<int>(json['totalRuns']),
      totalTimePlayedSeconds: serializer.fromJson<int>(
        json['totalTimePlayedSeconds'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastLogin: serializer.fromJson<DateTime>(json['lastLogin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playerName': serializer.toJson<String>(playerName),
      'goldCoins': serializer.toJson<int>(goldCoins),
      'gems': serializer.toJson<int>(gems),
      'totalKills': serializer.toJson<int>(totalKills),
      'totalRuns': serializer.toJson<int>(totalRuns),
      'totalTimePlayedSeconds': serializer.toJson<int>(totalTimePlayedSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastLogin': serializer.toJson<DateTime>(lastLogin),
    };
  }

  PlayerProfile copyWith({
    int? id,
    String? playerName,
    int? goldCoins,
    int? gems,
    int? totalKills,
    int? totalRuns,
    int? totalTimePlayedSeconds,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) => PlayerProfile(
    id: id ?? this.id,
    playerName: playerName ?? this.playerName,
    goldCoins: goldCoins ?? this.goldCoins,
    gems: gems ?? this.gems,
    totalKills: totalKills ?? this.totalKills,
    totalRuns: totalRuns ?? this.totalRuns,
    totalTimePlayedSeconds:
        totalTimePlayedSeconds ?? this.totalTimePlayedSeconds,
    createdAt: createdAt ?? this.createdAt,
    lastLogin: lastLogin ?? this.lastLogin,
  );
  PlayerProfile copyWithCompanion(PlayerProfilesCompanion data) {
    return PlayerProfile(
      id: data.id.present ? data.id.value : this.id,
      playerName: data.playerName.present
          ? data.playerName.value
          : this.playerName,
      goldCoins: data.goldCoins.present ? data.goldCoins.value : this.goldCoins,
      gems: data.gems.present ? data.gems.value : this.gems,
      totalKills: data.totalKills.present
          ? data.totalKills.value
          : this.totalKills,
      totalRuns: data.totalRuns.present ? data.totalRuns.value : this.totalRuns,
      totalTimePlayedSeconds: data.totalTimePlayedSeconds.present
          ? data.totalTimePlayedSeconds.value
          : this.totalTimePlayedSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastLogin: data.lastLogin.present ? data.lastLogin.value : this.lastLogin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfile(')
          ..write('id: $id, ')
          ..write('playerName: $playerName, ')
          ..write('goldCoins: $goldCoins, ')
          ..write('gems: $gems, ')
          ..write('totalKills: $totalKills, ')
          ..write('totalRuns: $totalRuns, ')
          ..write('totalTimePlayedSeconds: $totalTimePlayedSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLogin: $lastLogin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    playerName,
    goldCoins,
    gems,
    totalKills,
    totalRuns,
    totalTimePlayedSeconds,
    createdAt,
    lastLogin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerProfile &&
          other.id == this.id &&
          other.playerName == this.playerName &&
          other.goldCoins == this.goldCoins &&
          other.gems == this.gems &&
          other.totalKills == this.totalKills &&
          other.totalRuns == this.totalRuns &&
          other.totalTimePlayedSeconds == this.totalTimePlayedSeconds &&
          other.createdAt == this.createdAt &&
          other.lastLogin == this.lastLogin);
}

class PlayerProfilesCompanion extends UpdateCompanion<PlayerProfile> {
  final Value<int> id;
  final Value<String> playerName;
  final Value<int> goldCoins;
  final Value<int> gems;
  final Value<int> totalKills;
  final Value<int> totalRuns;
  final Value<int> totalTimePlayedSeconds;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastLogin;
  const PlayerProfilesCompanion({
    this.id = const Value.absent(),
    this.playerName = const Value.absent(),
    this.goldCoins = const Value.absent(),
    this.gems = const Value.absent(),
    this.totalKills = const Value.absent(),
    this.totalRuns = const Value.absent(),
    this.totalTimePlayedSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLogin = const Value.absent(),
  });
  PlayerProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.playerName = const Value.absent(),
    this.goldCoins = const Value.absent(),
    this.gems = const Value.absent(),
    this.totalKills = const Value.absent(),
    this.totalRuns = const Value.absent(),
    this.totalTimePlayedSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLogin = const Value.absent(),
  });
  static Insertable<PlayerProfile> custom({
    Expression<int>? id,
    Expression<String>? playerName,
    Expression<int>? goldCoins,
    Expression<int>? gems,
    Expression<int>? totalKills,
    Expression<int>? totalRuns,
    Expression<int>? totalTimePlayedSeconds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastLogin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerName != null) 'player_name': playerName,
      if (goldCoins != null) 'gold_coins': goldCoins,
      if (gems != null) 'gems': gems,
      if (totalKills != null) 'total_kills': totalKills,
      if (totalRuns != null) 'total_runs': totalRuns,
      if (totalTimePlayedSeconds != null)
        'total_time_played_seconds': totalTimePlayedSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (lastLogin != null) 'last_login': lastLogin,
    });
  }

  PlayerProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? playerName,
    Value<int>? goldCoins,
    Value<int>? gems,
    Value<int>? totalKills,
    Value<int>? totalRuns,
    Value<int>? totalTimePlayedSeconds,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastLogin,
  }) {
    return PlayerProfilesCompanion(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      goldCoins: goldCoins ?? this.goldCoins,
      gems: gems ?? this.gems,
      totalKills: totalKills ?? this.totalKills,
      totalRuns: totalRuns ?? this.totalRuns,
      totalTimePlayedSeconds:
          totalTimePlayedSeconds ?? this.totalTimePlayedSeconds,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playerName.present) {
      map['player_name'] = Variable<String>(playerName.value);
    }
    if (goldCoins.present) {
      map['gold_coins'] = Variable<int>(goldCoins.value);
    }
    if (gems.present) {
      map['gems'] = Variable<int>(gems.value);
    }
    if (totalKills.present) {
      map['total_kills'] = Variable<int>(totalKills.value);
    }
    if (totalRuns.present) {
      map['total_runs'] = Variable<int>(totalRuns.value);
    }
    if (totalTimePlayedSeconds.present) {
      map['total_time_played_seconds'] = Variable<int>(
        totalTimePlayedSeconds.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastLogin.present) {
      map['last_login'] = Variable<DateTime>(lastLogin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfilesCompanion(')
          ..write('id: $id, ')
          ..write('playerName: $playerName, ')
          ..write('goldCoins: $goldCoins, ')
          ..write('gems: $gems, ')
          ..write('totalKills: $totalKills, ')
          ..write('totalRuns: $totalRuns, ')
          ..write('totalTimePlayedSeconds: $totalTimePlayedSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLogin: $lastLogin')
          ..write(')'))
        .toString();
  }
}

class $PermanentUpgradesTable extends PermanentUpgrades
    with TableInfo<$PermanentUpgradesTable, PermanentUpgrade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PermanentUpgradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _upgradeIdMeta = const VerificationMeta(
    'upgradeId',
  );
  @override
  late final GeneratedColumn<String> upgradeId = GeneratedColumn<String>(
    'upgrade_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentLevelMeta = const VerificationMeta(
    'currentLevel',
  );
  @override
  late final GeneratedColumn<int> currentLevel = GeneratedColumn<int>(
    'current_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxLevelMeta = const VerificationMeta(
    'maxLevel',
  );
  @override
  late final GeneratedColumn<int> maxLevel = GeneratedColumn<int>(
    'max_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _baseCostMeta = const VerificationMeta(
    'baseCost',
  );
  @override
  late final GeneratedColumn<int> baseCost = GeneratedColumn<int>(
    'base_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMultiplierMeta = const VerificationMeta(
    'costMultiplier',
  );
  @override
  late final GeneratedColumn<double> costMultiplier = GeneratedColumn<double>(
    'cost_multiplier',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.5),
  );
  static const VerificationMeta _bonusPerLevelMeta = const VerificationMeta(
    'bonusPerLevel',
  );
  @override
  late final GeneratedColumn<double> bonusPerLevel = GeneratedColumn<double>(
    'bonus_per_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    upgradeId,
    name,
    description,
    currentLevel,
    maxLevel,
    baseCost,
    costMultiplier,
    bonusPerLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'permanent_upgrades';
  @override
  VerificationContext validateIntegrity(
    Insertable<PermanentUpgrade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('upgrade_id')) {
      context.handle(
        _upgradeIdMeta,
        upgradeId.isAcceptableOrUnknown(data['upgrade_id']!, _upgradeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_upgradeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('current_level')) {
      context.handle(
        _currentLevelMeta,
        currentLevel.isAcceptableOrUnknown(
          data['current_level']!,
          _currentLevelMeta,
        ),
      );
    }
    if (data.containsKey('max_level')) {
      context.handle(
        _maxLevelMeta,
        maxLevel.isAcceptableOrUnknown(data['max_level']!, _maxLevelMeta),
      );
    }
    if (data.containsKey('base_cost')) {
      context.handle(
        _baseCostMeta,
        baseCost.isAcceptableOrUnknown(data['base_cost']!, _baseCostMeta),
      );
    } else if (isInserting) {
      context.missing(_baseCostMeta);
    }
    if (data.containsKey('cost_multiplier')) {
      context.handle(
        _costMultiplierMeta,
        costMultiplier.isAcceptableOrUnknown(
          data['cost_multiplier']!,
          _costMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('bonus_per_level')) {
      context.handle(
        _bonusPerLevelMeta,
        bonusPerLevel.isAcceptableOrUnknown(
          data['bonus_per_level']!,
          _bonusPerLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bonusPerLevelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {upgradeId};
  @override
  PermanentUpgrade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PermanentUpgrade(
      upgradeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upgrade_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      currentLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_level'],
      )!,
      maxLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_level'],
      )!,
      baseCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_cost'],
      )!,
      costMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_multiplier'],
      )!,
      bonusPerLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bonus_per_level'],
      )!,
    );
  }

  @override
  $PermanentUpgradesTable createAlias(String alias) {
    return $PermanentUpgradesTable(attachedDatabase, alias);
  }
}

class PermanentUpgrade extends DataClass
    implements Insertable<PermanentUpgrade> {
  final String upgradeId;
  final String name;
  final String description;
  final int currentLevel;
  final int maxLevel;
  final int baseCost;
  final double costMultiplier;
  final double bonusPerLevel;
  const PermanentUpgrade({
    required this.upgradeId,
    required this.name,
    required this.description,
    required this.currentLevel,
    required this.maxLevel,
    required this.baseCost,
    required this.costMultiplier,
    required this.bonusPerLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['upgrade_id'] = Variable<String>(upgradeId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['current_level'] = Variable<int>(currentLevel);
    map['max_level'] = Variable<int>(maxLevel);
    map['base_cost'] = Variable<int>(baseCost);
    map['cost_multiplier'] = Variable<double>(costMultiplier);
    map['bonus_per_level'] = Variable<double>(bonusPerLevel);
    return map;
  }

  PermanentUpgradesCompanion toCompanion(bool nullToAbsent) {
    return PermanentUpgradesCompanion(
      upgradeId: Value(upgradeId),
      name: Value(name),
      description: Value(description),
      currentLevel: Value(currentLevel),
      maxLevel: Value(maxLevel),
      baseCost: Value(baseCost),
      costMultiplier: Value(costMultiplier),
      bonusPerLevel: Value(bonusPerLevel),
    );
  }

  factory PermanentUpgrade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PermanentUpgrade(
      upgradeId: serializer.fromJson<String>(json['upgradeId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      currentLevel: serializer.fromJson<int>(json['currentLevel']),
      maxLevel: serializer.fromJson<int>(json['maxLevel']),
      baseCost: serializer.fromJson<int>(json['baseCost']),
      costMultiplier: serializer.fromJson<double>(json['costMultiplier']),
      bonusPerLevel: serializer.fromJson<double>(json['bonusPerLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'upgradeId': serializer.toJson<String>(upgradeId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'currentLevel': serializer.toJson<int>(currentLevel),
      'maxLevel': serializer.toJson<int>(maxLevel),
      'baseCost': serializer.toJson<int>(baseCost),
      'costMultiplier': serializer.toJson<double>(costMultiplier),
      'bonusPerLevel': serializer.toJson<double>(bonusPerLevel),
    };
  }

  PermanentUpgrade copyWith({
    String? upgradeId,
    String? name,
    String? description,
    int? currentLevel,
    int? maxLevel,
    int? baseCost,
    double? costMultiplier,
    double? bonusPerLevel,
  }) => PermanentUpgrade(
    upgradeId: upgradeId ?? this.upgradeId,
    name: name ?? this.name,
    description: description ?? this.description,
    currentLevel: currentLevel ?? this.currentLevel,
    maxLevel: maxLevel ?? this.maxLevel,
    baseCost: baseCost ?? this.baseCost,
    costMultiplier: costMultiplier ?? this.costMultiplier,
    bonusPerLevel: bonusPerLevel ?? this.bonusPerLevel,
  );
  PermanentUpgrade copyWithCompanion(PermanentUpgradesCompanion data) {
    return PermanentUpgrade(
      upgradeId: data.upgradeId.present ? data.upgradeId.value : this.upgradeId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      currentLevel: data.currentLevel.present
          ? data.currentLevel.value
          : this.currentLevel,
      maxLevel: data.maxLevel.present ? data.maxLevel.value : this.maxLevel,
      baseCost: data.baseCost.present ? data.baseCost.value : this.baseCost,
      costMultiplier: data.costMultiplier.present
          ? data.costMultiplier.value
          : this.costMultiplier,
      bonusPerLevel: data.bonusPerLevel.present
          ? data.bonusPerLevel.value
          : this.bonusPerLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PermanentUpgrade(')
          ..write('upgradeId: $upgradeId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('baseCost: $baseCost, ')
          ..write('costMultiplier: $costMultiplier, ')
          ..write('bonusPerLevel: $bonusPerLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    upgradeId,
    name,
    description,
    currentLevel,
    maxLevel,
    baseCost,
    costMultiplier,
    bonusPerLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PermanentUpgrade &&
          other.upgradeId == this.upgradeId &&
          other.name == this.name &&
          other.description == this.description &&
          other.currentLevel == this.currentLevel &&
          other.maxLevel == this.maxLevel &&
          other.baseCost == this.baseCost &&
          other.costMultiplier == this.costMultiplier &&
          other.bonusPerLevel == this.bonusPerLevel);
}

class PermanentUpgradesCompanion extends UpdateCompanion<PermanentUpgrade> {
  final Value<String> upgradeId;
  final Value<String> name;
  final Value<String> description;
  final Value<int> currentLevel;
  final Value<int> maxLevel;
  final Value<int> baseCost;
  final Value<double> costMultiplier;
  final Value<double> bonusPerLevel;
  final Value<int> rowid;
  const PermanentUpgradesCompanion({
    this.upgradeId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.currentLevel = const Value.absent(),
    this.maxLevel = const Value.absent(),
    this.baseCost = const Value.absent(),
    this.costMultiplier = const Value.absent(),
    this.bonusPerLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PermanentUpgradesCompanion.insert({
    required String upgradeId,
    required String name,
    required String description,
    this.currentLevel = const Value.absent(),
    this.maxLevel = const Value.absent(),
    required int baseCost,
    this.costMultiplier = const Value.absent(),
    required double bonusPerLevel,
    this.rowid = const Value.absent(),
  }) : upgradeId = Value(upgradeId),
       name = Value(name),
       description = Value(description),
       baseCost = Value(baseCost),
       bonusPerLevel = Value(bonusPerLevel);
  static Insertable<PermanentUpgrade> custom({
    Expression<String>? upgradeId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? currentLevel,
    Expression<int>? maxLevel,
    Expression<int>? baseCost,
    Expression<double>? costMultiplier,
    Expression<double>? bonusPerLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (upgradeId != null) 'upgrade_id': upgradeId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (currentLevel != null) 'current_level': currentLevel,
      if (maxLevel != null) 'max_level': maxLevel,
      if (baseCost != null) 'base_cost': baseCost,
      if (costMultiplier != null) 'cost_multiplier': costMultiplier,
      if (bonusPerLevel != null) 'bonus_per_level': bonusPerLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PermanentUpgradesCompanion copyWith({
    Value<String>? upgradeId,
    Value<String>? name,
    Value<String>? description,
    Value<int>? currentLevel,
    Value<int>? maxLevel,
    Value<int>? baseCost,
    Value<double>? costMultiplier,
    Value<double>? bonusPerLevel,
    Value<int>? rowid,
  }) {
    return PermanentUpgradesCompanion(
      upgradeId: upgradeId ?? this.upgradeId,
      name: name ?? this.name,
      description: description ?? this.description,
      currentLevel: currentLevel ?? this.currentLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      baseCost: baseCost ?? this.baseCost,
      costMultiplier: costMultiplier ?? this.costMultiplier,
      bonusPerLevel: bonusPerLevel ?? this.bonusPerLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (upgradeId.present) {
      map['upgrade_id'] = Variable<String>(upgradeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (currentLevel.present) {
      map['current_level'] = Variable<int>(currentLevel.value);
    }
    if (maxLevel.present) {
      map['max_level'] = Variable<int>(maxLevel.value);
    }
    if (baseCost.present) {
      map['base_cost'] = Variable<int>(baseCost.value);
    }
    if (costMultiplier.present) {
      map['cost_multiplier'] = Variable<double>(costMultiplier.value);
    }
    if (bonusPerLevel.present) {
      map['bonus_per_level'] = Variable<double>(bonusPerLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PermanentUpgradesCompanion(')
          ..write('upgradeId: $upgradeId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('baseCost: $baseCost, ')
          ..write('costMultiplier: $costMultiplier, ')
          ..write('bonusPerLevel: $bonusPerLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunHistoriesTable extends RunHistories
    with TableInfo<$RunHistoriesTable, RunHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _survivedSecondsMeta = const VerificationMeta(
    'survivedSeconds',
  );
  @override
  late final GeneratedColumn<int> survivedSeconds = GeneratedColumn<int>(
    'survived_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enemiesSlainMeta = const VerificationMeta(
    'enemiesSlain',
  );
  @override
  late final GeneratedColumn<int> enemiesSlain = GeneratedColumn<int>(
    'enemies_slain',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goldEarnedMeta = const VerificationMeta(
    'goldEarned',
  );
  @override
  late final GeneratedColumn<int> goldEarned = GeneratedColumn<int>(
    'gold_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waveReachedMeta = const VerificationMeta(
    'waveReached',
  );
  @override
  late final GeneratedColumn<int> waveReached = GeneratedColumn<int>(
    'wave_reached',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    score,
    survivedSeconds,
    enemiesSlain,
    goldEarned,
    waveReached,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('survived_seconds')) {
      context.handle(
        _survivedSecondsMeta,
        survivedSeconds.isAcceptableOrUnknown(
          data['survived_seconds']!,
          _survivedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_survivedSecondsMeta);
    }
    if (data.containsKey('enemies_slain')) {
      context.handle(
        _enemiesSlainMeta,
        enemiesSlain.isAcceptableOrUnknown(
          data['enemies_slain']!,
          _enemiesSlainMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enemiesSlainMeta);
    }
    if (data.containsKey('gold_earned')) {
      context.handle(
        _goldEarnedMeta,
        goldEarned.isAcceptableOrUnknown(data['gold_earned']!, _goldEarnedMeta),
      );
    } else if (isInserting) {
      context.missing(_goldEarnedMeta);
    }
    if (data.containsKey('wave_reached')) {
      context.handle(
        _waveReachedMeta,
        waveReached.isAcceptableOrUnknown(
          data['wave_reached']!,
          _waveReachedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_waveReachedMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      survivedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}survived_seconds'],
      )!,
      enemiesSlain: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enemies_slain'],
      )!,
      goldEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gold_earned'],
      )!,
      waveReached: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wave_reached'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $RunHistoriesTable createAlias(String alias) {
    return $RunHistoriesTable(attachedDatabase, alias);
  }
}

class RunHistory extends DataClass implements Insertable<RunHistory> {
  final int id;
  final int score;
  final int survivedSeconds;
  final int enemiesSlain;
  final int goldEarned;
  final int waveReached;
  final DateTime playedAt;
  const RunHistory({
    required this.id,
    required this.score,
    required this.survivedSeconds,
    required this.enemiesSlain,
    required this.goldEarned,
    required this.waveReached,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['score'] = Variable<int>(score);
    map['survived_seconds'] = Variable<int>(survivedSeconds);
    map['enemies_slain'] = Variable<int>(enemiesSlain);
    map['gold_earned'] = Variable<int>(goldEarned);
    map['wave_reached'] = Variable<int>(waveReached);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  RunHistoriesCompanion toCompanion(bool nullToAbsent) {
    return RunHistoriesCompanion(
      id: Value(id),
      score: Value(score),
      survivedSeconds: Value(survivedSeconds),
      enemiesSlain: Value(enemiesSlain),
      goldEarned: Value(goldEarned),
      waveReached: Value(waveReached),
      playedAt: Value(playedAt),
    );
  }

  factory RunHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunHistory(
      id: serializer.fromJson<int>(json['id']),
      score: serializer.fromJson<int>(json['score']),
      survivedSeconds: serializer.fromJson<int>(json['survivedSeconds']),
      enemiesSlain: serializer.fromJson<int>(json['enemiesSlain']),
      goldEarned: serializer.fromJson<int>(json['goldEarned']),
      waveReached: serializer.fromJson<int>(json['waveReached']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'score': serializer.toJson<int>(score),
      'survivedSeconds': serializer.toJson<int>(survivedSeconds),
      'enemiesSlain': serializer.toJson<int>(enemiesSlain),
      'goldEarned': serializer.toJson<int>(goldEarned),
      'waveReached': serializer.toJson<int>(waveReached),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  RunHistory copyWith({
    int? id,
    int? score,
    int? survivedSeconds,
    int? enemiesSlain,
    int? goldEarned,
    int? waveReached,
    DateTime? playedAt,
  }) => RunHistory(
    id: id ?? this.id,
    score: score ?? this.score,
    survivedSeconds: survivedSeconds ?? this.survivedSeconds,
    enemiesSlain: enemiesSlain ?? this.enemiesSlain,
    goldEarned: goldEarned ?? this.goldEarned,
    waveReached: waveReached ?? this.waveReached,
    playedAt: playedAt ?? this.playedAt,
  );
  RunHistory copyWithCompanion(RunHistoriesCompanion data) {
    return RunHistory(
      id: data.id.present ? data.id.value : this.id,
      score: data.score.present ? data.score.value : this.score,
      survivedSeconds: data.survivedSeconds.present
          ? data.survivedSeconds.value
          : this.survivedSeconds,
      enemiesSlain: data.enemiesSlain.present
          ? data.enemiesSlain.value
          : this.enemiesSlain,
      goldEarned: data.goldEarned.present
          ? data.goldEarned.value
          : this.goldEarned,
      waveReached: data.waveReached.present
          ? data.waveReached.value
          : this.waveReached,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunHistory(')
          ..write('id: $id, ')
          ..write('score: $score, ')
          ..write('survivedSeconds: $survivedSeconds, ')
          ..write('enemiesSlain: $enemiesSlain, ')
          ..write('goldEarned: $goldEarned, ')
          ..write('waveReached: $waveReached, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    score,
    survivedSeconds,
    enemiesSlain,
    goldEarned,
    waveReached,
    playedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunHistory &&
          other.id == this.id &&
          other.score == this.score &&
          other.survivedSeconds == this.survivedSeconds &&
          other.enemiesSlain == this.enemiesSlain &&
          other.goldEarned == this.goldEarned &&
          other.waveReached == this.waveReached &&
          other.playedAt == this.playedAt);
}

class RunHistoriesCompanion extends UpdateCompanion<RunHistory> {
  final Value<int> id;
  final Value<int> score;
  final Value<int> survivedSeconds;
  final Value<int> enemiesSlain;
  final Value<int> goldEarned;
  final Value<int> waveReached;
  final Value<DateTime> playedAt;
  const RunHistoriesCompanion({
    this.id = const Value.absent(),
    this.score = const Value.absent(),
    this.survivedSeconds = const Value.absent(),
    this.enemiesSlain = const Value.absent(),
    this.goldEarned = const Value.absent(),
    this.waveReached = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  RunHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required int score,
    required int survivedSeconds,
    required int enemiesSlain,
    required int goldEarned,
    required int waveReached,
    this.playedAt = const Value.absent(),
  }) : score = Value(score),
       survivedSeconds = Value(survivedSeconds),
       enemiesSlain = Value(enemiesSlain),
       goldEarned = Value(goldEarned),
       waveReached = Value(waveReached);
  static Insertable<RunHistory> custom({
    Expression<int>? id,
    Expression<int>? score,
    Expression<int>? survivedSeconds,
    Expression<int>? enemiesSlain,
    Expression<int>? goldEarned,
    Expression<int>? waveReached,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (score != null) 'score': score,
      if (survivedSeconds != null) 'survived_seconds': survivedSeconds,
      if (enemiesSlain != null) 'enemies_slain': enemiesSlain,
      if (goldEarned != null) 'gold_earned': goldEarned,
      if (waveReached != null) 'wave_reached': waveReached,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  RunHistoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? score,
    Value<int>? survivedSeconds,
    Value<int>? enemiesSlain,
    Value<int>? goldEarned,
    Value<int>? waveReached,
    Value<DateTime>? playedAt,
  }) {
    return RunHistoriesCompanion(
      id: id ?? this.id,
      score: score ?? this.score,
      survivedSeconds: survivedSeconds ?? this.survivedSeconds,
      enemiesSlain: enemiesSlain ?? this.enemiesSlain,
      goldEarned: goldEarned ?? this.goldEarned,
      waveReached: waveReached ?? this.waveReached,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (survivedSeconds.present) {
      map['survived_seconds'] = Variable<int>(survivedSeconds.value);
    }
    if (enemiesSlain.present) {
      map['enemies_slain'] = Variable<int>(enemiesSlain.value);
    }
    if (goldEarned.present) {
      map['gold_earned'] = Variable<int>(goldEarned.value);
    }
    if (waveReached.present) {
      map['wave_reached'] = Variable<int>(waveReached.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('score: $score, ')
          ..write('survivedSeconds: $survivedSeconds, ')
          ..write('enemiesSlain: $enemiesSlain, ')
          ..write('goldEarned: $goldEarned, ')
          ..write('waveReached: $waveReached, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

class $GameSettingsTableTable extends GameSettingsTable
    with TableInfo<$GameSettingsTableTable, GameSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _musicVolumeMeta = const VerificationMeta(
    'musicVolume',
  );
  @override
  late final GeneratedColumn<double> musicVolume = GeneratedColumn<double>(
    'music_volume',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.7),
  );
  static const VerificationMeta _sfxVolumeMeta = const VerificationMeta(
    'sfxVolume',
  );
  @override
  late final GeneratedColumn<double> sfxVolume = GeneratedColumn<double>(
    'sfx_volume',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.9),
  );
  static const VerificationMeta _hapticsEnabledMeta = const VerificationMeta(
    'hapticsEnabled',
  );
  @override
  late final GeneratedColumn<bool> hapticsEnabled = GeneratedColumn<bool>(
    'haptics_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptics_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _damageNumbersMeta = const VerificationMeta(
    'damageNumbers',
  );
  @override
  late final GeneratedColumn<bool> damageNumbers = GeneratedColumn<bool>(
    'damage_numbers',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("damage_numbers" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('es'),
  );
  static const VerificationMeta _isLeftHandedMeta = const VerificationMeta(
    'isLeftHanded',
  );
  @override
  late final GeneratedColumn<bool> isLeftHanded = GeneratedColumn<bool>(
    'is_left_handed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_left_handed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    musicVolume,
    sfxVolume,
    hapticsEnabled,
    damageNumbers,
    languageCode,
    isLeftHanded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('music_volume')) {
      context.handle(
        _musicVolumeMeta,
        musicVolume.isAcceptableOrUnknown(
          data['music_volume']!,
          _musicVolumeMeta,
        ),
      );
    }
    if (data.containsKey('sfx_volume')) {
      context.handle(
        _sfxVolumeMeta,
        sfxVolume.isAcceptableOrUnknown(data['sfx_volume']!, _sfxVolumeMeta),
      );
    }
    if (data.containsKey('haptics_enabled')) {
      context.handle(
        _hapticsEnabledMeta,
        hapticsEnabled.isAcceptableOrUnknown(
          data['haptics_enabled']!,
          _hapticsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('damage_numbers')) {
      context.handle(
        _damageNumbersMeta,
        damageNumbers.isAcceptableOrUnknown(
          data['damage_numbers']!,
          _damageNumbersMeta,
        ),
      );
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('is_left_handed')) {
      context.handle(
        _isLeftHandedMeta,
        isLeftHanded.isAcceptableOrUnknown(
          data['is_left_handed']!,
          _isLeftHandedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      musicVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}music_volume'],
      )!,
      sfxVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sfx_volume'],
      )!,
      hapticsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptics_enabled'],
      )!,
      damageNumbers: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}damage_numbers'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      isLeftHanded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_left_handed'],
      )!,
    );
  }

  @override
  $GameSettingsTableTable createAlias(String alias) {
    return $GameSettingsTableTable(attachedDatabase, alias);
  }
}

class GameSettingsTableData extends DataClass
    implements Insertable<GameSettingsTableData> {
  final int id;
  final double musicVolume;
  final double sfxVolume;
  final bool hapticsEnabled;
  final bool damageNumbers;
  final String languageCode;
  final bool isLeftHanded;
  const GameSettingsTableData({
    required this.id,
    required this.musicVolume,
    required this.sfxVolume,
    required this.hapticsEnabled,
    required this.damageNumbers,
    required this.languageCode,
    required this.isLeftHanded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['music_volume'] = Variable<double>(musicVolume);
    map['sfx_volume'] = Variable<double>(sfxVolume);
    map['haptics_enabled'] = Variable<bool>(hapticsEnabled);
    map['damage_numbers'] = Variable<bool>(damageNumbers);
    map['language_code'] = Variable<String>(languageCode);
    map['is_left_handed'] = Variable<bool>(isLeftHanded);
    return map;
  }

  GameSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return GameSettingsTableCompanion(
      id: Value(id),
      musicVolume: Value(musicVolume),
      sfxVolume: Value(sfxVolume),
      hapticsEnabled: Value(hapticsEnabled),
      damageNumbers: Value(damageNumbers),
      languageCode: Value(languageCode),
      isLeftHanded: Value(isLeftHanded),
    );
  }

  factory GameSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      musicVolume: serializer.fromJson<double>(json['musicVolume']),
      sfxVolume: serializer.fromJson<double>(json['sfxVolume']),
      hapticsEnabled: serializer.fromJson<bool>(json['hapticsEnabled']),
      damageNumbers: serializer.fromJson<bool>(json['damageNumbers']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      isLeftHanded: serializer.fromJson<bool>(json['isLeftHanded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'musicVolume': serializer.toJson<double>(musicVolume),
      'sfxVolume': serializer.toJson<double>(sfxVolume),
      'hapticsEnabled': serializer.toJson<bool>(hapticsEnabled),
      'damageNumbers': serializer.toJson<bool>(damageNumbers),
      'languageCode': serializer.toJson<String>(languageCode),
      'isLeftHanded': serializer.toJson<bool>(isLeftHanded),
    };
  }

  GameSettingsTableData copyWith({
    int? id,
    double? musicVolume,
    double? sfxVolume,
    bool? hapticsEnabled,
    bool? damageNumbers,
    String? languageCode,
    bool? isLeftHanded,
  }) => GameSettingsTableData(
    id: id ?? this.id,
    musicVolume: musicVolume ?? this.musicVolume,
    sfxVolume: sfxVolume ?? this.sfxVolume,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    damageNumbers: damageNumbers ?? this.damageNumbers,
    languageCode: languageCode ?? this.languageCode,
    isLeftHanded: isLeftHanded ?? this.isLeftHanded,
  );
  GameSettingsTableData copyWithCompanion(GameSettingsTableCompanion data) {
    return GameSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      musicVolume: data.musicVolume.present
          ? data.musicVolume.value
          : this.musicVolume,
      sfxVolume: data.sfxVolume.present ? data.sfxVolume.value : this.sfxVolume,
      hapticsEnabled: data.hapticsEnabled.present
          ? data.hapticsEnabled.value
          : this.hapticsEnabled,
      damageNumbers: data.damageNumbers.present
          ? data.damageNumbers.value
          : this.damageNumbers,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      isLeftHanded: data.isLeftHanded.present
          ? data.isLeftHanded.value
          : this.isLeftHanded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSettingsTableData(')
          ..write('id: $id, ')
          ..write('musicVolume: $musicVolume, ')
          ..write('sfxVolume: $sfxVolume, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('damageNumbers: $damageNumbers, ')
          ..write('languageCode: $languageCode, ')
          ..write('isLeftHanded: $isLeftHanded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    musicVolume,
    sfxVolume,
    hapticsEnabled,
    damageNumbers,
    languageCode,
    isLeftHanded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSettingsTableData &&
          other.id == this.id &&
          other.musicVolume == this.musicVolume &&
          other.sfxVolume == this.sfxVolume &&
          other.hapticsEnabled == this.hapticsEnabled &&
          other.damageNumbers == this.damageNumbers &&
          other.languageCode == this.languageCode &&
          other.isLeftHanded == this.isLeftHanded);
}

class GameSettingsTableCompanion
    extends UpdateCompanion<GameSettingsTableData> {
  final Value<int> id;
  final Value<double> musicVolume;
  final Value<double> sfxVolume;
  final Value<bool> hapticsEnabled;
  final Value<bool> damageNumbers;
  final Value<String> languageCode;
  final Value<bool> isLeftHanded;
  const GameSettingsTableCompanion({
    this.id = const Value.absent(),
    this.musicVolume = const Value.absent(),
    this.sfxVolume = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.damageNumbers = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.isLeftHanded = const Value.absent(),
  });
  GameSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.musicVolume = const Value.absent(),
    this.sfxVolume = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.damageNumbers = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.isLeftHanded = const Value.absent(),
  });
  static Insertable<GameSettingsTableData> custom({
    Expression<int>? id,
    Expression<double>? musicVolume,
    Expression<double>? sfxVolume,
    Expression<bool>? hapticsEnabled,
    Expression<bool>? damageNumbers,
    Expression<String>? languageCode,
    Expression<bool>? isLeftHanded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (musicVolume != null) 'music_volume': musicVolume,
      if (sfxVolume != null) 'sfx_volume': sfxVolume,
      if (hapticsEnabled != null) 'haptics_enabled': hapticsEnabled,
      if (damageNumbers != null) 'damage_numbers': damageNumbers,
      if (languageCode != null) 'language_code': languageCode,
      if (isLeftHanded != null) 'is_left_handed': isLeftHanded,
    });
  }

  GameSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<double>? musicVolume,
    Value<double>? sfxVolume,
    Value<bool>? hapticsEnabled,
    Value<bool>? damageNumbers,
    Value<String>? languageCode,
    Value<bool>? isLeftHanded,
  }) {
    return GameSettingsTableCompanion(
      id: id ?? this.id,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      damageNumbers: damageNumbers ?? this.damageNumbers,
      languageCode: languageCode ?? this.languageCode,
      isLeftHanded: isLeftHanded ?? this.isLeftHanded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (musicVolume.present) {
      map['music_volume'] = Variable<double>(musicVolume.value);
    }
    if (sfxVolume.present) {
      map['sfx_volume'] = Variable<double>(sfxVolume.value);
    }
    if (hapticsEnabled.present) {
      map['haptics_enabled'] = Variable<bool>(hapticsEnabled.value);
    }
    if (damageNumbers.present) {
      map['damage_numbers'] = Variable<bool>(damageNumbers.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (isLeftHanded.present) {
      map['is_left_handed'] = Variable<bool>(isLeftHanded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('musicVolume: $musicVolume, ')
          ..write('sfxVolume: $sfxVolume, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('damageNumbers: $damageNumbers, ')
          ..write('languageCode: $languageCode, ')
          ..write('isLeftHanded: $isLeftHanded')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayerProfilesTable playerProfiles = $PlayerProfilesTable(this);
  late final $PermanentUpgradesTable permanentUpgrades =
      $PermanentUpgradesTable(this);
  late final $RunHistoriesTable runHistories = $RunHistoriesTable(this);
  late final $GameSettingsTableTable gameSettingsTable =
      $GameSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerProfiles,
    permanentUpgrades,
    runHistories,
    gameSettingsTable,
  ];
}

typedef $$PlayerProfilesTableCreateCompanionBuilder =
    PlayerProfilesCompanion Function({
      Value<int> id,
      Value<String> playerName,
      Value<int> goldCoins,
      Value<int> gems,
      Value<int> totalKills,
      Value<int> totalRuns,
      Value<int> totalTimePlayedSeconds,
      Value<DateTime> createdAt,
      Value<DateTime> lastLogin,
    });
typedef $$PlayerProfilesTableUpdateCompanionBuilder =
    PlayerProfilesCompanion Function({
      Value<int> id,
      Value<String> playerName,
      Value<int> goldCoins,
      Value<int> gems,
      Value<int> totalKills,
      Value<int> totalRuns,
      Value<int> totalTimePlayedSeconds,
      Value<DateTime> createdAt,
      Value<DateTime> lastLogin,
    });

class $$PlayerProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goldCoins => $composableBuilder(
    column: $table.goldCoins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gems => $composableBuilder(
    column: $table.gems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalKills => $composableBuilder(
    column: $table.totalKills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalRuns => $composableBuilder(
    column: $table.totalRuns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTimePlayedSeconds => $composableBuilder(
    column: $table.totalTimePlayedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLogin => $composableBuilder(
    column: $table.lastLogin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goldCoins => $composableBuilder(
    column: $table.goldCoins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gems => $composableBuilder(
    column: $table.gems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalKills => $composableBuilder(
    column: $table.totalKills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRuns => $composableBuilder(
    column: $table.totalRuns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTimePlayedSeconds => $composableBuilder(
    column: $table.totalTimePlayedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLogin => $composableBuilder(
    column: $table.lastLogin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goldCoins =>
      $composableBuilder(column: $table.goldCoins, builder: (column) => column);

  GeneratedColumn<int> get gems =>
      $composableBuilder(column: $table.gems, builder: (column) => column);

  GeneratedColumn<int> get totalKills => $composableBuilder(
    column: $table.totalKills,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalRuns =>
      $composableBuilder(column: $table.totalRuns, builder: (column) => column);

  GeneratedColumn<int> get totalTimePlayedSeconds => $composableBuilder(
    column: $table.totalTimePlayedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLogin =>
      $composableBuilder(column: $table.lastLogin, builder: (column) => column);
}

class $$PlayerProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerProfilesTable,
          PlayerProfile,
          $$PlayerProfilesTableFilterComposer,
          $$PlayerProfilesTableOrderingComposer,
          $$PlayerProfilesTableAnnotationComposer,
          $$PlayerProfilesTableCreateCompanionBuilder,
          $$PlayerProfilesTableUpdateCompanionBuilder,
          (
            PlayerProfile,
            BaseReferences<_$AppDatabase, $PlayerProfilesTable, PlayerProfile>,
          ),
          PlayerProfile,
          PrefetchHooks Function()
        > {
  $$PlayerProfilesTableTableManager(
    _$AppDatabase db,
    $PlayerProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> playerName = const Value.absent(),
                Value<int> goldCoins = const Value.absent(),
                Value<int> gems = const Value.absent(),
                Value<int> totalKills = const Value.absent(),
                Value<int> totalRuns = const Value.absent(),
                Value<int> totalTimePlayedSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastLogin = const Value.absent(),
              }) => PlayerProfilesCompanion(
                id: id,
                playerName: playerName,
                goldCoins: goldCoins,
                gems: gems,
                totalKills: totalKills,
                totalRuns: totalRuns,
                totalTimePlayedSeconds: totalTimePlayedSeconds,
                createdAt: createdAt,
                lastLogin: lastLogin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> playerName = const Value.absent(),
                Value<int> goldCoins = const Value.absent(),
                Value<int> gems = const Value.absent(),
                Value<int> totalKills = const Value.absent(),
                Value<int> totalRuns = const Value.absent(),
                Value<int> totalTimePlayedSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastLogin = const Value.absent(),
              }) => PlayerProfilesCompanion.insert(
                id: id,
                playerName: playerName,
                goldCoins: goldCoins,
                gems: gems,
                totalKills: totalKills,
                totalRuns: totalRuns,
                totalTimePlayedSeconds: totalTimePlayedSeconds,
                createdAt: createdAt,
                lastLogin: lastLogin,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayerProfilesTable, PlayerProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlayerProfilesTable,
                    PlayerProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerProfilesTable,
      PlayerProfile,
      $$PlayerProfilesTableFilterComposer,
      $$PlayerProfilesTableOrderingComposer,
      $$PlayerProfilesTableAnnotationComposer,
      $$PlayerProfilesTableCreateCompanionBuilder,
      $$PlayerProfilesTableUpdateCompanionBuilder,
      (
        PlayerProfile,
        BaseReferences<_$AppDatabase, $PlayerProfilesTable, PlayerProfile>,
      ),
      PlayerProfile,
      PrefetchHooks Function()
    >;
typedef $$PermanentUpgradesTableCreateCompanionBuilder =
    PermanentUpgradesCompanion Function({
      required String upgradeId,
      required String name,
      required String description,
      Value<int> currentLevel,
      Value<int> maxLevel,
      required int baseCost,
      Value<double> costMultiplier,
      required double bonusPerLevel,
      Value<int> rowid,
    });
typedef $$PermanentUpgradesTableUpdateCompanionBuilder =
    PermanentUpgradesCompanion Function({
      Value<String> upgradeId,
      Value<String> name,
      Value<String> description,
      Value<int> currentLevel,
      Value<int> maxLevel,
      Value<int> baseCost,
      Value<double> costMultiplier,
      Value<double> bonusPerLevel,
      Value<int> rowid,
    });

class $$PermanentUpgradesTableFilterComposer
    extends Composer<_$AppDatabase, $PermanentUpgradesTable> {
  $$PermanentUpgradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get upgradeId => $composableBuilder(
    column: $table.upgradeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxLevel => $composableBuilder(
    column: $table.maxLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseCost => $composableBuilder(
    column: $table.baseCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costMultiplier => $composableBuilder(
    column: $table.costMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bonusPerLevel => $composableBuilder(
    column: $table.bonusPerLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PermanentUpgradesTableOrderingComposer
    extends Composer<_$AppDatabase, $PermanentUpgradesTable> {
  $$PermanentUpgradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get upgradeId => $composableBuilder(
    column: $table.upgradeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxLevel => $composableBuilder(
    column: $table.maxLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseCost => $composableBuilder(
    column: $table.baseCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costMultiplier => $composableBuilder(
    column: $table.costMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bonusPerLevel => $composableBuilder(
    column: $table.bonusPerLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PermanentUpgradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PermanentUpgradesTable> {
  $$PermanentUpgradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get upgradeId =>
      $composableBuilder(column: $table.upgradeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxLevel =>
      $composableBuilder(column: $table.maxLevel, builder: (column) => column);

  GeneratedColumn<int> get baseCost =>
      $composableBuilder(column: $table.baseCost, builder: (column) => column);

  GeneratedColumn<double> get costMultiplier => $composableBuilder(
    column: $table.costMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bonusPerLevel => $composableBuilder(
    column: $table.bonusPerLevel,
    builder: (column) => column,
  );
}

class $$PermanentUpgradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PermanentUpgradesTable,
          PermanentUpgrade,
          $$PermanentUpgradesTableFilterComposer,
          $$PermanentUpgradesTableOrderingComposer,
          $$PermanentUpgradesTableAnnotationComposer,
          $$PermanentUpgradesTableCreateCompanionBuilder,
          $$PermanentUpgradesTableUpdateCompanionBuilder,
          (
            PermanentUpgrade,
            BaseReferences<
              _$AppDatabase,
              $PermanentUpgradesTable,
              PermanentUpgrade
            >,
          ),
          PermanentUpgrade,
          PrefetchHooks Function()
        > {
  $$PermanentUpgradesTableTableManager(
    _$AppDatabase db,
    $PermanentUpgradesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PermanentUpgradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PermanentUpgradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PermanentUpgradesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> upgradeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> currentLevel = const Value.absent(),
                Value<int> maxLevel = const Value.absent(),
                Value<int> baseCost = const Value.absent(),
                Value<double> costMultiplier = const Value.absent(),
                Value<double> bonusPerLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PermanentUpgradesCompanion(
                upgradeId: upgradeId,
                name: name,
                description: description,
                currentLevel: currentLevel,
                maxLevel: maxLevel,
                baseCost: baseCost,
                costMultiplier: costMultiplier,
                bonusPerLevel: bonusPerLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String upgradeId,
                required String name,
                required String description,
                Value<int> currentLevel = const Value.absent(),
                Value<int> maxLevel = const Value.absent(),
                required int baseCost,
                Value<double> costMultiplier = const Value.absent(),
                required double bonusPerLevel,
                Value<int> rowid = const Value.absent(),
              }) => PermanentUpgradesCompanion.insert(
                upgradeId: upgradeId,
                name: name,
                description: description,
                currentLevel: currentLevel,
                maxLevel: maxLevel,
                baseCost: baseCost,
                costMultiplier: costMultiplier,
                bonusPerLevel: bonusPerLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PermanentUpgradesTable, PermanentUpgrade>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PermanentUpgradesTable,
                    PermanentUpgrade
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PermanentUpgradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PermanentUpgradesTable,
      PermanentUpgrade,
      $$PermanentUpgradesTableFilterComposer,
      $$PermanentUpgradesTableOrderingComposer,
      $$PermanentUpgradesTableAnnotationComposer,
      $$PermanentUpgradesTableCreateCompanionBuilder,
      $$PermanentUpgradesTableUpdateCompanionBuilder,
      (
        PermanentUpgrade,
        BaseReferences<
          _$AppDatabase,
          $PermanentUpgradesTable,
          PermanentUpgrade
        >,
      ),
      PermanentUpgrade,
      PrefetchHooks Function()
    >;
typedef $$RunHistoriesTableCreateCompanionBuilder =
    RunHistoriesCompanion Function({
      Value<int> id,
      required int score,
      required int survivedSeconds,
      required int enemiesSlain,
      required int goldEarned,
      required int waveReached,
      Value<DateTime> playedAt,
    });
typedef $$RunHistoriesTableUpdateCompanionBuilder =
    RunHistoriesCompanion Function({
      Value<int> id,
      Value<int> score,
      Value<int> survivedSeconds,
      Value<int> enemiesSlain,
      Value<int> goldEarned,
      Value<int> waveReached,
      Value<DateTime> playedAt,
    });

class $$RunHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $RunHistoriesTable> {
  $$RunHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get survivedSeconds => $composableBuilder(
    column: $table.survivedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enemiesSlain => $composableBuilder(
    column: $table.enemiesSlain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goldEarned => $composableBuilder(
    column: $table.goldEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waveReached => $composableBuilder(
    column: $table.waveReached,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RunHistoriesTable> {
  $$RunHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get survivedSeconds => $composableBuilder(
    column: $table.survivedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enemiesSlain => $composableBuilder(
    column: $table.enemiesSlain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goldEarned => $composableBuilder(
    column: $table.goldEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waveReached => $composableBuilder(
    column: $table.waveReached,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunHistoriesTable> {
  $$RunHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get survivedSeconds => $composableBuilder(
    column: $table.survivedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enemiesSlain => $composableBuilder(
    column: $table.enemiesSlain,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goldEarned => $composableBuilder(
    column: $table.goldEarned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get waveReached => $composableBuilder(
    column: $table.waveReached,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);
}

class $$RunHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunHistoriesTable,
          RunHistory,
          $$RunHistoriesTableFilterComposer,
          $$RunHistoriesTableOrderingComposer,
          $$RunHistoriesTableAnnotationComposer,
          $$RunHistoriesTableCreateCompanionBuilder,
          $$RunHistoriesTableUpdateCompanionBuilder,
          (
            RunHistory,
            BaseReferences<_$AppDatabase, $RunHistoriesTable, RunHistory>,
          ),
          RunHistory,
          PrefetchHooks Function()
        > {
  $$RunHistoriesTableTableManager(_$AppDatabase db, $RunHistoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> survivedSeconds = const Value.absent(),
                Value<int> enemiesSlain = const Value.absent(),
                Value<int> goldEarned = const Value.absent(),
                Value<int> waveReached = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => RunHistoriesCompanion(
                id: id,
                score: score,
                survivedSeconds: survivedSeconds,
                enemiesSlain: enemiesSlain,
                goldEarned: goldEarned,
                waveReached: waveReached,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int score,
                required int survivedSeconds,
                required int enemiesSlain,
                required int goldEarned,
                required int waveReached,
                Value<DateTime> playedAt = const Value.absent(),
              }) => RunHistoriesCompanion.insert(
                id: id,
                score: score,
                survivedSeconds: survivedSeconds,
                enemiesSlain: enemiesSlain,
                goldEarned: goldEarned,
                waveReached: waveReached,
                playedAt: playedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RunHistoriesTable, RunHistory>(table),
                  BaseReferences<_$AppDatabase, $RunHistoriesTable, RunHistory>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunHistoriesTable,
      RunHistory,
      $$RunHistoriesTableFilterComposer,
      $$RunHistoriesTableOrderingComposer,
      $$RunHistoriesTableAnnotationComposer,
      $$RunHistoriesTableCreateCompanionBuilder,
      $$RunHistoriesTableUpdateCompanionBuilder,
      (
        RunHistory,
        BaseReferences<_$AppDatabase, $RunHistoriesTable, RunHistory>,
      ),
      RunHistory,
      PrefetchHooks Function()
    >;
typedef $$GameSettingsTableTableCreateCompanionBuilder =
    GameSettingsTableCompanion Function({
      Value<int> id,
      Value<double> musicVolume,
      Value<double> sfxVolume,
      Value<bool> hapticsEnabled,
      Value<bool> damageNumbers,
      Value<String> languageCode,
      Value<bool> isLeftHanded,
    });
typedef $$GameSettingsTableTableUpdateCompanionBuilder =
    GameSettingsTableCompanion Function({
      Value<int> id,
      Value<double> musicVolume,
      Value<double> sfxVolume,
      Value<bool> hapticsEnabled,
      Value<bool> damageNumbers,
      Value<String> languageCode,
      Value<bool> isLeftHanded,
    });

class $$GameSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GameSettingsTableTable> {
  $$GameSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get musicVolume => $composableBuilder(
    column: $table.musicVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sfxVolume => $composableBuilder(
    column: $table.sfxVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get damageNumbers => $composableBuilder(
    column: $table.damageNumbers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLeftHanded => $composableBuilder(
    column: $table.isLeftHanded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSettingsTableTable> {
  $$GameSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get musicVolume => $composableBuilder(
    column: $table.musicVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sfxVolume => $composableBuilder(
    column: $table.sfxVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get damageNumbers => $composableBuilder(
    column: $table.damageNumbers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLeftHanded => $composableBuilder(
    column: $table.isLeftHanded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSettingsTableTable> {
  $$GameSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get musicVolume => $composableBuilder(
    column: $table.musicVolume,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sfxVolume =>
      $composableBuilder(column: $table.sfxVolume, builder: (column) => column);

  GeneratedColumn<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get damageNumbers => $composableBuilder(
    column: $table.damageNumbers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLeftHanded => $composableBuilder(
    column: $table.isLeftHanded,
    builder: (column) => column,
  );
}

class $$GameSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSettingsTableTable,
          GameSettingsTableData,
          $$GameSettingsTableTableFilterComposer,
          $$GameSettingsTableTableOrderingComposer,
          $$GameSettingsTableTableAnnotationComposer,
          $$GameSettingsTableTableCreateCompanionBuilder,
          $$GameSettingsTableTableUpdateCompanionBuilder,
          (
            GameSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $GameSettingsTableTable,
              GameSettingsTableData
            >,
          ),
          GameSettingsTableData,
          PrefetchHooks Function()
        > {
  $$GameSettingsTableTableTableManager(
    _$AppDatabase db,
    $GameSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> musicVolume = const Value.absent(),
                Value<double> sfxVolume = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<bool> damageNumbers = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<bool> isLeftHanded = const Value.absent(),
              }) => GameSettingsTableCompanion(
                id: id,
                musicVolume: musicVolume,
                sfxVolume: sfxVolume,
                hapticsEnabled: hapticsEnabled,
                damageNumbers: damageNumbers,
                languageCode: languageCode,
                isLeftHanded: isLeftHanded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> musicVolume = const Value.absent(),
                Value<double> sfxVolume = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<bool> damageNumbers = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<bool> isLeftHanded = const Value.absent(),
              }) => GameSettingsTableCompanion.insert(
                id: id,
                musicVolume: musicVolume,
                sfxVolume: sfxVolume,
                hapticsEnabled: hapticsEnabled,
                damageNumbers: damageNumbers,
                languageCode: languageCode,
                isLeftHanded: isLeftHanded,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameSettingsTableTable, GameSettingsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $GameSettingsTableTable,
                    GameSettingsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSettingsTableTable,
      GameSettingsTableData,
      $$GameSettingsTableTableFilterComposer,
      $$GameSettingsTableTableOrderingComposer,
      $$GameSettingsTableTableAnnotationComposer,
      $$GameSettingsTableTableCreateCompanionBuilder,
      $$GameSettingsTableTableUpdateCompanionBuilder,
      (
        GameSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $GameSettingsTableTable,
          GameSettingsTableData
        >,
      ),
      GameSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayerProfilesTableTableManager get playerProfiles =>
      $$PlayerProfilesTableTableManager(_db, _db.playerProfiles);
  $$PermanentUpgradesTableTableManager get permanentUpgrades =>
      $$PermanentUpgradesTableTableManager(_db, _db.permanentUpgrades);
  $$RunHistoriesTableTableManager get runHistories =>
      $$RunHistoriesTableTableManager(_db, _db.runHistories);
  $$GameSettingsTableTableTableManager get gameSettingsTable =>
      $$GameSettingsTableTableTableManager(_db, _db.gameSettingsTable);
}
