import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Small, quiet motion used across the app. Everything here switches itself
/// off when the phone asks for reduced motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Fades its child in while it rises a few pixels — the "answer is ready"
/// moment on a calculator screen.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;

  /// Share of [duration] to wait before starting (0–1), for staggering.
  final double delayFraction;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 380),
    this.delayFraction = 0,
    this.offsetY = 16,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _ctrl,
    curve: Interval(widget.delayFraction, 1, curve: Curves.easeOutCubic),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotion(context)) {
      _ctrl.value = 1;
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, widget.offsetY * (1 - _t.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Home-screen cards arrive one after another — but only the first time the
/// app opens, never again on a rebuild or when coming back to Home.
class StaggerIn extends StatelessWidget {
  final int index;
  final Widget child;

  const StaggerIn({super.key, required this.index, required this.child});

  static bool _played = false;
  static const int _stepMs = 40;
  static const int _moveMs = 300;

  /// Wraps each child with its position in the sequence.
  static List<Widget> wrapAll(List<Widget> children) => [
    for (var i = 0; i < children.length; i++)
      StaggerIn(index: i, child: children[i]),
  ];

  @override
  Widget build(BuildContext context) {
    if (_played || reduceMotion(context)) return child;
    // The flag flips after this first frame, so every card built in it still
    // animates and anything built later appears at once.
    WidgetsBinding.instance.addPostFrameCallback((_) => _played = true);
    final total = _moveMs + index * _stepMs;
    return FadeSlideIn(
      duration: Duration(milliseconds: total),
      delayFraction: index * _stepMs / total,
      offsetY: 14,
      child: child,
    );
  }
}

/// Shrinks its child a touch while a finger is on it.
class PressScale extends StatefulWidget {
  final Widget child;
  const PressScale({super.key, required this.child});

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !reduceMotion(context) ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A number that counts up from zero to [value].
class CountUpText extends StatelessWidget {
  final double value;
  final String Function(double value) format;
  final TextStyle? style;

  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: reduceMotion(context)
          ? Duration.zero
          : const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(format(v), style: style),
    );
  }
}

/// Horizontal offset for a short "no, not that" shake. [t] runs 0 → 1.
double shakeOffset(double t) => math.sin(t * math.pi * 6) * 6 * (1 - t);
