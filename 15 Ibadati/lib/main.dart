import 'package:flutter/material.dart';
import 'screen_library.dart';

void main() => runApp(const IbadatiApp());

const teal = Color(0xFF0F766E);
const gold = Color(0xFFB8893D);
const ivory = Color(0xFFF5F1E8);

class IbadatiApp extends StatefulWidget {
  const IbadatiApp({super.key});
  @override
  State<IbadatiApp> createState() => _IbadatiAppState();
}

class _IbadatiAppState extends State<IbadatiApp> {
  ThemeMode mode = ThemeMode.system;
  Locale locale = const Locale('en');

  void setLocale(Locale value) => setState(() => locale = value);
  void setTheme(ThemeMode value) => setState(() => mode = value);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: teal, brightness: Brightness.light);
    final dark = ColorScheme.fromSeed(seedColor: teal, brightness: Brightness.dark);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ibadati',
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('ur')],
      builder: (context, child) => Directionality(
        textDirection: locale.languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      themeMode: mode,
      theme: ThemeData(colorScheme: scheme, scaffoldBackgroundColor: ivory, useMaterial3: true, cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero)),
      darkTheme: ThemeData(colorScheme: dark, scaffoldBackgroundColor: const Color(0xFF101917), useMaterial3: true, cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero)),
      home: AppShell(locale: locale, onLocale: setLocale, mode: mode, onTheme: setTheme),
    );
  }
}

String tr(Locale locale, String en, String hi, String ur) => switch (locale.languageCode) {'hi' => hi, 'ur' => ur, _ => en};

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.locale, required this.onLocale, required this.mode, required this.onTheme});
  final Locale locale;
  final ValueChanged<Locale> onLocale;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onTheme;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [HomePage(locale: widget.locale), PrayerPage(locale: widget.locale), ExplorePage(locale: widget.locale), SettingsPage(locale: widget.locale, onLocale: widget.onLocale, mode: widget.mode, onTheme: widget.onTheme)];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr(widget.locale, 'Home', 'होम', 'ہوم')),
          NavigationDestination(icon: const Icon(Icons.access_time), label: tr(widget.locale, 'Prayer', 'नमाज़', 'نماز')),
          NavigationDestination(icon: const Icon(Icons.grid_view_outlined), label: tr(widget.locale, 'Explore', 'खोजें', 'دریافت')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: tr(widget.locale, 'Settings', 'सेटिंग', 'ترتیبات')),
        ],
      ),
    );
  }
}

class PagePad extends StatelessWidget {
  const PagePad({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [child]);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.locale});
  final Locale locale;
  @override
  Widget build(BuildContext context) => PagePad(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ibadati', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)), Text(tr(locale, 'Peace be upon you', 'अस्सलामु अलैकुम', 'السلام علیکم'))]), const CircleAvatar(child: Icon(Icons.person_outline))]),
    const SizedBox(height: 22),
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(24)), child: Column(children: [const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('NEXT PRAYER', style: TextStyle(color: Colors.white70)), Text('New Delhi', style: TextStyle(color: Colors.white70))]), const SizedBox(height: 16), const Text('Maghrib', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)), const Text('6:41 PM', style: TextStyle(color: Colors.white, fontSize: 38)), const SizedBox(height: 4), Text(tr(locale, 'in 1 hour 24 minutes', '1 घंटा 24 मिनट बाकी', '1 گھنٹہ 24 منٹ باقی'), style: const TextStyle(color: Colors.white70))])),
    const SizedBox(height: 20), Text(tr(locale, 'Today', 'आज', 'آج'), style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 10),
    const PrayerStrip(), const SizedBox(height: 20),
    GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6, children: [
      FeatureTile(icon: Icons.explore_outlined, title: tr(locale, 'Qibla', 'क़िबला', 'قبلہ'), page: const QiblaPage()),
      FeatureTile(icon: Icons.menu_book_outlined, title: tr(locale, 'Duas & Azkar', 'दुआ व अज़कार', 'دعائیں و اذکار'), page: const DuaPage()),
      FeatureTile(icon: Icons.touch_app_outlined, title: tr(locale, 'Tasbih', 'तस्बीह', 'تسبیح'), page: const TasbihPage()),
      FeatureTile(icon: Icons.nightlight_outlined, title: tr(locale, 'Ramadan', 'रमज़ान', 'رمضان'), page: const RamadanPage()),
    ])
  ]));
}

