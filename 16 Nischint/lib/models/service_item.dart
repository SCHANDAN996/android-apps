import 'package:flutter/material.dart';

/// सवाल-जवाब की एक जोड़ी।
class Faq {
  const Faq(this.question, this.answer);

  final String question;
  final String answer;
}

/// एक सेवा जो ऐप में दिखती है। [available] false हो तो "जल्द आ रहा है"।
class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.title,
    required this.shortLine,
    required this.icon,
    required this.priceFrom,
    required this.priceLabel,
    this.priceNote = '',
    this.duration = '',
    this.includes = const [],
    this.faqs = const [],
    this.available = true,
    this.needsProblem = false,
    this.extraPerKwAbove3 = 0,
  });

  /// स्थायी पहचान, बुकिंग में सेव होती है। बदलें नहीं।
  final String id;
  final String title;
  final String shortLine;
  final IconData icon;

  /// सबसे कम रेट रुपये में (गिनती के लिए)।
  final int priceFrom;

  /// दिखाने वाला रेट, जैसे "₹600 से"।
  final String priceLabel;
  final String priceNote;
  final String duration;
  final List<String> includes;
  final List<Faq> faqs;
  final bool available;

  /// बुकिंग में "दिक्कत क्या है" पूछना है या नहीं (रिपेयर के लिए)।
  final bool needsProblem;

  /// 3 kW से बड़े सिस्टम पर हर अतिरिक्त kW का रेट (0 = कोई नहीं)।
  final int extraPerKwAbove3;

  /// सिस्टम के kW के हिसाब से अनुमानित रेट।
  int estimateFor(int kw) {
    if (extraPerKwAbove3 <= 0 || kw <= 3) return priceFrom;
    return priceFrom + (kw - 3) * extraPerKwAbove3;
  }
}
