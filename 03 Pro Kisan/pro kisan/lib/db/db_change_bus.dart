import 'package:flutter/foundation.dart';

/// दूध वाले data (एंट्री / ग्राहक / भुगतान) में कोई भी बदलाव होते ही यह
/// notifier +1 हो जाता है। जो screen इसे सुन रही है वह अपने-आप ताज़ा data
/// ले लेती है — उपयोगकर्ता को page refresh नहीं करना पड़ता।
///
/// किसने बदला, कहाँ से बदला — इससे फ़र्क़ नहीं पड़ता: DAO की हर write
/// (insert/update/delete) और backup-restore के बाद [notifyDbChanged] चलता है।
final ValueNotifier<int> dbChangeBus = ValueNotifier<int>(0);

void notifyDbChanged() {
  dbChangeBus.value++;
}