class PrayerStrip extends StatelessWidget {
  const PrayerStrip({super.key});
  @override
  Widget build(BuildContext context) {
    const values = [('Fajr','5:08'),('Dhuhr','12:24'),('Asr','4:48'),('Maghrib','6:41'),('Isha','8:02')];
    return Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: values.map((e) => Column(children: [Text(e.$1, style: const TextStyle(fontSize: 11)), const SizedBox(height: 5), Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w600))])).toList())));
  }
}

class FeatureTile extends StatelessWidget {
  const FeatureTile({super.key, required this.icon, required this.title, required this.page});
  final IconData icon; final String title; final Widget page;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Icon(icon, color: teal), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)))]))));
}

class PrayerPage extends StatefulWidget { const PrayerPage({super.key, required this.locale}); final Locale locale; @override State<PrayerPage> createState()=>_PrayerPageState(); }
class _PrayerPageState extends State<PrayerPage> {
  final enabled = <String,bool>{'Fajr':true,'Sunrise':false,'Dhuhr':true,'Asr':true,'Maghrib':true,'Isha':true};
  @override Widget build(BuildContext context)=>PagePad(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(tr(widget.locale,'Prayer times','नमाज़ का समय','نماز کے اوقات'),style:Theme.of(context).textTheme.headlineSmall),const Text('Tuesday · 12 Ramadan 1448',style:TextStyle(color:Colors.grey)),const SizedBox(height:18),...enabled.entries.map((e)=>Card(child:ListTile(leading:Icon(e.key=='Sunrise'?Icons.wb_sunny_outlined:Icons.nightlight_outlined,color:e.key=='Maghrib'?gold:teal),title:Text(e.key),subtitle:Text(switch(e.key){'Fajr'=>'5:08 AM','Sunrise'=>'6:27 AM','Dhuhr'=>'12:24 PM','Asr'=>'4:48 PM','Maghrib'=>'6:41 PM',_=>'8:02 PM'}),trailing:IconButton(onPressed:()=>setState(()=>enabled[e.key]=!e.value),icon:Icon(e.value?Icons.notifications_active:Icons.notifications_off_outlined))))),const SizedBox(height:12),FilledButton.icon(onPressed:()=>showModalBottomSheet(context:context,builder:(_)=>const Padding(padding:EdgeInsets.all(24),child:Text('Calculation: University of Islamic Sciences, Karachi\nAsr: Hanafi\nManual adjustments: enabled'))),icon:const Icon(Icons.tune),label:Text(tr(widget.locale,'Calculation settings','गणना सेटिंग','حساب کی ترتیب')))]));
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key, required this.locale}); final Locale locale;
  @override Widget build(BuildContext context)=>PagePad(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(tr(locale,'Explore','सभी फीचर','تمام خصوصیات'),style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:16),FeatureTile(icon:Icons.explore,title:tr(locale,'Qibla compass','क़िबला कम्पास','قبلہ کمپاس'),page:const QiblaPage()),const SizedBox(height:10),FeatureTile(icon:Icons.menu_book,title:tr(locale,'Duas & Azkar','दुआ एवं अज़कार','دعائیں و اذکار'),page:const DuaPage()),const SizedBox(height:10),FeatureTile(icon:Icons.touch_app,title:tr(locale,'Tasbih counter','तस्बीह काउंटर','تسبیح کاؤنٹر'),page:const TasbihPage()),const SizedBox(height:10),FeatureTile(icon:Icons.nightlight,title:tr(locale,'Ramadan tracker','रमज़ान ट्रैकर','رمضان ٹریکر'),page:const RamadanPage()),const SizedBox(height:10),FeatureTile(icon:Icons.calculate_outlined,title:tr(locale,'Zakat calculator','ज़कात कैलकुलेटर','زکوٰۃ کیلکولیٹر'),page:const ZakatPage()),const SizedBox(height:10),FeatureTile(icon:Icons.bookmark_outline,title:tr(locale,'Saved','सेव किया हुआ','محفوظ'),page:const SavedSupportPage()),const SizedBox(height:10),FeatureTile(icon:Icons.search,title:tr(locale,'Search','खोजें','تلاش'),page:const SearchSupportPage())]));
}

