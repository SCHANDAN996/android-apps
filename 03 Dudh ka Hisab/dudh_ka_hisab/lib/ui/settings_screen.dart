import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/backup_cubit.dart';
import '../../blocs/entry_cubit.dart';
import '../../blocs/customer_cubit.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _languages = {
    'hi': 'हिन्दी (Hindi)',
    'en': 'English',
    'bho': 'भोजपुरी (Bhojpuri)',
    'mr': 'मराठी (Marathi)',
    'bn': 'বাংলা (Bengali)',
    'te': 'తెలుగు (Telugu)',
    'ta': 'தமிழ் (Tamil)',
    'gu': 'ગુજરાતી (Gujarati)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
  };

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BackupCubit, BackupState>(
          listener: (context, state) {
            if (state is BackupSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              // Reload all state if database imported
              if (state.message.contains("रीस्टोर")) {
                context.read<AppCubit>().loadSettings();
                context.read<EntryCubit>().loadHomeData();
                context.read<CustomerCubit>().loadCustomers();
              }
            } else if (state is BackupFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.get(context, 'settings')),
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context, AppLocalizations.get(context, 'selectMode')),
                _buildModeTile(context, state),
                const SizedBox(height: 16),
                _buildHeader(context, AppLocalizations.get(context, 'rateType')),
                _buildRateTypeTile(context, state),
                const SizedBox(height: 16),
                _buildHeader(context, AppLocalizations.get(context, 'rate')),
                _buildRateValueFields(context, state),
                const SizedBox(height: 16),
                _buildHeader(context, AppLocalizations.get(context, 'language')),
                _buildLanguageTile(context, state),
                const SizedBox(height: 16),
                _buildHeader(context, AppLocalizations.get(context, 'backupRestore')),
                _buildBackupRestoreTile(context),
                const SizedBox(height: 24),
                _buildMoreAppsSection(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildModeTile(BuildContext context, AppState state) {
    final appCubit = context.read<AppCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                  state.isKisanMode
                      ? AppLocalizations.get(context, 'kisanMode')
                      : AppLocalizations.get(context, 'doodhwalaMode'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  state.isKisanMode
                      ? AppLocalizations.get(context, 'kisanModeDesc')
                      : AppLocalizations.get(context, 'doodhwalaModeDesc'),
                ),
              ),
            ),
            Switch(
              value: state.isDoodhwalaMode,
              onChanged: (val) {
                _showModeWarning(context, val ? 'doodhwala' : 'kisan', appCubit);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateTypeTile(BuildContext context, AppState state) {
    final appCubit = context.read<AppCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text(
              AppLocalizations.get(context, 'rateType'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: state.rateType,
              items: [
                DropdownMenuItem(
                  value: 'flat',
                  child: Text(AppLocalizations.get(context, 'flat')),
                ),
                DropdownMenuItem(
                  value: 'fat',
                  child: Text(AppLocalizations.get(context, 'fatBased')),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  appCubit.setRateType(val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateValueFields(BuildContext context, AppState state) {
    final appCubit = context.read<AppCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!state.isFatBased)
              TextFormField(
                initialValue: state.flatRate.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(context, 'flatRateLabel'),
                  prefixText: '₹ ',
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed >= 0) {
                    appCubit.setFlatRate(parsed);
                  }
                },
              )
            else
              TextFormField(
                initialValue: state.ratePerFatPoint.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(context, 'ratePerFat'),
                  prefixText: '₹ ',
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed >= 0) {
                    appCubit.setRatePerFatPoint(parsed);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppState state) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.language_rounded, color: Theme.of(context).primaryColor),
        title: Text(AppLocalizations.get(context, 'language')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _languages[state.language] ?? 'English',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        onTap: () {
          _showLanguagePicker(context, state.language);
        },
      ),
    );
  }

  Widget _buildBackupRestoreTile(BuildContext context) {
    final backupCubit = context.read<BackupCubit>();
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.share_rounded, color: Colors.blue),
            title: Text(AppLocalizations.get(context, 'backup')),
            subtitle: const Text('पूरे डेटा को JSON फाइल में सुरक्षित करें'),
            onTap: () => backupCubit.runExport(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.file_open_rounded, color: Colors.green),
            title: Text(AppLocalizations.get(context, 'restore')),
            subtitle: const Text('बैकअप JSON फाइल से डेटा वापस लाएं'),
            onTap: () => backupCubit.runImport(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreAppsSection(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'दूध का हिसाब v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '100% सुरक्षित और ऑफलाइन | मेड इन इंडिया 🇮🇳',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showModeWarning(BuildContext context, String targetMode, AppCubit appCubit) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.get(context, 'warning')),
          content: Text(AppLocalizations.get(context, 'modeChangeWarning')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get(context, 'no')),
            ),
            ElevatedButton(
              onPressed: () {
                appCubit.setMode(targetMode);
                Navigator.pop(ctx);
              },
              child: Text(AppLocalizations.get(context, 'yes')),
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, String currentLang) {
    final appCubit = context.read<AppCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ListView(
                  children: _languages.entries.map((entry) {
                    final isSelected = entry.key == currentLang;
                    return ListTile(
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor)
                          : null,
                      onTap: () {
                        appCubit.setLanguage(entry.key);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
