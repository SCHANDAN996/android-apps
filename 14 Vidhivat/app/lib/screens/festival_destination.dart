import 'package:flutter/material.dart';

import '../vidhi/aane_wale_din.dart' show tyoharKaVrat, tyoharKiPuja;
import 'vidhi_screen.dart';
import 'vrat_panna_screen.dart';

/// अपना पन्ना न हो तो event केवल तारीख़ की तरह दिखे, नक़ली विधि न खुले।
/// विधि न हो पर व्रत-पन्ना हो (शरद पूर्णिमा), तो वह (→ D-130)।
Widget? festivalDestination(String name) {
  final vidhiId = tyoharKiPuja[name];
  if (vidhiId != null) return VidhiScreen(id: vidhiId);
  final vratId = tyoharKaVrat[name];
  return vratId == null ? null : VratPannaScreen(id: vratId);
}