class QiblaPage extends StatelessWidget { const QiblaPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Qibla')),body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Container(width:250,height:250,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:teal,width:10)),child:Transform.rotate(angle:.65,child:const Icon(Icons.navigation,color:gold,size:100))),const SizedBox(height:24),const Text('Qibla · 266° NW',style:TextStyle(fontSize:24,fontWeight:FontWeight.w600)),const SizedBox(height:8),const Text('3,828 km from Makkah'),const SizedBox(height:24),const Padding(padding:EdgeInsets.symmetric(horizontal:30),child:Text('Demo compass preview. Connect the device magnetometer and calibration service before release.',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey))) ]))); }

class DuaPage extends StatelessWidget { const DuaPage({super.key}); @override Widget build(BuildContext context){const items=[('Morning remembrance','أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ'),('Before sleeping','بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا'),('For travel','سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا')];return Scaffold(appBar:AppBar(title:const Text('Duas & Azkar')),body:ListView(padding:const EdgeInsets.all(18),children:items.map((e)=>Card(child:ExpansionTile(title:Text(e.$1),childrenPadding:const EdgeInsets.all(18),children:[Text(e.$2,textDirection:TextDirection.rtl,style:const TextStyle(fontSize:25)),const SizedBox(height:12),const Text('Transliteration and verified translation content will be loaded from the local content database.'),const SizedBox(height:8),const Row(children:[Icon(Icons.bookmark_border),SizedBox(width:12),Icon(Icons.volume_up_outlined)] )]))).toList()));}}

class TasbihPage extends StatefulWidget { const TasbihPage({super.key}); @override State<TasbihPage> createState()=>_TasbihPageState(); }
class _TasbihPageState extends State<TasbihPage>{int count=0;@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Tasbih')),body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('سُبْحَانَ اللَّهِ',style:TextStyle(fontSize:30)),const SizedBox(height:8),const Text('SubhanAllah · Goal 33'),const SizedBox(height:30),InkWell(customBorder:const CircleBorder(),onTap:()=>setState(()=>count++),onLongPress:()=>setState(()=>count=0),child:Container(width:190,height:190,decoration:const BoxDecoration(color:teal,shape:BoxShape.circle),alignment:Alignment.center,child:Text('$count',style:const TextStyle(color:Colors.white,fontSize:58)))),const SizedBox(height:20),Text(count>=33?'Goal completed — Alhamdulillah':'Tap to count · Hold to reset')])));}

class RamadanPage extends StatefulWidget { const RamadanPage({super.key}); @override State<RamadanPage> createState()=>_RamadanPageState(); }
class _RamadanPageState extends State<RamadanPage>{final fasts=List<bool>.filled(30,false);@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Ramadan tracker')),body:ListView(padding:const EdgeInsets.all(18),children:[Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:teal,borderRadius:BorderRadius.circular(22)),child:const Column(children:[Text('12 Ramadan 1448',style:TextStyle(color:Colors.white70)),SizedBox(height:10),Text('Iftar in 1h 24m',style:TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.w600)),Text('Maghrib · 6:41 PM',style:TextStyle(color:Colors.white70))])),const SizedBox(height:18),Text('Fast log · ${fasts.where((e)=>e).length} completed'),const SizedBox(height:10),GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:6,mainAxisSpacing:8,crossAxisSpacing:8),itemCount:30,itemBuilder:(_,i)=>InkWell(onTap:()=>setState(()=>fasts[i]=!fasts[i]),child:Container(alignment:Alignment.center,decoration:BoxDecoration(color:fasts[i]?teal:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(10)),child:Text('${i+1}',style:TextStyle(color:fasts[i]?Colors.white:null)))))]));}

class ZakatPage extends StatefulWidget { const ZakatPage({super.key}); @override State<ZakatPage> createState()=>_ZakatPageState(); }
class _ZakatPageState extends State<ZakatPage>{final assets=TextEditingController(text:'1250000');final liabilities=TextEditingController(text:'300000');double result=23750;void calculate(){final eligible=(double.tryParse(assets.text)??0)-(double.tryParse(liabilities.text)??0);setState(()=>result=eligible>67360?eligible*.025:0);}@override void dispose(){assets.dispose();liabilities.dispose();super.dispose();}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Zakat calculator')),body:ListView(padding:const EdgeInsets.all(18),children:[TextField(controller:assets,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Total eligible assets (₹)',border:OutlineInputBorder())),const SizedBox(height:14),TextField(controller:liabilities,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Short-term liabilities (₹)',border:OutlineInputBorder())),const SizedBox(height:16),FilledButton(onPressed:calculate,child:const Text('Calculate 2.5%')),const SizedBox(height:20),Card(color:teal,child:Padding(padding:const EdgeInsets.all(22),child:Column(children:[const Text('Estimated Zakat due',style:TextStyle(color:Colors.white70)),Text('₹${result.toStringAsFixed(0)}',style:const TextStyle(color:Colors.white,fontSize:36,fontWeight:FontWeight.w600))]))),const SizedBox(height:14),const Text('Illustrative estimate using a demo silver Nisab of ₹67,360. Verify current metal prices and consult a trusted scholar for personal circumstances.',style:TextStyle(color:Colors.grey))]));}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key,required this.locale,required this.onLocale,required this.mode,required this.onTheme}); final Locale locale;final ValueChanged<Locale> onLocale;final ThemeMode mode;final ValueChanged<ThemeMode> onTheme;
  @override Widget build(BuildContext context)=>PagePad(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(tr(locale,'Settings','सेटिंग','ترتیبات'),style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:16),
    Card(child:Column(children:[
      ListTile(leading:const Icon(Icons.language,color:teal),title:Text(tr(locale,'Language','भाषा','زبان')),trailing:DropdownButton<Locale>(value:locale,underline:const SizedBox(),items:const [DropdownMenuItem(value:Locale('en'),child:Text('English')),DropdownMenuItem(value:Locale('hi'),child:Text('हिन्दी')),DropdownMenuItem(value:Locale('ur'),child:Text('اردو'))],onChanged:(v){if(v!=null)onLocale(v);}),),
      ListTile(leading:const Icon(Icons.dark_mode_outlined,color:teal),title:Text(tr(locale,'Appearance','दिखावट','ظاہری شکل')),trailing:DropdownButton<ThemeMode>(value:mode,underline:const SizedBox(),items:const [DropdownMenuItem(value:ThemeMode.system,child:Text('System')),DropdownMenuItem(value:ThemeMode.light,child:Text('Light')),DropdownMenuItem(value:ThemeMode.dark,child:Text('Dark'))],onChanged:(v){if(v!=null)onTheme(v);})),
      _settingsLink(context,Icons.location_on_outlined,'Location','New Delhi, India',const LocationSupportPage()),
      _settingsLink(context,Icons.notifications_outlined,'Adhan & notifications','Prayer alerts and sound',const AdhanSupportPage()),
      _settingsLink(context,Icons.download_outlined,'Offline downloads','Saved content without internet',const OfflineSupportPage()),
      _settingsLink(context,Icons.privacy_tip_outlined,'Privacy & data','Your choices and records',const PrivacySupportPage()),
      _settingsLink(context,Icons.help_outline,'Help & feedback','Report a translation or issue',const HelpFeedbackPage()),
      _settingsLink(context,Icons.dashboard_customize_outlined,'All designed screens','Complete UI/UX screen library',const ScreenLibraryPage()),
      _settingsLink(context,Icons.info_outline,'About, terms & privacy','Ibadati v0.2.0',const AboutSupportPage()),
    ])),const SizedBox(height:20),const Center(child:Text('Ibadati MVP · 0.2.0',style:TextStyle(color:Colors.grey))) ]));

