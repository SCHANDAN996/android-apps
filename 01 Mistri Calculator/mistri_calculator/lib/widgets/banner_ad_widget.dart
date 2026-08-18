import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/services/ad_service.dart';

/// A self-contained bottom banner ad. Loads on mount, shows nothing until the
/// ad is ready (so no empty grey box), and disposes itself automatically.
/// Drop it into a Scaffold as `bottomNavigationBar: const BannerAdWidget()`.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final ad = AdService().createBannerAd(
      onLoaded: () {
        if (mounted) setState(() => _loaded = true);
      },
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
