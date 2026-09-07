import 'package:flutter/material.dart';

const libraryTeal = Color(0xFF0F766E);
const libraryGold = Color(0xFFC6943F);

enum ScreenKind { setup, prayer, qibla, content, tracker, setting, system }

class IbadatiScreenSpec {
  const IbadatiScreenSpec({
    required this.id,
    required this.title,
    required this.group,
    required this.kind,
    required this.icon,
    required this.summary,
    required this.primary,
  });
  final String id;
  final String title;
  final String group;
  final ScreenKind kind;
  final IconData icon;
  final String summary;
  final String primary;
}

const ibadatiScreenSpecs = <IbadatiScreenSpec>[
  IbadatiScreenSpec(id: 'onboarding', title: 'Welcome onboarding', group: 'Setup', kind: ScreenKind.setup, icon: Icons.waving_hand_outlined, summary: 'Ibadati का purpose और तीन core benefits।', primary: 'Get started'),
  IbadatiScreenSpec(id: 'location-setup', title: 'Location setup', group: 'Setup', kind: ScreenKind.setup, icon: Icons.location_on_outlined, summary: 'Prayer times और Qibla के लिए location permission।', primary: 'Use my location'),
  IbadatiScreenSpec(id: 'prayer-setup', title: 'Prayer setup', group: 'Setup', kind: ScreenKind.setup, icon: Icons.access_time_outlined, summary: 'Calculation method, madhhab और alerts चुनें।', primary: 'Save prayer setup'),
  IbadatiScreenSpec(id: 'permissions', title: 'Permissions', group: 'Setup', kind: ScreenKind.setup, icon: Icons.security_outlined, summary: 'Location और notification permission status।', primary: 'Continue'),
  IbadatiScreenSpec(id: 'home-dashboard', title: 'Home dashboard', group: 'Daily worship', kind: ScreenKind.prayer, icon: Icons.home_outlined, summary: 'Next prayer, daily schedule और quick actions।', primary: 'View all prayer times'),
  IbadatiScreenSpec(id: 'prayer-times', title: 'Prayer times', group: 'Daily worship', kind: ScreenKind.prayer, icon: Icons.schedule, summary: 'आज का prayer schedule और per-prayer alert switch।', primary: 'Calculation settings'),
  IbadatiScreenSpec(id: 'prayer-adjustments', title: 'Prayer adjustments', group: 'Daily worship', kind: ScreenKind.prayer, icon: Icons.tune, summary: 'Calculation method और manual time offset।', primary: 'Save adjustments'),
  IbadatiScreenSpec(id: 'adhan-settings', title: 'Adhan settings', group: 'Daily worship', kind: ScreenKind.prayer, icon: Icons.notifications_active_outlined, summary: 'Adhan sound, vibration और alert preferences।', primary: 'Test notification'),
  IbadatiScreenSpec(id: 'adhan-alert', title: 'Adhan alert', group: 'Daily worship', kind: ScreenKind.prayer, icon: Icons.notifications_none, summary: 'Prayer time आने पर calm full-screen alert।', primary: 'Open prayer details'),
  IbadatiScreenSpec(id: 'notification-help', title: 'Notification help', group: 'Daily worship', kind: ScreenKind.system, icon: Icons.notification_important_outlined, summary: 'Android notification issue का step-by-step fix।', primary: 'Open app settings'),
  IbadatiScreenSpec(id: 'qibla', title: 'Qibla compass', group: 'Daily worship', kind: ScreenKind.qibla, icon: Icons.explore_outlined, summary: 'Makkah direction, degrees और location context।', primary: 'Calibrate compass'),
  IbadatiScreenSpec(id: 'qibla-calibration', title: 'Qibla calibration', group: 'Daily worship', kind: ScreenKind.qibla, icon: Icons.compass_calibration, summary: 'Compass accuracy सुधारने की guided motion।', primary: 'Start calibration'),
  IbadatiScreenSpec(id: 'explore', title: 'Explore', group: 'Content', kind: ScreenKind.content, icon: Icons.grid_view_outlined, summary: 'सभी worship features का organized entry point।', primary: 'Open feature'),
  IbadatiScreenSpec(id: 'duas-library', title: 'Duas library', group: 'Content', kind: ScreenKind.content, icon: Icons.menu_book_outlined, summary: 'Duas और Azkar categories की searchable library।', primary: 'Open dua'),
  IbadatiScreenSpec(id: 'dua-reader', title: 'Dua reader', group: 'Content', kind: ScreenKind.content, icon: Icons.auto_stories_outlined, summary: 'Arabic, transliteration, translation, audio और save।', primary: 'Save dua'),
  IbadatiScreenSpec(id: 'azkar-session', title: 'Azkar session', group: 'Content', kind: ScreenKind.content, icon: Icons.repeat, summary: 'Morning/evening Azkar के लिए guided count session।', primary: 'Start session'),
  IbadatiScreenSpec(id: 'global-search', title: 'Global search', group: 'Content', kind: ScreenKind.content, icon: Icons.search, summary: 'Hindi, Urdu और English में universal search।', primary: 'Search'),
  IbadatiScreenSpec(id: 'search-empty', title: 'Search empty state', group: 'Content', kind: ScreenKind.system, icon: Icons.search_off, summary: 'Result न मिलने पर language suggestions।', primary: 'Try suggestion'),
  IbadatiScreenSpec(id: 'saved', title: 'Saved content', group: 'Content', kind: ScreenKind.content, icon: Icons.bookmark_outline, summary: 'Saved duas, Azkar और useful content।', primary: 'Open saved item'),
  IbadatiScreenSpec(id: 'saved-empty', title: 'Saved empty state', group: 'Content', kind: ScreenKind.system, icon: Icons.bookmark_border, summary: 'पहली बार कोई item save न होने का state।', primary: 'Explore duas & azkar'),
  IbadatiScreenSpec(id: 'tasbih', title: 'Tasbih counter', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.touch_app_outlined, summary: 'Dhikr count, goal, reset और history entry।', primary: 'Tap to count'),
  IbadatiScreenSpec(id: 'tasbih-history', title: 'Tasbih history', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.history, summary: 'Recent dhikr sessions और completion record।', primary: 'Start new tasbih'),
  IbadatiScreenSpec(id: 'ramadan', title: 'Ramadan dashboard', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.nightlight_outlined, summary: 'Iftar countdown, calendar और fast progress।', primary: 'Log today’s fast'),
  IbadatiScreenSpec(id: 'ramadan-calendar', title: 'Ramadan calendar', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.calendar_month, summary: 'पूरे Ramadan के fast status का calendar view।', primary: 'Select a day'),
  IbadatiScreenSpec(id: 'fast-log', title: 'Fast log', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.check_circle_outline, summary: 'आज का fast completed, missed या exempt mark करें।', primary: 'Save fast status'),
  IbadatiScreenSpec(id: 'fast-history', title: 'Fast & Qaza history', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.history_toggle_off, summary: 'Ramadan record, missed fast और Qaza completion।', primary: 'Mark Qaza complete'),
  IbadatiScreenSpec(id: 'zakat', title: 'Zakat calculator', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.calculate_outlined, summary: 'Assets, liabilities और 2.5% estimate।', primary: 'Calculate zakat'),
  IbadatiScreenSpec(id: 'zakat-result', title: 'Zakat result', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.currency_rupee, summary: 'Calculation result, assumptions और save action।', primary: 'Save calculation'),
  IbadatiScreenSpec(id: 'zakat-history', title: 'Zakat history', group: 'Trackers', kind: ScreenKind.tracker, icon: Icons.account_balance_wallet_outlined, summary: 'Past calculations, payment record और next review।', primary: 'Mark as paid'),
  IbadatiScreenSpec(id: 'profile', title: 'Profile', group: 'Settings', kind: ScreenKind.setting, icon: Icons.person_outline, summary: 'User worship space और personal shortcuts।', primary: 'Manage profile'),
  IbadatiScreenSpec(id: 'language-region', title: 'Language & region', group: 'Settings', kind: ScreenKind.setting, icon: Icons.language, summary: 'Hindi, اردو और English language selection।', primary: 'Save language'),
  IbadatiScreenSpec(id: 'location-search', title: 'Location search', group: 'Settings', kind: ScreenKind.setting, icon: Icons.travel_explore, summary: 'City या country search करके timezone select करें।', primary: 'Use this location'),
  IbadatiScreenSpec(id: 'offline-downloads', title: 'Offline downloads', group: 'Settings', kind: ScreenKind.setting, icon: Icons.download_outlined, summary: 'Duas/Azkar packs को device में रखें।', primary: 'Download essentials'),
  IbadatiScreenSpec(id: 'appearance', title: 'Appearance', group: 'Settings', kind: ScreenKind.setting, icon: Icons.dark_mode_outlined, summary: 'System, light/dark mode और text comfort।', primary: 'Apply appearance'),
  IbadatiScreenSpec(id: 'widget-setup', title: 'Widget setup', group: 'Settings', kind: ScreenKind.setting, icon: Icons.widgets_outlined, summary: 'Home-screen prayer widget का configuration।', primary: 'Add widget'),
  IbadatiScreenSpec(id: 'privacy-data', title: 'Privacy & data', group: 'Settings', kind: ScreenKind.setting, icon: Icons.privacy_tip_outlined, summary: 'Analytics, local records और privacy choices।', primary: 'Save privacy choices'),
  IbadatiScreenSpec(id: 'help-feedback', title: 'Help & feedback', group: 'Settings', kind: ScreenKind.setting, icon: Icons.help_outline, summary: 'Help articles, feedback और translation report।', primary: 'Send securely'),
  IbadatiScreenSpec(id: 'about-privacy', title: 'About, terms & privacy', group: 'Settings', kind: ScreenKind.setting, icon: Icons.info_outline, summary: 'Version, legal documents और app information।', primary: 'Open privacy policy'),
  IbadatiScreenSpec(id: 'network-state', title: 'Loading & offline state', group: 'System states', kind: ScreenKind.system, icon: Icons.wifi_off_outlined, summary: 'Skeleton loading, no internet और retry action।', primary: 'Retry connection'),
  IbadatiScreenSpec(id: 'location-unavailable', title: 'Location unavailable', group: 'System states', kind: ScreenKind.system, icon: Icons.location_off_outlined, summary: 'Permission fail होने पर manual city fallback।', primary: 'Choose city manually'),
  IbadatiScreenSpec(id: 'action-confirmed', title: 'Action confirmed', group: 'System states', kind: ScreenKind.system, icon: Icons.check_circle_outline, summary: 'Fast, Zakat या setting save होने के बाद confirmation।', primary: 'Back to home'),
];

