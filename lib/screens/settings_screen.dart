import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../data/repositories/game_repository.dart';

class SettingsScreen extends StatefulWidget {
  final GameRepository repository;

  const SettingsScreen({super.key, required this.repository});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _musicVolume = 0.7;
  double _sfxVolume = 0.9;
  String _difficulty = 'nightmare';
  bool _isLeftHanded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.repository.getSettings();
    setState(() {
      _musicVolume = settings.musicVolume;
      _sfxVolume = settings.sfxVolume;
      _difficulty = settings.difficultyMode;
      _isLeftHanded = settings.isLeftHanded;
      _isLoading = false;
    });
    // Sincronizar AudioManager
    AudioManager.setMusicVolume(_musicVolume);
    AudioManager.setSfxVolume(_sfxVolume);
  }

  Future<void> _updateMusicVolume(double val) async {
    setState(() => _musicVolume = val);
    AudioManager.setMusicVolume(val);
    await widget.repository.setMusicVolume(val);
  }

  Future<void> _updateSfxVolume(double val) async {
    setState(() => _sfxVolume = val);
    AudioManager.setSfxVolume(val);
    await widget.repository.setSfxVolume(val);
  }

  Future<void> _updateDifficulty(String mode) async {
    setState(() => _difficulty = mode);
    await widget.repository.setDifficultyMode(mode);
    AudioManager.playGem();
  }

  Future<void> _updateHandedness(bool leftHanded) async {
    setState(() => _isLeftHanded = leftHanded);
    await widget.repository.setLeftHanded(leftHanded);
    AudioManager.playGem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141B2B),
        elevation: 4,
        title: const Text(
          'AJUSTES DEL JUEGO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E5FF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : Stack(
              children: [
                // Fondo con gradiente místico
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.4),
                      radius: 1.3,
                      colors: [
                        Color(0xFF162034),
                        Color(0xFF090C12),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    children: [
                      // --- SECCIÓN: AUDIO Y MÚSICA D&D ---
                      _buildSectionHeader('SONIDO Y AMBIENTACIÓN D&D', Icons.music_note),
                      const SizedBox(height: 12),
                      _buildSliderCard(
                        title: 'Música Ambiental D&D',
                        subtitle: 'Pista de mazmorra en Re menor con tambores y campanas arcanas',
                        icon: Icons.music_note,
                        value: _musicVolume,
                        activeColor: const Color(0xFF00E5FF),
                        onChanged: _updateMusicVolume,
                      ),
                      const SizedBox(height: 12),
                      _buildSliderCard(
                        title: 'Efectos de Sonido (SFX)',
                        subtitle: 'Disparos, impactos, gemas, rugidos y explosiones',
                        icon: Icons.volume_up,
                        value: _sfxVolume,
                        activeColor: const Color(0xFFFFD700),
                        onChanged: _updateSfxVolume,
                        onChangeEnd: (_) => AudioManager.playShoot(),
                      ),
                      const SizedBox(height: 24),

                      // --- SECCIÓN: NIVEL DE DIFICULTAD ---
                      _buildSectionHeader('NIVEL DE DIFICULTAD', Icons.local_fire_department),
                      const SizedBox(height: 6),
                      const Text(
                        'Selecciona tu estilo de desafío para la partida:',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                      const SizedBox(height: 14),

                      // Selector Novato
                      _buildDifficultyCard(
                        mode: 'novice',
                        title: 'MODO NOVATO',
                        subtitle: 'Supervivencia clásica y equilibrada',
                        badge: 'EQUILIBRADO',
                        badgeColor: const Color(0xFF00E5FF),
                        icon: Icons.shield_outlined,
                        accentColor: const Color(0xFF00E5FF),
                        isSelected: _difficulty == 'novice',
                        details: [
                          'Monstruos con vidas reducidas (Murciélagos 20 HP, Esqueletos 45 HP, Brutos 120 HP, Malakor 480 HP).',
                          'Límite de hasta 32 monstruos simultáneos.',
                          'Un único Jefe Malakor por oleada de boss.',
                        ],
                        onTap: () => _updateDifficulty('novice'),
                      ),
                      const SizedBox(height: 14),

                      // Selector Pesadilla
                      _buildDifficultyCard(
                        mode: 'nightmare',
                        title: 'MODO PESADILLA',
                        subtitle: '¡Nivelazo extremo para veteranos!',
                        badge: 'HARDCORE',
                        badgeColor: const Color(0xFFFF2A4B),
                        icon: Icons.dangerous,
                        accentColor: const Color(0xFFFF2A4B),
                        isSelected: _difficulty == 'nightmare',
                        details: [
                          'Monstruos con vida reforzada (Murciélagos 45 HP, Esqueletos 65 HP, Brutos 160 HP, Malakor 780 HP).',
                          'Hordas masivas: 60-70 en Oleada 1, escalando hasta 125 simultáneos.',
                          'A partir de la Oleada 15, los Jefes Malakor se duplican (x2) en cada encuentro.',
                        ],
                        onTap: () => _updateDifficulty('nightmare'),
                      ),
                      const SizedBox(height: 24),

                      // --- SECCIÓN: ERGONOMÍA ---
                      _buildSectionHeader('CONTROLES Y ERGONOMÍA', Icons.pan_tool_alt),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141B2B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app, color: Color(0xFF00E5FF), size: 24),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Posición del Joystick',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    _isLeftHanded ? 'Modo Zurdo (Derecha)' : 'Modo Diestro (Izquierda)',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isLeftHanded,
                              activeThumbColor: const Color(0xFF00E5FF),
                              onChanged: _updateHandedness,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    final percent = (value * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: activeColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: activeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$percent%',
                  style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: Colors.white12,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard({
    required String mode,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required List<String> details,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.12) : const Color(0xFF141B2B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white10,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? accentColor : Colors.white30,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 10),
            for (final detail in details)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Expanded(
                      child: Text(
                        detail,
                        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
