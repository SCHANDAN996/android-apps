import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/dao/customer_dao.dart';
import '../db/dao/entry_dao.dart';
import '../db/dao/settings_dao.dart';
import '../l10n/app_localizations.dart';
import '../ui/weather/weather_common.dart' show kMonthsHi, kMonthsShortEn;
import 'backup_service.dart';
import 'excel_service.dart';
import 'notification_service.dart';

/// महीना पूरा होते ही उसका हिसाब अपने-आप सहेजना, और रोज़ का बैकअप।
///
/// **background scheduler जान-बूझकर नहीं** — Vivo/Oppo जैसे फ़ोन background
/// काम बंद कर देते हैं, इसलिए भरोसा नहीं। इसके बजाय **ऐप खुलते ही जाँच**:
/// यह हमेशा चलती है, कोई नई अनुमति नहीं लगती, और बैटरी भी नहीं ख़र्च होती।
class ReportArchiveService {
  static final ReportArchiveService instance = ReportArchiveService._();
  ReportArchiveService._();

  static const _kArchivedMonth = 'last_archived_month';
  static const _kArchivedPath = 'last_archived_report_path';

  bool _ranThisSession = false;

  /// ऐप खुलने पर एक बार — पहले रोज़ का बैकअप, फिर महीने की रिपोर्ट।
  Future<void> runOnAppOpen(BuildContext context) async {
    if (_ranThisSession) return;
    _ranThisSession = true;

    // भाषा से जुड़ी चीज़ें await से *पहले* निकाल लो (context बाद में बासी हो सकता है)
    String t(String k) => AppLocalizations.get(context, k);
    final isHi = AppLocalizations.isHindiLike(context);
    final labels = {
      for (final k in [
        'summaryLabel', 'appName', 'milkDashTitle', 'totalMilk',
        'totalSellLabel', 'totalBuyLabel', 'netBalanceLabel', 'avgFat',
        'totalEntries', 'report_table_date', 'report_table_shift',
        'tableName', 'litres', 'fat', 'rate', 'totalAmount', 'morning',
        'evening', 'home_farmer_default', 'monthReportReadyTitle',
        'monthReportReadyBody',
      ])
        k: t(k)
    };
    String tr(String k) => labels[k] ?? k;

    await _dailyBackupTopUp();
    await _archiveLastMonth(tr, isHi);
  }

  /// जिस दिन कोई एंट्री न हो, उस दिन भी बैकअप ताज़ा रहे।
  Future<void> _dailyBackupTopUp() async {
    try {
      final dao = SettingsDao();
      final last = await dao.getSetting('last_auto_backup');
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (last != null && last.length >= 10 && last.substring(0, 10) == today) {
        return; // आज हो चुका
      }
      await BackupService().autoSaveToPublicFolder();
    } catch (_) {}
  }

  /// पिछला महीना बंद हो चुका और उसकी रिपोर्ट नहीं बनी → अभी बना दो।
  Future<void> _archiveLastMonth(String Function(String) tr, bool isHi) async {
    try {
      final dao = SettingsDao();
      final now = DateTime.now();
      final prev = DateTime(now.year, now.month - 1, 1);
      final key = DateFormat('MM-yyyy').format(prev);

      if (await dao.getSetting(_kArchivedMonth) == key) return;

      // महीना निपट गया मानकर निशान लगा दो — एंट्री न हो तो रोज़-रोज़ न दोहराए
      await dao.setSetting(_kArchivedMonth, key);

      final entries = await EntryDao().getMonthlyEntries(key);
      if (entries.isEmpty) return;

      final customers = await CustomerDao().getAllCustomers();
      final names = {
        for (final c in customers)
          if (c.id != null) c.id!: c.name
      };

      final monthName =
          '${isHi ? kMonthsHi[prev.month] : kMonthsShortEn[prev.month]} ${prev.year}';

      final path = await ExcelService.instance.saveMonthlyExcelReport(
        month: key,
        periodName: monthName,
        t: tr,
        entries: entries,
        customerNames: names,
      );
      if (path == null) return;

      await dao.setSetting(_kArchivedPath, path);
      await NotificationService.instance.showNow(
        id: 901,
        title: tr('monthReportReadyTitle'),
        body: tr('monthReportReadyBody').replaceFirst('{month}', monthName),
      );
    } catch (_) {}
  }
}
