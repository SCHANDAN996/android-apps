import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  bool _initialized = false;
  bool _interstitialLoaded = false;
  InterstitialAd? _interstitialAd;

  // Test Ad Unit IDs (Google provided test IDs)
  static const String bannerAdUnitIdAndroid = "ca-app-pub-3940256099942544/6300978111";
  static const String interstitialAdUnitIdAndroid = "ca-app-pub-3940256099942544/1033173712";

  /// Initialize Mobile Ads SDK.
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      loadInterstitialAd();
    } catch (_) {}
  }

  /// Create and return a BannerAd widget with bottom constraints.
  Widget getBannerAdWidget() {
    if (!_initialized) return const SizedBox.shrink();

    final banner = BannerAd(
      adUnitId: bannerAdUnitIdAndroid,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    banner.load();

    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }

  /// Load Interstitial Ad.
  void loadInterstitialAd() {
    if (!_initialized) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitIdAndroid,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoaded = false;
        },
      ),
    );
  }

  /// Show Interstitial Ad (only 1 per session/call, handles callbacks).
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
}
