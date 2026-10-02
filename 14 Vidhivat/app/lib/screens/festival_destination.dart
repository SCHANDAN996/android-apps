import 'package:flutter/material.dart';

import '../vidhi/aane_wale_din.dart' show tyoharKiPuja;
import 'vidhi_screen.dart';

/// अपना पन्ना न हो तो event केवल तारीख़ की तरह दिखे, नक़ली विधि न खुले।
Widget? festivalDestination(String name) {
  final vidhiId = tyoharKiPuja[name];
  return vidhiId == null ? null : VidhiScreen(id: vidhiId);
}
