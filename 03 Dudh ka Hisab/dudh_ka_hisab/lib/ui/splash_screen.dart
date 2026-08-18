import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/app_cubit.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (!state.isLoading) {
          if (!state.isFirstRun) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Milk can design icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_drink_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.get(context, 'appName'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  Text(
                    AppLocalizations.get(context, 'tagline'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.get(context, 'selectMode'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionCard(
                    context,
                    title: AppLocalizations.get(context, 'kisanMode'),
                    description: AppLocalizations.get(context, 'kisanModeDesc'),
                    icon: Icons.agriculture_rounded,
                    onTap: () async {
                      final appCubit = context.read<AppCubit>();
                      await appCubit.setMode('kisan');
                      await appCubit.completeFirstRun();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    context,
                    title: AppLocalizations.get(context, 'doodhwalaMode'),
                    description: AppLocalizations.get(context, 'doodhwalaModeDesc'),
                    icon: Icons.people_alt_rounded,
                    onTap: () async {
                      final appCubit = context.read<AppCubit>();
                      await appCubit.setMode('doodhwala');
                      await appCubit.completeFirstRun();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
