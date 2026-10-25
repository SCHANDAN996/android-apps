import 'package:flutter/foundation.dart';

/// मुख्य पन्ने (`HomeShell`) का कौन-सा tab खुले — किसी और पन्ने से माँगने के लिए।
///
/// पूजा पूरी होने पर «होम पर लौटें» `popUntil(isFirst)` करता था, पर `HomeShell`
/// पहले चुना tab याद रखता है — पूजा «पूजा» tab से शुरू हुई हो तो लौटकर होम की जगह
/// पूजा-सूची दिखती थी (UX-017, फ़ोन पर पकड़ा गया)। बटन का नाम वही करे जो कहता है।
class ShellTabMaang extends ChangeNotifier {
  int? _maanga;

  /// [index] वाला tab खोलने की माँग — `HomeShell` सुनता है।
  void maango(int index) {
    _maanga = index;
    notifyListeners();
  }

  /// माँगा हुआ tab, एक ही बार — लेने के बाद माँग ख़त्म।
  int? lo() {
    final i = _maanga;
    _maanga = null;
    return i;
  }
}

final shellTabMaang = ShellTabMaang();

/// `HomeShell` में होम वाला tab।
const int homeTab = 0;
