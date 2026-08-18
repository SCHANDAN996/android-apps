import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'blocs/app_cubit.dart';
import 'blocs/entry_cubit.dart';
import 'blocs/customer_cubit.dart';
import 'blocs/report_cubit.dart';
import 'blocs/backup_cubit.dart';
import 'blocs/dairy_product_cubit.dart';
import 'db/models/customer.dart';
import 'db/models/milk_entry.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'services/backup_guard.dart';
import 'services/backup_lifecycle.dart';
import 'services/pashu_photo_service.dart';
import 'services/ssl_pinning.dart';
import 'ui/splash_screen.dart';
import 'ui/onboarding_screen.dart';
import 'ui/main_shell.dart';
import 'ui/home_screen.dart';
import 'ui/entry_screen.dart';
import 'ui/customer_screen.dart';
import 'ui/customer_detail_screen.dart';
import 'ui/report_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/dairy_products_screen.dart';
import 'ui/weather_screen.dart';
import 'ui/news_screen.dart';
import 'ui/yojana_screen.dart';
import 'ui/mandi_screen.dart';
import 'ui/sujhav_screen.dart';
import 'ui/about_screen.dart';
import 'ui/faq_screen.dart';
import 'ui/helpline_screen.dart';
import 'ui/theme/dairy_theme.dart';
import 'ui/pashu/pashu_screen.dart';
import 'ui/pashu/my_pashu_screen.dart';
import 'ui/khaad/khaad_screen.dart';
import 'ui/land_measurement_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    HttpOverrides.global = ProKisanHttpOverrides();
  } catch (_) {}

  try {
    await initializeDateFormatting();
  } catch (_) {}

  try {
    await NotificationService.instance.init();
  } catch (_) {}

  // पशु की फ़ोटो का फ़ोल्डर एक बार निकालकर रख लो। UI के build() में await
  // नहीं कर सकते, और DB में अब सिर्फ़ फ़ाइल का नाम रहता है — पूरा रास्ता
  // यहीं से बनता है। देखें PashuPhotoService.fullPathSync()।
  try {
    await PashuPhotoService.warmUp();
  } catch (_) {}

  // 🛡️ किसान का हिसाब सुरक्षित रखने का ज़िम्मा।
  //
  //  • ऐप बंद होते ही backup — फ़ोन में, और Google खाता जुड़ा हो तो Drive पर
  //  • खाता न जुड़ा हो तो हफ़्ते में एक बार याद — "WhatsApp पर भेज दीजिए"
  //
  // गाँव के बहुत से फ़ोन में Google खाता होता ही नहीं; वहाँ Android का
  // auto-backup भी नहीं चलता। फ़ोन खोया तो महीनों का हिसाब चला जाता है —
  // इसलिए ऐप ख़ुद ज़िम्मा लेता है।
  try {
    BackupLifecycle.instance.suruKaro();
    await BackupGuard.instance.refreshReminder();
  } catch (_) {}

  runApp(const DudhKaHisabApp());
}

class DudhKaHisabApp extends StatelessWidget {
  const DudhKaHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(
          create: (context) => AppCubit()..loadSettings(),
        ),
        BlocProvider<EntryCubit>(
          create: (context) => EntryCubit(),
        ),
        BlocProvider<CustomerCubit>(
          create: (context) => CustomerCubit(),
        ),
        BlocProvider<ReportCubit>(
          create: (context) => ReportCubit(),
        ),
        BlocProvider<BackupCubit>(
          create: (context) => BackupCubit(),
        ),
        BlocProvider<DairyProductCubit>(
          create: (context) => DairyProductCubit(),
        ),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'प्रो किसान',
            debugShowCheckedModeBanner: false,
            theme: DairyTheme.lightTheme,
            darkTheme: DairyTheme.darkTheme,
            themeMode: state.themeMode == 'dark'
                ? ThemeMode.dark
                : state.themeMode == 'system'
                    ? ThemeMode.system
                    : ThemeMode.light,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(state.fontScale),
                ),
                child: child!,
              );
            },
            locale: Locale(state.language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              FallbackMaterialLocalizationsDelegate(),
              FallbackCupertinoLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case '/onboarding':
                  return MaterialPageRoute(builder: (_) => const OnboardingScreen());
                case '/shell':
                  return MaterialPageRoute(builder: (_) => const MainShell());
                case '/home':
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case '/entry':
                  final args = settings.arguments as MilkEntry?;
                  return MaterialPageRoute(builder: (_) => EntryScreen(editEntry: args));
                case '/customers':
                  return MaterialPageRoute(builder: (_) => const CustomerScreen());
                case '/customer_detail':
                  final args = settings.arguments as Customer;
                  return MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: args));
                case '/report':
                  return MaterialPageRoute(builder: (_) => const ReportScreen());
                case '/settings':
                  return MaterialPageRoute(builder: (_) => const SettingsScreen());
                case '/dairy_products':
                  return MaterialPageRoute(builder: (_) => const DairyProductsScreen());
                case '/weather':
                  return MaterialPageRoute(builder: (_) => const WeatherScreen());
                case '/news':
                  return MaterialPageRoute(builder: (_) => const NewsScreen());
                case '/yojana':
                  return MaterialPageRoute(builder: (_) => const YojanaScreen());
                case '/mandi':
                  return MaterialPageRoute(builder: (_) => const MandiScreen());
                case '/sujhav':
                  return MaterialPageRoute(builder: (_) => const SujhavScreen());
                case '/faq':
                  return MaterialPageRoute(builder: (_) => const FaqScreen());
                case '/about':
                  return MaterialPageRoute(builder: (_) => const AboutScreen());
                case '/helpline':
                  return MaterialPageRoute(builder: (_) => const HelplineScreen());
                case '/pashu':
                  return MaterialPageRoute(builder: (_) => const PashuScreen());
                case '/my_pashu':
                  return MaterialPageRoute(builder: (_) => const MyPashuScreen());
                case '/khaad':
                  return MaterialPageRoute(builder: (_) => const KhaadScreen());
                case '/land_measurement':
                  return MaterialPageRoute(builder: (_) => const LandMeasurementScreen());
                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
            },
          );
        },
      ),
    );
  }
}
