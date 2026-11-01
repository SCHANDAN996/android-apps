import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/theme.dart';
import '../content/config.dart';
import '../models/profiles.dart';
import '../widgets/common.dart';

/// पहली बार ऐप खोलने पर 3 स्लाइड। "छोड़ें" या "शुरू करें" दबाने पर
/// RootGate अपने-आप होम स्क्रीन दिखा देता है।
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.line,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String title;
  final String line;
  final Color color;
  final Color background;
}

const List<_Slide> _slides = [
  _Slide(
    icon: Icons.solar_power,
    title: 'सोलर की सफ़ाई और जाँच, घर पर',
    line: 'बस 3 टैप में बुकिंग। तय रेट, और पैसा काम के बाद।',
    color: AppColors.sun,
    background: AppColors.sunSoft,
  ),
  _Slide(
    icon: Icons.schedule,
    title: 'शिकायत 48 घंटे में',
    line: 'बिजली कम बने या इन्वर्टर बंद हो, 48 घंटे के अंदर हमारा टेक्नीशियन आपके घर।',
    color: AppColors.primary,
    background: AppColors.primarySoft,
  ),
  _Slide(
    icon: Icons.photo_camera,
    title: 'हर काम का फ़ोटो सबूत',
    line: 'काम से पहले और बाद की फ़ोटो सीधे आपके WhatsApp पर।',
    color: AppColors.success,
    background: AppColors.successSoft,
  ),
];

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  bool _finishing = false;

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await AppScope.read(context).completeOnboarding(AppRole.customer);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.s, AppSpace.s, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      AppConfig.appName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !_isLast,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: _finishing ? null : _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('छोड़ें'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            _Dots(count: _slides.length, current: _page),
            const SizedBox(height: AppSpace.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
              child: AppButton(
                label: _isLast ? 'शुरू करें' : 'आगे',
                icon: _isLast ? Icons.check : Icons.arrow_forward,
                onPressed: _finishing ? null : _next,
              ),
            ),
            const SizedBox(height: AppSpace.l),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl, vertical: AppSpace.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 168,
              height: 168,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: slide.background, shape: BoxShape.circle),
              child: Container(
                width: 112,
                height: 112,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
                child: Icon(slide.icon, size: 60, color: slide.color),
              ),
            ),
            const SizedBox(height: AppSpace.xxl),
            Text(slide.title, textAlign: TextAlign.center, style: AppText.h1),
            const SizedBox(height: AppSpace.m),
            Text(
              slide.line,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, color: AppColors.textMuted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
