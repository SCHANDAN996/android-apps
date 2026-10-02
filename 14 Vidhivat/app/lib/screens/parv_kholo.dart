import 'package:flutter/material.dart';

import '../state/settings.dart';
import '../vidhi/parv.dart';
import '../vidhi/parv_aaj.dart';
import 'parv_screen.dart';
import 'vidhi_screen.dart';

/// नवरात्रि का पर्व-पन्ना खोलो — होम का slider और पूजा की सूची, दोनों
/// यहीं से खोलते हैं, ताकि "आज" और शहर एक ही जगह से गिने जाएँ (→ D-074)।
void kholoNavratri(BuildContext context, Parv parv) {
  final navigator = Navigator.of(context);
  navigator.push(
    MaterialPageRoute(
      builder: (_) => ParvScreen(
        parv: parv,
        aaj: navratriAaj(aaj: DateTime.now(), place: settings.place),
        onVidhiKholo: (id) => navigator.push(
          MaterialPageRoute(builder: (_) => VidhiScreen(id: id)),
        ),
      ),
    ),
  );
}
