import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/app_cubit.dart';
import 'theme/dairy_theme.dart';

import '../services/notification_service.dart';
import '../db/database_sanitizer.dart';

/// Loading/router screen. Navigates to onboarding (first run) or the main
/// shell once settings finish loading. Handles the race where settings load
/// BEFORE this widget subscribes (which previously left the app stuck here).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      await DatabaseSanitizer.instance.sanitizeDatabase();
    } catch (_) {}
  }

  void _go(AppState state) {
    if (_navigated) return;
    _navigated = true;

    // Schedule active reminders on startup
    try {
      NotificationService.instance.scheduleDailyReminders(
        morningEnabled: state.morningReminderEnabled,
        morningTime: state.morningReminderTime,
        eveningEnabled: state.eveningReminderEnabled,
        eveningTime: state.eveningReminderTime,
      );
    } catch (_) {}

    Navigator.pushReplacementNamed(
      context,
      state.isFirstRun ? '/onboarding' : '/shell',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (!state.isLoading) _go(state);
      },
      builder: (context, state) {
        // If loading already finished before we subscribed, navigate next frame.
        if (!state.isLoading && !_navigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _go(state);
          });
        }
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: DairyTheme.primaryTeal.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.agriculture_rounded,
                      size: 60,
                      color: DairyTheme.primaryTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Pro Kisan',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: DairyTheme.primaryTeal,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
