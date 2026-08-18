import 'palan_data_1.dart';
import 'palan_data_2.dart';
import 'palan_data_3.dart';
import 'palan_model.dart';

export 'palan_model.dart';

/// सभी पालन एक जगह।
///
/// क्रम जान-बूझकर ऐसा है: **गाय और भैंस सबसे ऊपर**, क्योंकि भारत में सबसे
/// ज़्यादा पशुपालक यही करते हैं। पहले ये गाइड में थे ही नहीं — वहाँ सिर्फ़
/// कैलकुलेटर थे (मेरे पशु, गाभिन, आहार), पर नस्ल/आवास/टीका/बीमारी/लागत की
/// पूरी जानकारी कहीं नहीं थी।
///
/// उसके बाद बाक़ी — सबसे आम और कम लागत वाले पहले।
final List<PalanGuide> kPalanGuides = [
  ...kPalanPart3, // गाय, भैंस
  ...kPalanPart1,
  ...kPalanPart2,
];

PalanGuide? palanById(String id) {
  for (final g in kPalanGuides) {
    if (g.id == id) return g;
  }
  return null;
}
