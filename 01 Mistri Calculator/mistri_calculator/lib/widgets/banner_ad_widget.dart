import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/services/ad_service.dart';
import '../core/theme/app_theme.dart';

/// A self-contained bottom banner ad. Sizes itself to the device width, retries
/// a few times if the load fails (a network blip shouldn't kill ads for the
/// whole screen), shows nothing until the ad is ready — so no empty grey box —
/// and disposes itself automatically.
/// Drop it into a Scaffold as `bottomNavigationBar: const BannerAdWidget()`.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;
  int _retries = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    // Deferred so we can read the screen width for the adaptive size.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted || !AdService.adsEnabled) return;
    final widthPx = MediaQuery.of(context).size.width.truncate();
    final size = await AdService.adaptiveBannerSize(widthPx);
    if (!mounted) return;

    final ad = AdService().createBannerAd(
      size: size,
      onLoaded: () {
        if (mounted) setState(() => _loaded = true);
      },
      onFailed: (_) => _scheduleRetry(),
    );
    setState(() {
      _ad = ad;
      _loaded = false;
    });
    ad.load();
  }

  void _scheduleRetry() {
    if (!mounted || _retries >= AdService.maxLoadRetries) return;
    final attempt = _retries++;
    _ad = null;
    _retryTimer?.cancel();
    _retryTimer = Timer(AdService.retryDelay(attempt), _load);
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The gesture bar / back-button strip at the bottom of the phone. The
    // Scaffold hands that space to whatever sits in bottomNavigationBar, so if
    // we shrink to nothing the page content slides underneath it — which is
    // what happened while the ad was still loading.
    final navBarHeight = MediaQuery.of(context).viewPadding.bottom;

    final ad = _ad;
    if (!_loaded || ad == null) {
      return Container(height: navBarHeight, color: AppColors.background);
    }

    return Container(
      padding: EdgeInsets.only(bottom: navBarHeight),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
