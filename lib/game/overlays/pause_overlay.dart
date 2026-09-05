import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../dungeon_game.dart';

class PauseOverlay extends StatefulWidget {
  final DungeonGame game;
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const PauseOverlay({
    super.key,
    required this.game,
    required this.onResume,
    required this.onQuit,
  });

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  late double _musicVol;
  late double _sfxVol;

  @override
  void initState() {
    super.initState();
    _musicVol = AudioManager.musicVolume;
    _sfxVol = AudioManager.sfxVolume;
  }

  void _changeMusic(double val) {
    setState(() => _musicVol = val);
    AudioManager.setMusicVolume(val);
    widget.game.repository.setMusicVolume(val);
  }

  void _changeSfx(double val) {
    setState(() => _sfxVol = val);
    AudioManager.setSfxVolume(val);
    widget.game.repository.setSfxVolume(val);
  }

  @override
  Widget build(BuildContext context) {
    final isNightmare = widget.game.isNightmare;

    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 380,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF141B2B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título con icono
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.pause_circle_filled, color: Color(0xFF00E5FF), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'PARTIDA EN PAUSA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Indicador de dificultad actual
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isNightmare
                      ? const Color(0xFFFF2A4B).withValues(alpha: 0.15)
                      : const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isNightmare
                        ? const Color(0xFFFF2A4B).withValues(alpha: 0.4)
                        : const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNightmare ? Icons.dangerous : Icons.shield_outlined,
                      color: isNightmare ? const Color(0xFFFF2A4B) : const Color(0xFF00E5FF),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isNightmare ? 'MODO PESADILLA (HARDCORE)' : 'MODO NOVATO (EQUILIBRADO)',
                      style: TextStyle(
                        color: isNightmare ? const Color(0xFFFF2A4B) : const Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Control Música
              _buildSliderRow(
                label: 'Música D&D',
                icon: Icons.music_note,
                val: _musicVol,
                color: const Color(0xFF00E5FF),
                onChanged: _changeMusic,
              ),
              const SizedBox(height: 12),

              // Control SFX
              _buildSliderRow(
                label: 'Efectos SFX',
                icon: Icons.volume_up,
                val: _sfxVol,
                color: const Color(0xFFFFD700),
                onChanged: _changeSfx,
                onChangeEnd: (_) => AudioManager.playShoot(),
              ),
              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  // Salir al Menú
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onQuit,
                      icon: const Icon(Icons.home, size: 18, color: Colors.white70),
                      label: const Text(
                        'MENÚ',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Reanudar
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onResume,
                      icon: const Icon(Icons.play_arrow, size: 20, color: Colors.white),
                      label: const Text(
                        'CONTINUAR',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required IconData icon,
    required double val,
    required Color color,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    final pct = (val * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            Text(
              '$pct%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: Colors.white12,
            thumbColor: color,
            trackHeight: 4,
          ),
          child: Slider(
            value: val,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}
