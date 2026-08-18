import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'blocs/app_cubit.dart';
import 'blocs/entry_cubit.dart';
import 'blocs/customer_cubit.dart';
import 'blocs/report_cubit.dart';
import 'blocs/backup_cubit.dart';
import 'db/models/customer.dart';
import 'db/models/milk_entry.dart';
import 'l10n/app_localizations.dart';
import 'services/ad_service.dart';
import 'ui/splash_screen.dart';
import 'ui/home_screen.dart';
import 'ui/entry_screen.dart';
import 'ui/customer_screen.dart';
import 'ui/customer_detail_screen.dart';
import 'ui/report_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/theme/dairy_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mobile Ads SDK (runs offline-friendly)
  await AdService.instance.init();

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
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'दूध का हिसाब',
            debugShowCheckedModeBanner: false,
            theme: DairyTheme.lightTheme,
            locale: Locale(state.language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
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
