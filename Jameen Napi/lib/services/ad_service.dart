import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_flags.dart';

class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  bool _initialized = false;
  bool _interstitialLoaded = false;
  InterstitialAd? _interstitialAd;

  // Google Official AdMob Test Unit IDs
  static const String _testBannerAdUnitId = "ca-app-pub-3940256099942544/6300978111";
  static const String _testInterstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712";

  // Production AdMob Unit IDs
  static const String _prodBannerAdUnitId = "ca-app-pub-1812659704661588/3699858745";
  static const String _prodInterstitialAdUnitId = "ca-app-pub-1812659704661588/5993622304";

  // Dynamic IDs based on debug/release mode
  static String get bannerAdUnitId => kDebugMode ? _testBannerAdUnitId : _prodBannerAdUnitId;
  static String get interstitialAdUnitId => kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;

  static const String _exitCountKey = 'admob_exit_count';
  static const int _interstitialInterval = 3; // Show ad every 3rd time the user pops a screen

  /// Initialize Mobile Ads SDK.
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      loadInterstitialAd();
    } catch (e) {
      debugPrint('AdService initialization failed: $e');
    }
  }

  /// Create and return a BannerAd. Caller is responsible for loading and disposing it.
  BannerAd createBannerAd({VoidCallback? onLoaded}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  /// Load Interstitial Ad.
  void loadInterstitialAd() {
    if (!_initialized) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialLoaded = false;
        },
      ),
    );
  }

  /// Show Interstitial Ad (only if loaded, handles callbacks).
  void showInterstitialAd(VoidCallback onDismissed) {
    if (!_initialized || !_interstitialLoaded || _interstitialAd == null) {
      onDismissed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialLoaded = false;
        loadInterstitialAd(); // Load next for future
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialLoaded = false;
        loadInterstitialAd();
        onDismissed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  /// Show interstitial ad periodically when exiting a screen.
  Future<void> showInterstitialWithCounter(VoidCallback onComplete) async {
    if (screenshotMode) {
      onComplete();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      int count = prefs.getInt(_exitCountKey) ?? 0;
      count++;
      await prefs.setInt(_exitCountKey, count);

      if (count % _interstitialInterval == 0) {
        showInterstitialAd(onComplete);
      } else {
        onComplete();
      }
    } catch (_) {
      onComplete();
    }
  }
}