class ScreenLibraryPage extends StatefulWidget {
  const ScreenLibraryPage({super.key});
  @override
  State<ScreenLibraryPage> createState() => _ScreenLibraryPageState();
}

class _ScreenLibraryPageState extends State<ScreenLibraryPage> {
  String group = 'All';
  @override
  Widget build(BuildContext context) {
    final groups = <String>['All', ...{for (final item in ibadatiScreenSpecs) item.group}];
    final screens = group == 'All' ? ibadatiScreenSpecs : ibadatiScreenSpecs.where((item) => item.group == group).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('All Ibadati screens')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('यहां हर design एक functional Flutter page के रूप में मौजूद है।'),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: groups.map((item) => ChoiceChip(label: Text(item), selected: group == item, onSelected: (_) => setState(() => group = item))).toList()),
        const SizedBox(height: 18),
        Text('${screens.length} screens', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...screens.map((screen) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Card(child: ListTile(
          leading: CircleAvatar(backgroundColor: const Color(0x1F0F766E), child: Icon(screen.icon, color: libraryTeal)),
          title: Text(screen.title),
          subtitle: Text(screen.summary),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IbadatiDetailPage(spec: screen))),
        )))),
      ]),
    );
  }
}

class IbadatiDetailPage extends StatefulWidget {
  const IbadatiDetailPage({super.key, required this.spec});
  final IbadatiScreenSpec spec;
  @override
  State<IbadatiDetailPage> createState() => _IbadatiDetailPageState();
}