  Widget _settingsLink(BuildContext context,IconData icon,String title,String subtitle,Widget page)=>ListTile(leading:Icon(icon,color:teal),title:Text(title),subtitle:Text(subtitle),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>page)));
}

class SupportScaffold extends StatelessWidget { const SupportScaffold({super.key,required this.title,required this.body}); final String title;final Widget body;@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title)),body:SafeArea(child:body)); }

class LocationSupportPage extends StatefulWidget { const LocationSupportPage({super.key});@override State<LocationSupportPage> createState()=>_LocationSupportPageState(); }
class _LocationSupportPageState extends State<LocationSupportPage>{bool manual=false;@override Widget build(BuildContext context)=>SupportScaffold(title:'Location',body:PagePad(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('New Delhi, India',style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:4),const Text('Prayer times and Qibla direction use this location.'),const SizedBox(height:22),FilledButton.icon(onPressed:(){},icon:const Icon(Icons.my_location),label:const Text('Use current location')),const SizedBox(height:10),OutlinedButton(onPressed:()=>setState(()=>manual=!manual),child:const Text('Choose city manually')),if(manual)...[const SizedBox(height:16),const TextField(decoration:InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search city or country',border:OutlineInputBorder())),const SizedBox(height:10),const Card(child:ListTile(leading:Icon(Icons.location_on,color:teal),title:Text('New Delhi, India'),subtitle:Text('Asia/Kolkata')))],const SizedBox(height:20),const Text('You can use the app without location permission by choosing a city manually.',style:TextStyle(color:Colors.grey))])));}

class AdhanSupportPage extends StatefulWidget { const AdhanSupportPage({super.key});@override State<AdhanSupportPage> createState()=>_AdhanSupportPageState(); }
class _AdhanSupportPageState extends State<AdhanSupportPage>{bool alerts=true;bool vibration=true;@override Widget build(BuildContext context)=>SupportScaffold(title:'Adhan & notifications',body:PagePad(child:Column(children:[SwitchListTile(value:alerts,onChanged:(v)=>setState(()=>alerts=v),title:const Text('Prayer notifications'),subtitle:const Text('Alerts before selected prayer times')),SwitchListTile(value:vibration,onChanged:(v)=>setState(()=>vibration=v),title:const Text('Vibration')),const ListTile(leading:Icon(Icons.music_note,color:teal),title:Text('Adhan sound'),subtitle:Text('Default Adhan')),const SizedBox(height:16),OutlinedButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const NotificationHelpPage())),icon:const Icon(Icons.help_outline),label:const Text('Notifications are not working?'))])));}

class NotificationHelpPage extends StatelessWidget { const NotificationHelpPage({super.key});@override Widget build(BuildContext context)=>SupportScaffold(title:'Adhan notifications',body:PagePad(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Notifications are turned off',style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:18),const ListTile(leading:CircleAvatar(child:Text('1')),title:Text('Open phone settings'),subtitle:Text('Settings → Apps → Ibadati')),const ListTile(leading:CircleAvatar(child:Text('2')),title:Text('Allow notifications'),subtitle:Text('Enable Ibadati and the Adhan category')),const ListTile(leading:CircleAvatar(child:Text('3')),title:Text('Check battery settings'),subtitle:Text('Exclude Ibadati from battery optimization'))])));}

class OfflineSupportPage extends StatefulWidget { const OfflineSupportPage({super.key});@override State<OfflineSupportPage> createState()=>_OfflineSupportPageState(); }
class _OfflineSupportPageState extends State<OfflineSupportPage>{bool downloaded=false;@override Widget build(BuildContext context)=>SupportScaffold(title:'Offline downloads',body:PagePad(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Keep worship content close',style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:5),const Text('Saved items stay available without internet.'),const SizedBox(height:18),Card(child:ListTile(leading:const Icon(Icons.download,color:teal),title:const Text('Duas & Azkar essentials'),subtitle:Text(downloaded?'Downloaded · 8.4 MB':'8.4 MB'),trailing:FilledButton(onPressed:()=>setState(()=>downloaded=!downloaded),child:Text(downloaded?'Remove':'Download')))),const SizedBox(height:10),const Card(child:ListTile(leading:Icon(Icons.info_outline,color:gold),title:Text('Prayer times need a refresh'),subtitle:Text('Last known schedule can be shown offline.')))])));}

class PrivacySupportPage extends StatefulWidget { const PrivacySupportPage({super.key});@override State<PrivacySupportPage> createState()=>_PrivacySupportPageState(); }
class _PrivacySupportPageState extends State<PrivacySupportPage>{bool analytics=true;@override Widget build(BuildContext context)=>SupportScaffold(title:'Privacy & data',body:PagePad(child:Column(children:[SwitchListTile(value:analytics,onChanged:(v)=>setState(()=>analytics=v),title:const Text('Anonymous analytics'),subtitle:const Text('Help improve Ibadati with non-identifying usage data')),const Divider(),const ListTile(leading:Icon(Icons.delete_outline),title:Text('Delete local records'),subtitle:Text('Tasbih, Ramadan and Zakat demo records')),const SizedBox(height:14),const Text('The production version must include a published privacy policy and account data controls.')])));}

class HelpFeedbackPage extends StatefulWidget { const HelpFeedbackPage({super.key});@override State<HelpFeedbackPage> createState()=>_HelpFeedbackPageState(); }
class _HelpFeedbackPageState extends State<HelpFeedbackPage>{bool sent=false;@override Widget build(BuildContext context)=>SupportScaffold(title:'Help & feedback',body:PagePad(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const ListTile(leading:Icon(Icons.access_time,color:teal),title:Text('Prayer time accuracy'),subtitle:Text('Location and calculation methods')),const ListTile(leading:Icon(Icons.compass_calibration,color:teal),title:Text('Qibla compass help'),subtitle:Text('Calibration guide')),const ListTile(leading:Icon(Icons.translate,color:teal),title:Text('Report a translation'),subtitle:Text('Correct Hindi, Urdu or English text')),const SizedBox(height:20),Text('Send feedback',style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:10),const TextField(maxLines:4,decoration:InputDecoration(hintText:'Idea, question or technical issue…',border:OutlineInputBorder())),const SizedBox(height:12),FilledButton(onPressed:()=>setState(()=>sent=true),child:const Text('Send securely')),if(sent)const Padding(padding:EdgeInsets.only(top:10),child:Text('Thank you — your feedback is ready to be sent.',style:TextStyle(color:teal)))])));}

class AboutSupportPage extends StatelessWidget { const AboutSupportPage({super.key});@override Widget build(BuildContext context)=>SupportScaffold(title:'About & privacy',body:PagePad(child:const Column(children:[ListTile(leading:CircleAvatar(child:Icon(Icons.mosque_outlined)),title:Text('Ibadati'),subtitle:Text('My worship · Global edition'),trailing:Text('v0.2.0')),SizedBox(height:16),ListTile(leading:Icon(Icons.policy_outlined,color:teal),title:Text('Privacy policy'),subtitle:Text('How your data is handled')),ListTile(leading:Icon(Icons.gavel_outlined,color:teal),title:Text('Terms of use'),subtitle:Text('Conditions for using Ibadati')),ListTile(leading:Icon(Icons.code_outlined,color:teal),title:Text('Open-source notices'),subtitle:Text('Libraries and licenses')),SizedBox(height:18),Text('Built for every Muslim, everywhere.\nHindi · اردو · English, with more languages planned.',textAlign:TextAlign.center)])));}

class SavedSupportPage extends StatelessWidget { const SavedSupportPage({super.key});@override Widget build(BuildContext context)=>SupportScaffold(title:'Saved',body:Center(child:Padding(padding:const EdgeInsets.all(30),child:Column(mainAxisSize:MainAxisSize.min,children:[Container(width:84,height:84,decoration:BoxDecoration(color:teal.withOpacity(.12),borderRadius:BorderRadius.circular(28)),child:const Icon(Icons.bookmark_border,color:teal,size:38)),const SizedBox(height:18),const Text('Nothing saved yet',style:TextStyle(fontSize:20,fontWeight:FontWeight.w600)),const SizedBox(height:8),const Text('Save a Dua or Azkar and it will appear here for quick access.',textAlign:TextAlign.center),const SizedBox(height:18),FilledButton(onPressed:(){},child:const Text('Explore duas & azkar'))]))));}

class SearchSupportPage extends StatefulWidget { const SearchSupportPage({super.key});@override State<SearchSupportPage> createState()=>_SearchSupportPageState(); }
class _SearchSupportPageState extends State<SearchSupportPage>{final query=TextEditingController();@override void dispose(){query.dispose();super.dispose();}@override Widget build(BuildContext context)=>SupportScaffold(title:'Search',body:PagePad(child:Column(children:[TextField(controller:query,onChanged:(_)=>setState((){}),decoration:InputDecoration(prefixIcon:const Icon(Icons.search),suffixIcon:IconButton(icon:const Icon(Icons.close),onPressed:(){query.clear();setState((){});}),hintText:'Search duas, azkar and features',border:const OutlineInputBorder())),const SizedBox(height:46),const Icon(Icons.search_off,size:54,color:teal),const SizedBox(height:14),Text(query.text.isEmpty?'Search Ibadati':'No results found',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w600)),const SizedBox(height:8),const Text('Try: Morning azkar, Fajr dua, सुबह की दुआ, أذكار الصباح',textAlign:TextAlign.center)])));}
