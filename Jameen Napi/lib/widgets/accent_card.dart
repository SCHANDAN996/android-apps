import 'package:flutter/material.dart';

/// नतीजों वाला सफ़ेद कार्ड जिसकी बाईं तरफ़ रंगीन पट्टी होती है।
///
/// पहले हर स्क्रीन में यह ऐसे बनाया जाता था:
///
/// ```dart
/// BoxDecoration(
///   borderRadius: BorderRadius.only(...),
///   border: Border(
///     left: BorderSide(color: green, width: 4.5),   // बाईं तरफ़ हरा
///     top: BorderSide(color: grey, width: 1),       // बाकी तीनों grey
///     ...
///   ),
/// )
/// ```
///
/// Flutter गोल कोनों वाले `Border` में सब तरफ़ एक ही रंग माँगता है। रंग अलग-अलग
/// होने पर debug build में paint के वक़्त assertion फटती है
/// ("A borderRadius can only be given on borders with uniform colors"), और
/// release में गोल कोने चुपचाप लगते ही नहीं। इसलिए यहाँ पट्टी border से नहीं,
/// एक अलग Container से बनती है और पूरा कार्ड ClipRRect में कटता है — दिखता वही
/// है, पर सही तरीक़े से।
class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.child,
    this.accentColor = const Color(0xFF2E7D32),
    this.accentWidth = 4.5,
    this.margin = const EdgeInsets.only(bottom: 8),
    this.borderRadius = 12,
    this.background = Colors.white,
    this.borderColor,
  });

  final Widget child;
  final Color accentColor;
  final double accentWidth;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: Radius.circular(borderRadius / 3),
      bottomLeft: Radius.circular(borderRadius / 3),
      topRight: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: accentWidth, color: accentColor),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
