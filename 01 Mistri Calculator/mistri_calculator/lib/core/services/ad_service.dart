import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'review_service.dart';
import 'storage_service.dart';

/// AdMob service with test IDs. Replace with real IDs for production.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const String _bannerId = 'ca-app-pub-1812659704661588/7491554732';
  static const String _interstitialId = 'ca-app-pub-1812659704661588/6480526285';

  InterstitialAd? _interstitialAd;
  StorageService? _storage;

  Future<void> initialize(StorageService storage) async {
    _storage = storage;
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  /// How often the interstitial ad appears (every Nth calculation).
  static const int _interstitialEvery = 3;

  /// Track calculation count for interstitial + review triggers.
  ///
  /// The review prompt appears once (after the 3rd calc) and takes priority,
  /// so the user never gets an ad and a review popup on the same tap.
  Future<void> onCalculationComplete() async {
    if (_storage == null) return;
    await _storage!.incrementCalcCount();
    final count = _storage!.calcCount;

    // Review after 3rd calc, only once — shown alone, never with an ad.
    if (count >= 3 && !_storage!.reviewShown) {
      await _storage!.setReviewShown();
      ReviewService.requestReview();
      return;
    }

    if (count % _interstitialEvery == 0) {
      showInterstitial();
    }
  }

  // --- Banner ---

  /// Creates (but does not load) a banner ad. The caller must call `.load()`
  /// and dispose it. [onLoaded] fires once the ad is ready to display.
  BannerAd createBannerAd({VoidCallback? onLoaded}) {
    return BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
        },
      ),
    );
  }

  // --- Interstitial ---

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      _loadInterstitial();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
