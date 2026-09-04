import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static bool isMuted = false;
  static final Map<String, int> _lastPlayedMs = {};
  static final Map<String, AudioPool> _pools = {};

  static Future<void> initialize() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'shoot.wav',
        'hit.wav',
        'gem.wav',
        'levelup.wav',
        'hurt.wav',
        'gameover.wav',
        'ultimate.wav',
        'explosion.wav',
        'enemy_shoot.wav',
        'boss_roar.wav',
      ]);
      _pools['shoot.wav'] = await FlameAudio.createPool('shoot.wav', minPlayers: 1, maxPlayers: 2);
      _pools['hit.wav'] = await FlameAudio.createPool('hit.wav', minPlayers: 1, maxPlayers: 2);
      _pools['gem.wav'] = await FlameAudio.createPool('gem.wav', minPlayers: 1, maxPlayers: 2);
      _pools['levelup.wav'] = await FlameAudio.createPool('levelup.wav', minPlayers: 1, maxPlayers: 1);
      _pools['hurt.wav'] = await FlameAudio.createPool('hurt.wav', minPlayers: 1, maxPlayers: 1);
      _pools['gameover.wav'] = await FlameAudio.createPool('gameover.wav', minPlayers: 1, maxPlayers: 1);
      _pools['ultimate.wav'] = await FlameAudio.createPool('ultimate.wav', minPlayers: 1, maxPlayers: 1);
      _pools['explosion.wav'] = await FlameAudio.createPool('explosion.wav', minPlayers: 1, maxPlayers: 2);
      _pools['enemy_shoot.wav'] = await FlameAudio.createPool('enemy_shoot.wav', minPlayers: 1, maxPlayers: 2);
      _pools['boss_roar.wav'] = await FlameAudio.createPool('boss_roar.wav', minPlayers: 1, maxPlayers: 1);
    } catch (_) {}
  }

  static void playShoot() {
    _play('shoot.wav', volume: 0.45, throttleMs: 140);
  }

  static void playHit() {
    _play('hit.wav', volume: 0.55, throttleMs: 110);
  }

  static void playGem() {
    _play('gem.wav', volume: 0.65, throttleMs: 90);
  }

  static void playLevelUp() {
    _play('levelup.wav', volume: 0.9, throttleMs: 350);
  }

  static void playHurt() {
    _play('hurt.wav', volume: 0.8, throttleMs: 300);
  }

  static void playGameOver() {
    _play('gameover.wav', volume: 1.0, throttleMs: 600);
  }

  static void playUltimate() {
    _play('ultimate.wav', volume: 1.0, throttleMs: 500);
  }

  static void playExplosion() {
    _play('explosion.wav', volume: 0.85, throttleMs: 150);
  }

  static void playEnemyShoot() {
    _play('enemy_shoot.wav', volume: 0.5, throttleMs: 120);
  }

  static void playBossRoar() {
    _play('boss_roar.wav', volume: 1.0, throttleMs: 800);
  }

  static void _play(String fileName, {double volume = 1.0, int throttleMs = 80}) {
    if (isMuted) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayedMs[fileName] ?? 0;
    if (now - last < throttleMs) {
      return;
    }
    _lastPlayedMs[fileName] = now;

    try {
      final pool = _pools[fileName];
      if (pool != null) {
        pool.start(volume: volume);
      } else {
        FlameAudio.play(fileName, volume: volume);
      }
    } catch (_) {}
  }
}
