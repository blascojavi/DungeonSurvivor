import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gestor centralizado de publicidad con Google AdMob.
///
/// Actualmente configurado con las IDs oficiales de prueba de Google AdMob.
/// Cuando vayas a subir la APK a producción, solo tienes que cambiar
/// el valor de [bannerAdUnitIdProduction] por tu ID real de bloque de anuncios.
class AdManager {
  AdManager._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // ID de prueba oficial de Google para Banners en Android
  static const String _testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';

  // TODO: Reemplazar con tu ID real de bloque de anuncios de AdMob cuando subas la app
  static const String _productionBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';

  /// Indica si se deben forzar los IDs de prueba.
  /// Por defecto en true mientras la app esté en desarrollo/pruebas.
  static const bool useTestAds = true;

  /// Obtiene la ID del Banner adecuada según el modo de ejecución.
  static String get bannerAdUnitId {
    if (useTestAds || kDebugMode) {
      return _testBannerAdUnitIdAndroid;
    }
    return _productionBannerAdUnitIdAndroid;
  }

  /// Indica si la plataforma actual soporta Google Mobile Ads (Android / iOS).
  static bool get isSupportedPlatform =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// Inicializa el SDK de Google Mobile Ads de forma segura.
  static Future<void> initialize() async {
    if (!isSupportedPlatform) {
      debugPrint('AdManager: Plataforma ($defaultTargetPlatform) no compatible con Google Mobile Ads. Omitiendo.');
      return;
    }
    if (_isInitialized) return;
    try {
      final status = await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdManager: Google Mobile Ads SDK inicializado correctamente ($status)');
    } catch (e) {
      debugPrint('AdManager: Error al inicializar Google Mobile Ads SDK: $e');
    }
  }

  /// Crea y carga un Banner de AdMob de tamaño estándar (320x50)
  /// con gestión limpia de eventos de carga y error.
  static BannerAd? createBannerAd({
    required void Function(Ad ad) onLoaded,
    required void Function(Ad ad, LoadAdError error) onFailed,
  }) {
    if (!isSupportedPlatform) return null;
    final banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdManager: Banner cargado con éxito.');
          onLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdManager: Fallo al cargar banner (${error.code}): ${error.message}');
          ad.dispose();
          onFailed(ad, error);
        },
        onAdOpened: (ad) => debugPrint('AdManager: Banner abierto.'),
        onAdClosed: (ad) => debugPrint('AdManager: Banner cerrado.'),
      ),
    );

    banner.load();
    return banner;
  }
}
