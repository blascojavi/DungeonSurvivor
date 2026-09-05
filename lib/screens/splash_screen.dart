import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ad_manager.dart';
import '../data/repositories/game_repository.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  final GameRepository repository;

  const SplashScreen({super.key, required this.repository});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasNavigated = false;

  final List<String> _loadingTips = [
    'Afilando espadas y dagas espectrales...',
    'Invocando a Lord Malakor en las sombras...',
    'Calibrando oleadas y trampas de la mazmorra...',
    'Cargando pergaminos y runas arcanas...',
    '¡La mazmorra está lista! Adentrándose...',
  ];

  @override
  void initState() {
    super.initState();

    // 1. Controlador de la barra de progreso (5 segundos de carga épica)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _navigateToMainMenu();
        }
      })
      ..addListener(() {
        setState(() {});
      });

    // 2. Controlador de pulso/brillo ambiental continuo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // 3. Controlador de rotación del círculo arcano
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Iniciar carga del progreso
    _progressController.forward();

    // Cargar Banner de Google AdMob
    _loadBannerAd();
  }

  void _loadBannerAd() {
    try {
      _bannerAd = AdManager.createBannerAd(
        onLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onFailed: (ad, error) {
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('SplashScreen: No se pudo instanciar el banner: $e');
    }
  }

  void _navigateToMainMenu() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainMenuScreen(repository: widget.repository),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  String _getCurrentTip(double progress) {
    if (progress < 0.22) return _loadingTips[0];
    if (progress < 0.45) return _loadingTips[1];
    if (progress < 0.70) return _loadingTips[2];
    if (progress < 0.90) return _loadingTips[3];
    return _loadingTips[4];
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressController.value;
    final currentTip = _getCurrentTip(progress);
    final pulse = _pulseController.value;

    return Scaffold(
      backgroundColor: const Color(0xFF090C12),
      body: Stack(
        children: [
          // Fondo ambiental con gradiente místico y resplandor radial
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.3,
                  colors: [
                    Color.lerp(
                      const Color(0xFF142240),
                      const Color(0xFF1C2D54),
                      pulse,
                    )!,
                    const Color(0xFF090C12),
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Emblema Central con Círculo Arcano Rotatorio
                Center(
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Círculo rúnico rotatorio de fondo
                        RotationTransition(
                          turns: _rotateController,
                          child: Opacity(
                            opacity: 0.35 + (0.15 * pulse),
                            child: Image.asset(
                              'assets/images/arcane_blood_circle.png',
                              width: 165,
                              height: 165,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),

                        // Aura de luz mística pulsante
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.25 + 0.25 * pulse),
                                blurRadius: 35 + (15 * pulse),
                                spreadRadius: 6 + (4 * pulse),
                              ),
                              BoxShadow(
                                color: const Color(0xFF2979FF).withValues(alpha: 0.3),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        // Ícono de Escudo Central con Gradiente Metálico
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Título Épico del Juego
                const Text(
                  'SHADOW VAULT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.5,
                    shadows: [
                      Shadow(
                        blurRadius: 18,
                        color: Color(0xFF2979FF),
                        offset: Offset(0, 4),
                      ),
                      Shadow(
                        blurRadius: 35,
                        color: Color(0xFF00E5FF),
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'DUNGEON SURVIVOR 2D',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),

                const Spacer(flex: 2),

                // Sección de Carga y Barra de Progreso
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      // Indicador textual de cargando + porcentaje
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CARGANDO...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFeatures: [],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Barra de Progreso Estilizada
                      Container(
                        height: 9,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141B2B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                // Barra con degradado fluido
                                Container(
                                  width: constraints.maxWidth * progress,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2979FF),
                                        Color(0xFF00E5FF),
                                        Color(0xFFFFD700),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Texto dinámico de Lore con animación de cambio
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.25),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          currentTip,
                          key: ValueKey<String>(currentTip),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Sección Inferior: Banner de Publicidad Google AdMob
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
                  child: _buildBannerArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el banner de AdMob o un contenedor rúnico elegante si aún está cargando u offline.
  Widget _buildBannerArea() {
    if (_bannerAd != null && _isAdLoaded) {
      return Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // Contenedor elegante de respaldo (Placeholder sutil para modo offline o precarga)
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101624).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Color(0xFFFFD700),
              size: 15,
            ),
            SizedBox(width: 8),
            Text(
              'SHADOW VAULT • AVENTURA ROGUELIKE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.auto_awesome,
              color: Color(0xFFFFD700),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