class _IbadatiDetailPageState extends State<IbadatiDetailPage> {
  bool enabled = true;
  bool completed = false;
  int selected = 0;
  final cityController = TextEditingController(text: 'New Delhi, India');
  final feedbackController = TextEditingController();
  @override
  void dispose() { cityController.dispose(); feedbackController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.spec.title)),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 30), children: [
      _hero(),
      const SizedBox(height: 20),
      _body(),
      const SizedBox(height: 22),
      FilledButton.icon(onPressed: _primary, icon: Icon(completed ? Icons.check : widget.spec.icon), label: Text(completed ? 'Saved' : widget.spec.primary)),
      if (completed) Padding(padding: const EdgeInsets.only(top: 12), child: _confirmation()),
    ]),
  );

  Widget _hero() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: libraryTeal, borderRadius: BorderRadius.circular(22)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(widget.spec.icon, color: Colors.white, size: 34),
      const SizedBox(height: 14),
      Text(widget.spec.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(widget.spec.summary, style: const TextStyle(color: Colors.white70)),
    ]),
  );

  Widget _body() => switch (widget.spec.kind) {
    ScreenKind.setup => _setupBody(),
    ScreenKind.prayer => _prayerBody(),
    ScreenKind.qibla => _qiblaBody(),
    ScreenKind.content => _contentBody(),
    ScreenKind.tracker => _trackerBody(),
    ScreenKind.setting => _settingBody(),
    ScreenKind.system => _systemBody(),
  };

  Widget _setupBody() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('A respectful, optional setup flow. You can continue with manual choices at any time.'),
    const SizedBox(height: 18),
    ...['Choose language', 'Set your city', 'Review permissions'].asMap().entries.map((item) => Card(child: RadioListTile<int>(value: item.key, groupValue: selected, onChanged: (value) => setState(() => selected = value ?? 0), title: Text(item.value), subtitle: Text(item.key == 1 ? 'Prayer times and Qibla use your selected location.' : 'You stay in control.')))),
  ]);

  Widget _prayerBody() {
    if (widget.spec.id == 'adhan-alert') return const Center(child: Padding(padding: EdgeInsets.all(18), child: Column(children: [Icon(Icons.notifications_active, size: 72, color: libraryGold), SizedBox(height: 14), Text('Maghrib time', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)), Text('6:41 PM · New Delhi')] )));
    if (widget.spec.id == 'prayer-adjustments') return Column(children: [const _InfoRow(icon: Icons.calculate_outlined, title: 'Calculation method', subtitle: 'University of Islamic Sciences, Karachi'), const _InfoRow(icon: Icons.schedule, title: 'Asr juristic method', subtitle: 'Hanafi'), Slider(value: selected.toDouble(), max: 10, divisions: 10, label: '${selected - 5} min', onChanged: (value) => setState(() => selected = value.round()))]);
    return Column(children: [
      const _InfoRow(icon: Icons.location_on_outlined, title: 'New Delhi, India', subtitle: 'Tuesday · 12 Ramadan 1448'),
      ...['Fajr · 5:08 AM', 'Dhuhr · 12:24 PM', 'Asr · 4:48 PM', 'Maghrib · 6:41 PM', 'Isha · 8:02 PM'].map((item) => Card(child: SwitchListTile(value: enabled, onChanged: (value) => setState(() => enabled = value), title: Text(item), subtitle: const Text('Prayer alert enabled')))),
    ]);
  }

  Widget _qiblaBody() => Column(children: [
    Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, color: libraryTeal.withOpacity(.08), border: Border.all(color: libraryTeal, width: 10)), child: Transform.rotate(angle: .65, child: const Icon(Icons.navigation, size: 110, color: libraryGold))),
    const SizedBox(height: 18),
    Text(widget.spec.id == 'qibla-calibration' ? 'Move phone in a figure 8' : 'Qibla · 266° NW', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    Text(widget.spec.id == 'qibla-calibration' ? 'Keep away from magnets and metal surfaces.' : '3,828 km from Makkah'),
    if (widget.spec.id == 'qibla-calibration') ...[const SizedBox(height: 18), LinearProgressIndicator(value: completed ? 1 : .42, color: libraryTeal)],
  ]);

  Widget _contentBody() {
    if (widget.spec.id == 'dua-reader') return const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Card(child: Padding(padding: EdgeInsets.all(20), child: Text('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ', textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontSize: 27, height: 1.8)))), SizedBox(height: 14), Text('Transliteration'), Text('Verified transliteration is supplied through the reviewed local content pack.'), SizedBox(height: 14), OutlinedButton.icon(onPressed: null, icon: Icon(Icons.volume_up_outlined), label: Text('Audio pack required'))]);
    if (widget.spec.id == 'global-search') return TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search in Hindi, Urdu or English'));
    if (widget.spec.id == 'azkar-session') return Column(children: [const Text('Morning Azkar · 3 of 10'), const SizedBox(height: 12), LinearProgressIndicator(value: .3, color: libraryTeal), const SizedBox(height: 24), const Text('سُبْحَانَ اللَّهِ', style: TextStyle(fontSize: 30)), const SizedBox(height: 12), Wrap(spacing: 8, children: [1, 3, 5].map((value) => ChoiceChip(label: Text('$value'), selected: selected == value, onSelected: (_) => setState(() => selected = value))).toList())]);
    return Column(children: ['Morning remembrance', 'Before sleeping', 'For travel'].map((item) => Card(child: ListTile(leading: const Icon(Icons.menu_book_outlined, color: libraryTeal), title: Text(item), subtitle: const Text('Arabic · transliteration · translation'), trailing: const Icon(Icons.chevron_right)))).toList());
  }

  Widget _trackerBody() {
    if (widget.spec.id == 'tasbih') return Column(children: [const Text('سُبْحَانَ اللَّهِ', style: TextStyle(fontSize: 30)), const SizedBox(height: 18), GestureDetector(onTap: () => setState(() => selected++), child: Container(width: 180, height: 180, alignment: Alignment.center, decoration: const BoxDecoration(shape: BoxShape.circle, color: libraryTeal), child: Text('$selected', style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w700)))), const SizedBox(height: 14), const Text('Tap to count · Goal 33')]);
    if (widget.spec.id.contains('zakat')) return Column(children: [const _InfoRow(icon: Icons.currency_rupee, title: 'Eligible assets', subtitle: '₹12,50,000'), const _InfoRow(icon: Icons.remove_circle_outline, title: 'Short-term liabilities', subtitle: '₹3,00,000'), Card(color: libraryTeal, child: const Padding(padding: EdgeInsets.all(20), child: Column(children: [Text('Estimated Zakat due', style: TextStyle(color: Colors.white70)), Text('₹23,750', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700))])))]);
    if (widget.spec.id.contains('fast') || widget.spec.id.contains('ramadan')) return Column(children: [const _InfoRow(icon: Icons.nightlight_outlined, title: '12 Ramadan 1448', subtitle: 'Iftar · 6:41 PM'), GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 6, mainAxisSpacing: 7, crossAxisSpacing: 7, children: List.generate(30, (index) => InkWell(onTap: () => setState(() => selected = index), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: selected == index ? libraryTeal : Colors.black12, borderRadius: BorderRadius.circular(9)), child: Text('${index + 1}', style: TextStyle(color: selected == index ? Colors.white : null)))))]);
    return Column(children: [const _InfoRow(icon: Icons.check_circle_outline, title: 'Today’s goal', subtitle: '33 repetitions completed'), const _InfoRow(icon: Icons.history, title: 'Yesterday', subtitle: '99 repetitions'), const _InfoRow(icon: Icons.local_fire_department_outlined, title: 'Current streak', subtitle: '4 days')]);
  }

  Widget _settingBody() {
    if (widget.spec.id == 'location-search') return Column(children: [TextField(controller: cityController, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search city or country')), const SizedBox(height: 12), const _InfoRow(icon: Icons.location_city, title: 'New Delhi, India', subtitle: 'Asia/Kolkata · UTC +05:30')]);
    if (widget.spec.id == 'language-region') return Column(children: ['English', 'हिन्दी', 'اردو'].asMap().entries.map((item) => Card(child: RadioListTile<int>(value: item.key, groupValue: selected, onChanged: (value) => setState(() => selected = value ?? 0), title: Text(item.value)))).toList());
    if (widget.spec.id == 'appearance') return Column(children: ['System', 'Light', 'Dark'].asMap().entries.map((item) => Card(child: RadioListTile<int>(value: item.key, groupValue: selected, onChanged: (value) => setState(() => selected = value ?? 0), title: Text(item.value)))).toList());
    if (widget.spec.id == 'help-feedback') return Column(children: [const _InfoRow(icon: Icons.help_outline, title: 'Help articles', subtitle: 'Prayer times, Qibla and offline packs'), const _InfoRow(icon: Icons.translate, title: 'Report translation', subtitle: 'Help us correct content'), const SizedBox(height: 12), TextField(controller: feedbackController, maxLines: 4, decoration: const InputDecoration(labelText: 'Your feedback'))]);
    if (widget.spec.id == 'about-privacy') return const Column(children: [_InfoRow(icon: Icons.mosque_outlined, title: 'Ibadati', subtitle: 'Version 1.0.0 MVP'), _InfoRow(icon: Icons.policy_outlined, title: 'Privacy policy', subtitle: 'How your data is handled'), _InfoRow(icon: Icons.gavel_outlined, title: 'Terms of use', subtitle: 'Conditions for using Ibadati')]);
    return Column(children: [SwitchListTile(value: enabled, onChanged: (value) => setState(() => enabled = value), title: Text(widget.spec.id == 'offline-downloads' ? 'Download essentials for offline use' : 'Keep this preference enabled'), subtitle: Text(widget.spec.id == 'privacy-data' ? 'Anonymous diagnostics are optional.' : 'You can change this anytime.')), const _InfoRow(icon: widget.spec.icon, title: 'Your choice', subtitle: widget.spec.summary)]);
  }

  Widget _systemBody() {
    if (widget.spec.id == 'network-state') return Column(children: [const LinearProgressIndicator(color: libraryTeal), const SizedBox(height: 24), const Icon(Icons.wifi_off_outlined, size: 58, color: libraryTeal), const SizedBox(height: 14), const Text('You are offline', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('Your saved duas and records remain available.')]);
    if (widget.spec.id == 'action-confirmed') return const Column(children: [Icon(Icons.check_circle, color: libraryTeal, size: 74), SizedBox(height: 14), Text('Saved successfully', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)), SizedBox(height: 8), Text('Your record was saved. You can undo this action.')]);
    if (widget.spec.id == 'saved-empty' || widget.spec.id == 'search-empty') return Column(children: [Icon(widget.spec.icon, size: 68, color: libraryTeal), const SizedBox(height: 14), Text(widget.spec.id == 'saved-empty' ? 'Nothing saved yet' : 'No results found', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('Try another search or explore suggested content.', textAlign: TextAlign.center)]);
    return Column(children: [Icon(widget.spec.icon, size: 66, color: libraryTeal), const SizedBox(height: 16), const Text('A quick fix is available', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)), const SizedBox(height: 16), const _InfoRow(icon: Icons.looks_one_outlined, title: 'Check permission', subtitle: 'Allow the required Android permission.'), const _InfoRow(icon: Icons.looks_two_outlined, title: 'Try again', subtitle: 'Retry or choose the manual fallback.')]);
  }

  void _primary() {
    setState(() => completed = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.spec.title} saved')));
  }
  Widget _confirmation() => Row(children: [const Icon(Icons.check_circle, color: libraryTeal), const SizedBox(width: 8), Expanded(child: Text('${widget.spec.title} action completed.'))]);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: ListTile(leading: Icon(icon, color: libraryTeal), title: Text(title), subtitle: Text(subtitle))));
}
