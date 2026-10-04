import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'review_service.dart';
import 'storage_service.dart';

/// AdMob service with test IDs. Replace with real IDs for production.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const String _prodBannerId = 'ca-app-pub-1812659704661588/7491554732';
  static const String _prodInterstitialId =
      'ca-app-pub-1812659704661588/6480526285';

  // Google's public test units. Debug builds must never request real ads —
  // one accidental tap on our own ad can get the AdMob account banned.
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get bannerId => kDebugMode ? _testBannerId : _prodBannerId;
  static String get interstitialId =>
      kDebugMode ? _testInterstitialId : _prodInterstitialId;

  /// How many times a failed ad load is retried, and how long we wait between
  /// tries. Without this a single network blip kills ads for the whole session.
  static const int maxLoadRetries = 3;
  static Duration retryDelay(int attempt) =>
      Duration(seconds: 4 * (attempt + 1));

  InterstitialAd? _interstitialAd;
  StorageService? _storage;
  int _interstitialRetries = 0;

  /// `--dart-define=NO_ADS=true` builds an app with no ads at all — for the
  /// on-device test run and for taking store screenshots.
  static const bool adsEnabled = !bool.fromEnvironment('NO_ADS');

  Future<void> initialize(StorageService storage) async {
    _storage = storage;
    if (!adsEnabled) return;
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  /// An interstitial needs this many fresh calculations since the last one…
  static const int calcsPerInterstitial = 3;

  /// …and at least this long since the last one.
  static const Duration minInterstitialGap = Duration(minutes: 3);

  int _calcsSinceInterstitial = 0;
  bool _freshResult = false;
  DateTime? _lastInterstitialAt;

  /// Track calculation count for interstitial + review triggers.
  ///
  /// Nothing is shown here: the user has just tapped Calculate and wants to
  /// read the answer. The interstitial waits for [onCalculatorClosed].
  /// [repeat] = Calculate tapped again on an unchanged form; not counted.
  Future<void> onCalculationComplete({bool repeat = false}) async {
    if (_storage == null || repeat) return;
    await _storage!.incrementCalcCount();
    final count = _storage!.calcCount;

    // Review after 3rd calc, only once — and that calculation earns no ad.
    if (count >= 3 && !_storage!.reviewShown) {
      await _storage!.setReviewShown();
      ReviewService.requestReview();
      return;
    }

    _calcsSinceInterstitial++;
    _freshResult = true;
  }

  /// The user is leaving a screen. If they got an answer there, this is the
  /// natural break where an interstitial may appear.
  void onCalculatorClosed() {
    final hadFreshResult = _freshResult;
    _freshResult = false;
    final now = DateTime.now();
    if (!shouldShowInterstitial(
      hadFreshResult: hadFreshResult,
      calcsSinceLast: _calcsSinceInterstitial,
      lastShownAt: _lastInterstitialAt,
      now: now,
    )) {
      return;
    }
    if (showInterstitial()) {
      _calcsSinceInterstitial = 0;
      _lastInterstitialAt = now;
    }
  }

  /// The whole "is it time for an interstitial" rule, kept pure for testing.
  static bool shouldShowInterstitial({
    required bool hadFreshResult,
    required int calcsSinceLast,
    required DateTime? lastShownAt,
    required DateTime now,
  }) {
    if (!hadFreshResult || calcsSinceLast < calcsPerInterstitial) return false;
    return lastShownAt == null ||
        now.difference(lastShownAt) >= minInterstitialGap;
  }

  // --- Banner ---

  /// Creates (but does not load) a banner ad. The caller must call `.load()`
  /// and dispose it. [onLoaded] fires once the ad is ready to display.
  BannerAd createBannerAd({
    VoidCallback? onLoaded,
    void Function(LoadAdError error)? onFailed,
    AdSize size = AdSize.banner,
  }) {
    return BannerAd(
      adUnitId: bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
          onFailed?.call(error);
        },
      ),
    );
  }

  /// An adaptive banner sized to the device width — better fill and eCPM than
  /// a fixed 320x50. Falls back to the standard banner on failure.
  static Future<AdSize> adaptiveBannerSize(int widthPx) async {
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(widthPx);
    return size ?? AdSize.banner;
  }

  // --- Interstitial ---

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialRetries = 0;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial failed to show: $error');
              ad.dispose();
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
          // Retry with a growing delay, otherwise one failure means no
          // interstitial for the rest of the session.
          if (_interstitialRetries < maxLoadRetries) {
            final attempt = _interstitialRetries++;
            Future.delayed(retryDelay(attempt), _loadInterstitial);
          }
        },
      ),
    );
  }

  /// Shows the loaded interstitial. Returns false (and starts a fresh load)
  /// when none is ready.
  bool showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      return true;
    }
    _interstitialRetries = 0;
    _loadInterstitial();
    return false;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

/// Tells [AdService] when a full screen is popped. Dialogs and bottom sheets
/// are routes too, so only page routes count.
class CalculatorExitObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) AdService().onCalculatorClosed();
  }
}
