import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static bool isMuted = false;
  static double musicVolume = 0.7;
  static double sfxVolume = 0.9;
  static bool _isBgmPlaying = false;
  static final Map<String, int> _lastPlayedMs = {};
  static final Map<String, AudioPool> _pools = {};

  static Future<void> initialize({double? initialMusicVolume, double? initialSfxVolume}) async {
    if (initialMusicVolume != null) musicVolume = initialMusicVolume.clamp(0.0, 1.0);
    if (initialSfxVolume != null) sfxVolume = initialSfxVolume.clamp(0.0, 1.0);

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
        'bgm_dungeon.wav',
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

  // --- CONTROLES DE MÚSICA DE FONDO (BGM) ---

  static Future<void> startBgm() async {
    if (isMuted || musicVolume <= 0) return;
    try {
      if (!_isBgmPlaying) {
        await FlameAudio.bgm.play('bgm_dungeon.wav', volume: musicVolume);
        _isBgmPlaying = true;
      }
    } catch (_) {}
  }

  static Future<void> pauseBgm() async {
    try {
      if (_isBgmPlaying) {
        await FlameAudio.bgm.pause();
      }
    } catch (_) {}
  }

  static Future<void> resumeBgm() async {
    if (isMuted || musicVolume <= 0) return;
    try {
      if (_isBgmPlaying) {
        await FlameAudio.bgm.resume();
      } else {
        await startBgm();
      }
    } catch (_) {}
  }

  static Future<void> stopBgm() async {
    try {
      await FlameAudio.bgm.stop();
      _isBgmPlaying = false;
    } catch (_) {}
  }

  static void setMusicVolume(double vol) {
    musicVolume = vol.clamp(0.0, 1.0);
    try {
      if (musicVolume <= 0) {
        FlameAudio.bgm.pause();
      } else {
        FlameAudio.bgm.audioPlayer.setVolume(musicVolume);
        if (!_isBgmPlaying) {
          startBgm();
        } else {
          FlameAudio.bgm.resume();
        }
      }
    } catch (_) {}
  }

  static void setSfxVolume(double vol) {
    sfxVolume = vol.clamp(0.0, 1.0);
  }

  // --- EFECTOS DE SONIDO (SFX) ---

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
    if (isMuted || sfxVolume <= 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayedMs[fileName] ?? 0;
    if (now - last < throttleMs) {
      return;
    }
    _lastPlayedMs[fileName] = now;

    final effectiveVolume = (volume * sfxVolume).clamp(0.0, 1.0);

    try {
      final pool = _pools[fileName];
      if (pool != null) {
        pool.start(volume: effectiveVolume);
      } else {
        FlameAudio.play(fileName, volume: effectiveVolume);
      }
    } catch (_) {}
  }
}

