import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/foundation.dart';

class ReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;

  /// Request a review if available.
  static Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (e) {
      debugPrint('Error requesting in-app review: $e');
    }
  }
}
