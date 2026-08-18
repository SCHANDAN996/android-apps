import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/backup_cubit.dart';
import 'widgets/google_backup_tile.dart';
import '../../blocs/entry_cubit.dart';
import '../../blocs/customer_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../db/dao/settings_dao.dart';
import 'theme/dairy_theme.dart';

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
        body: SafeArea(
          child: BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAppIdentity(context),
                  const SizedBox(height: 18),
                  // किसान/दूधवाला mode-switch हटाया गया — अब एक ही unified flow है।
                  _buildHeader(context, AppLocalizations.get(context, 'rateType')),
                  _buildRateTypeTile(context, state),
                  const SizedBox(height: 16),
                  _buildHeader(context, AppLocalizations.get(context, 'rate')),
                  _buildRateValueFields(context, state),
                  const SizedBox(height: 16),
                  _buildHeader(context, AppLocalizations.get(context, 'language')),
                  _buildLanguageTile(context, state),
                  _buildThemeTile(context, state),
                  _buildFontScaleTile(context, state),
                  const SizedBox(height: 16),
                  _buildHeader(context, AppLocalizations.get(context, 'backupRestore')),
                  _buildBackupRestoreTile(context),
                  const SizedBox(height: 16),
                  _buildHeader(context, AppLocalizations.get(context, 'remindHeader')),
                  _buildReminderTile(context, state),
                  const SizedBox(height: 24),
                  _buildMoreAppsSection(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// सेटिंग के सबसे ऊपर ऐप की पहचान — असली icon, नाम और वर्शन।
  /// पहले यहाँ कुछ भी नहीं था; icon दिखने से भरोसा बनता है।
  Widget _buildAppIdentity(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DairyTheme.primaryTeal, DairyTheme.secondaryTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.cover,
              // फ़ाइल न मिले तो ऐप टूटे नहीं
              errorBuilder: (_, __, ___) => const Icon(Icons.agriculture_rounded,
                  size: 42, color: DairyTheme.primaryTeal),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.get(context, 'appName'),
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            AppLocalizations.get(context, 'aboutTagline'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              AppLocalizations.get(context, 'aboutVersion'),
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppLocalizations.get(context, 'rateHint'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
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

  Widget _buildThemeTile(BuildContext context, AppState state) {
    final isHi = AppLocalizations.isHindiLike(context);
    final themeMap = {
      'light': isHi ? 'लाइट थीम (Light)' : 'Light Theme',
      'dark': isHi ? 'डार्क मोड (Dark)' : 'Dark Mode',
      'system': isHi ? 'सिस्टम डिफ़ॉल्ट (System)' : 'System Default',
    };

    return Card(
      child: ListTile(
        leading: Icon(
          state.themeMode == 'dark'
              ? Icons.dark_mode_rounded
              : state.themeMode == 'system'
                  ? Icons.brightness_auto_rounded
                  : Icons.light_mode_rounded,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(isHi ? 'ऐप थीम (Theme Mode)' : 'App Theme Mode'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              themeMap[state.themeMode] ?? 'Light',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        onTap: () {
          _showThemePicker(context, state.themeMode);
        },
      ),
    );
  }

  Widget _buildFontScaleTile(BuildContext context, AppState state) {
    final isHi = AppLocalizations.isHindiLike(context);
    final scaleMap = {
      1.0: isHi ? 'सामान्य (1.0x)' : 'Normal (1.0x)',
      1.2: isHi ? 'बड़ा (1.2x)' : 'Large (1.2x)',
      1.4: isHi ? 'अति बड़ा (1.4x)' : 'Extra Large (1.4x)',
    };

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.text_fields_rounded,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(isHi ? 'अक्षर का आकार (Text Size)' : 'Text Scale Factor'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              scaleMap[state.fontScale] ?? '1.0x',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        onTap: () {
          _showFontScalePicker(context, state.fontScale);
        },
      ),
    );
  }

  void _showFontScalePicker(BuildContext context, double currentScale) {
    final appCubit = context.read<AppCubit>();
    final isHi = AppLocalizations.isHindiLike(context);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isHi ? 'अक्षर का आकार चुनें' : 'Choose Text Size',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.text_format_rounded, size: 20),
                  title: Text(isHi ? 'सामान्य आकार (1.0x Standard)' : 'Normal Size (1.0x)'),
                  trailing: currentScale == 1.0 ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    appCubit.setFontScale(1.0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.text_format_rounded, size: 26),
                  title: Text(isHi ? 'बड़ा आकार (1.2x Large)' : 'Large Size (1.2x)'),
                  trailing: currentScale == 1.2 ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    appCubit.setFontScale(1.2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.text_format_rounded, size: 32),
                  title: Text(isHi ? 'अति बड़ा आकार (1.4x Extra Large)' : 'Extra Large (1.4x)'),
                  trailing: currentScale == 1.4 ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    appCubit.setFontScale(1.4);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, String currentTheme) {
    final appCubit = context.read<AppCubit>();
    final isHi = AppLocalizations.isHindiLike(context);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isHi ? 'थीम चुनें (Choose Theme)' : 'Choose App Theme',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.light_mode_rounded, color: Colors.orange),
                  title: Text(isHi ? '☀️ लाइट मोड (Light Theme)' : '☀️ Light Mode'),
                  trailing: currentTheme == 'light' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    appCubit.setThemeMode('light');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded, color: Colors.indigo),
                  title: Text(isHi ? '🌙 डार्क मोड (Dark Mode)' : '🌙 Dark Mode'),
                  trailing: currentTheme == 'dark' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    appCubit.setThemeMode('dark');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_auto_rounded, color: Colors.teal),
                  title: Text(isHi ? '⚙️ सिस्टम के अनुसार (System Default)' : '⚙️ System Default'),
                  trailing: currentTheme == 'system' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    appCubit.setThemeMode('system');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackupRestoreTile(BuildContext context) {
    final backupCubit = context.read<BackupCubit>();
    final isHi = AppLocalizations.isHindiLike(context);

    return Card(
      child: Column(
        children: [
          // Auto-Backup Safety Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.get(context, 'autoBackupTitle'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                      ),
                      const SizedBox(height: 2),
                      _backupPathInfo(context, isHi),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🛡️ Google खाते वाला रास्ता — किसान की मर्ज़ी का।
          // जो जोड़ लेगा उसका हिसाब ऐप बंद करते ही Drive पर चढ़ जाएगा।
          const GoogleBackupTile(),
          const Divider(height: 1),

          // 1-Click Auto Detect Restore Button
          ListTile(
            leading: const Icon(Icons.find_in_page_rounded, color: Colors.teal, size: 24),
            title: Text(
              AppLocalizations.get(context, 'searchBackupBtn'),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            subtitle: Text(
              // ⚠️ पहले यहाँ "ऊपर लिखी जगहों से" लिखा था — पर अब वे जगहें
              // "जगह देखें" के पीछे छिपी हैं, तो वह वाक्य किसी और चीज़ की
              // ओर इशारा करता। अब सीधे बात कही है।
              isHi
                ? "1-क्लिक में पुराना बैकअप वापस लाएँ — फ़ोन में अपने-आप खोजता है"
                : "Restore previous backup in 1 click — searches your phone automatically",
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
            onTap: () async {
              final ok = await backupCubit.runAutoDetectRestore();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                        ? AppLocalizations.get(context, 'restoreSuccessAlert')
                        : AppLocalizations.get(context, 'restoreNotFoundAlert'),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          const Divider(height: 1),

          // Export Manual JSON
          ListTile(
            leading: const Icon(Icons.share_rounded, color: Colors.blue),
            title: Text(AppLocalizations.get(context, 'backup')),
            subtitle: Text(AppLocalizations.get(context, 'backupSub')),
            onTap: () => backupCubit.runExport(),
          ),
          const Divider(height: 1),

          // Import Manual JSON
          ListTile(
            leading: const Icon(Icons.file_open_rounded, color: Colors.green),
            title: Text(AppLocalizations.get(context, 'restore')),
            subtitle: Text(AppLocalizations.get(context, 'restoreSub')),
            onTap: () => backupCubit.runImport(),
          ),
          const Divider(height: 1),

          // Uninstall Safety Warning Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.get(context, 'uninstallSafetyWarning'),
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// बैकअप की **असली** जगह — जहाँ पिछली बार सचमुच फ़ाइल लिखी गई।
  ///
  /// अंदाज़े का path लिखना ग़लत होता: Android 11+ पर ऐप को public folder
  /// (Documents/Download) में लिखने की इजाज़त अक्सर नहीं मिलती, तो फ़ाइल
  /// ऐप के अपने folder में जाती है। इसलिए path वहीं से पढ़कर दिखाते हैं।
  ///
  /// ⚠️ पर **खुले में नहीं**। 9 अगस्त 2026 को असली फ़ोन पर देखा गया कि ये
  /// दो लंबी लाइनें —
  ///   /data/user/0/com.prokisan.app/app_flutter/ProKisan_Backups/…
  /// — आधा डिब्बा खा रही थीं। जिस किसान के लिए यह ऐप है (देखें
  /// `docs/ANPADH_UI_NIYAM.md`) उसके लिए यह पंक्ति बेमानी है; उसे बस इतना
  /// जानना है कि हिसाब सुरक्षित है। इसलिए path अब "जगह देखें" के पीछे है —
  /// जिसे ज़रूरत हो (जैसे फ़ाइल manager से उठानी हो) वही खोले।
  Widget _backupPathInfo(BuildContext context, bool isHi) =>
      _BackupPathInfo(isHi: isHi);

  Widget _buildMoreAppsSection(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${AppLocalizations.get(context, 'appName')} v1.0.0',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.get(context, 'appFooter'),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, String currentLang) {
    final appCubit = context.read<AppCubit>();
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
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

  Widget _buildReminderTile(BuildContext context, AppState state) {
    final appCubit = context.read<AppCubit>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Morning Reminder Row
            ListTile(
              leading: Icon(Icons.wb_sunny_rounded, color: Colors.orange[800]),
              title: Text(
                AppLocalizations.get(context, 'remindMorning'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                state.morningReminderEnabled
                    ? '${AppLocalizations.get(context, 'remindTimeLabel')}: ${state.morningReminderTime}'
                    : AppLocalizations.get(context, 'remindDisabled'),
              ),
              trailing: Switch(
                value: state.morningReminderEnabled,
                onChanged: (val) async {
                  if (val) {
                    final granted = await NotificationService.instance.requestPermissions();
                    if (!granted) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.get(context, 'remindPermission')),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }
                  }
                  await appCubit.updateMorningReminder(enabled: val);
                  await NotificationService.instance.scheduleDailyReminders(
                    morningEnabled: val,
                    morningTime: state.morningReminderTime,
                    eveningEnabled: state.eveningReminderEnabled,
                    eveningTime: state.eveningReminderTime,
                  );
                },
              ),
              onTap: state.morningReminderEnabled
                  ? () => _selectReminderTime(context, true, state.morningReminderTime, state)
                  : null,
            ),
            const Divider(),
            // Evening Reminder Row
            ListTile(
              leading: Icon(Icons.nights_stay_rounded, color: Colors.indigo[800]),
              title: Text(
                AppLocalizations.get(context, 'remindEvening'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                state.eveningReminderEnabled
                    ? '${AppLocalizations.get(context, 'remindTimeLabel')}: ${state.eveningReminderTime}'
                    : AppLocalizations.get(context, 'remindDisabled'),
              ),
              trailing: Switch(
                value: state.eveningReminderEnabled,
                onChanged: (val) async {
                  if (val) {
                    final granted = await NotificationService.instance.requestPermissions();
                    if (!granted) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.get(context, 'remindPermission')),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }
                  }
                  await appCubit.updateEveningReminder(enabled: val);
                  await NotificationService.instance.scheduleDailyReminders(
                    morningEnabled: state.morningReminderEnabled,
                    morningTime: state.morningReminderTime,
                    eveningEnabled: val,
                    eveningTime: state.eveningReminderTime,
                  );
                },
              ),
              onTap: state.eveningReminderEnabled
                  ? () => _selectReminderTime(context, false, state.eveningReminderTime, state)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectReminderTime(
    BuildContext context,
    bool isMorning,
    String currentTime,
    AppState state,
  ) async {
    final parts = currentTime.split(':');
    final hour = int.tryParse(parts[0]) ?? (isMorning ? 8 : 20);
    final minute = int.tryParse(parts[1]) ?? 30;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      helpText: AppLocalizations.get(context, isMorning ? 'remindPickMorning' : 'remindPickEvening'),
    );

    if (selectedTime != null) {
      final hourStr = selectedTime.hour.toString().padLeft(2, '0');
      final minStr = selectedTime.minute.toString().padLeft(2, '0');
      final formattedTime = '$hourStr:$minStr';

      final appCubit = context.read<AppCubit>();
      if (isMorning) {
        await appCubit.updateMorningReminder(time: formattedTime);
        await NotificationService.instance.scheduleDailyReminders(
          morningEnabled: state.morningReminderEnabled,
          morningTime: formattedTime,
          eveningEnabled: state.eveningReminderEnabled,
          eveningTime: state.eveningReminderTime,
        );
      } else {
        await appCubit.updateEveningReminder(time: formattedTime);
        await NotificationService.instance.scheduleDailyReminders(
          morningEnabled: state.morningReminderEnabled,
          morningTime: state.morningReminderTime,
          eveningEnabled: state.eveningReminderEnabled,
          eveningTime: formattedTime,
        );
      }
    }
  }
}

/// बैकअप कहाँ रखा है — path "जगह देखें" के पीछे
///
/// अपना छोटा stateful widget इसलिए, क्योंकि `SettingsScreen` stateless है
/// और खुलने-बंद होने की हालत कहीं तो रहनी चाहिए।
class _BackupPathInfo extends StatefulWidget {
  const _BackupPathInfo({required this.isHi});

  final bool isHi;

  @override
  State<_BackupPathInfo> createState() => _BackupPathInfoState();
}

class _BackupPathInfoState extends State<_BackupPathInfo> {
  bool _khula = false;

  @override
  Widget build(BuildContext context) {
    final isHi = widget.isHi;
    return FutureBuilder<String?>(
      future: SettingsDao().getSetting('backup_saved_paths'),
      builder: (context, snap) {
        final raw = (snap.data ?? '').trim();
        final paths = raw.isEmpty ? <String>[] : raw.split('\n');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHi
                  ? 'हर एंट्री के बाद अपने-आप सेव होता है।'
                  : 'Saved automatically after every entry.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade800),
            ),
            if (paths.isNotEmpty) ...[
              InkWell(
                onTap: () => setState(() => _khula = !_khula),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _khula
                            ? (isHi ? 'जगह छिपाएँ' : 'Hide location')
                            : (isHi ? 'जगह देखें' : 'Show location'),
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.teal),
                      ),
                      Icon(
                        _khula
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 18,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),
              if (_khula)
                for (final p in paths)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: SelectableText(
                      p,
                      style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade700,
                          height: 1.3),
                    ),
                  ),
            ],
            const SizedBox(height: 4),
            Text(
              '☁️ ${AppLocalizations.get(context, 'backupCloudNote')}',
              style: TextStyle(
                  fontSize: 10.5, color: Colors.grey.shade700, height: 1.3),
            ),
          ],
        );
      },
    );
  }
}
