import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../db/dao/customer_dao.dart';
import '../db/dao/entry_dao.dart';
import '../db/dao/payment_dao.dart';
import '../db/dao/settings_dao.dart';
import '../db/dairy_database.dart';

class BackupService {
  final CustomerDao _customerDao = CustomerDao();
  final EntryDao _entryDao = EntryDao();
  final PaymentDao _paymentDao = PaymentDao();
  final SettingsDao _settingsDao = SettingsDao();

  static const String _backupVersion = "1.0.0";

  /// Exports all data to a JSON string and triggers sharing sheet.
  Future<bool> exportBackup() async {
    try {
      final customers = await _customerDao.getAllCustomers();
      final entries = await _entryDao.getAllEntries();
      final payments = await _paymentDao.getAllPayments();
      final settings = await _settingsDao.getAllSettings();

      final backupData = {
        "version": _backupVersion,
        "timestamp": DateTime.now().toIso8601String(),
        "customers": customers.map((c) => c.toMap()).toList(),
        "entries": entries.map((e) => e.toMap()).toList(),
        "payments": payments.map((p) => p.toMap()).toList(),
        "settings": settings,
      };

      final jsonString = jsonEncode(backupData);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/dudh_ka_hisab_backup.json');
      await file.writeAsString(jsonString);

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'दूध का हिसाब बैकअप फाइल',
      );
      return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
    } catch (e) {
      return false;
    }
  }

  /// Imports database from a selected JSON file.
  Future<String> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return "कोई फाइल चुनी नहीं गई";
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (!data.containsKey("version")) {
        return "गलत फाइल प्रारूप (प्रारूप वर्शन नहीं मिला)";
      }

      final db = await DairyDatabase.instance.database;

      await db.transaction((txn) async {
        // Clear existing tables
        await txn.delete('entries');
        await txn.delete('payments');
        await txn.delete('customers');
        await txn.delete('settings');

        // Restore Settings
        if (data.containsKey("settings")) {
          final settings = Map<String, dynamic>.from(data["settings"]);
          for (final entry in settings.entries) {
            await txn.insert('settings', {
              'key': entry.key,
              'value': entry.value.toString(),
            });
          }
        }

        // Restore Customers
        if (data.containsKey("customers")) {
          final customersList = List<Map<String, dynamic>>.from(data["customers"]);
          for (final rawCustomer in customersList) {
            await txn.insert('customers', rawCustomer);
          }
        }

        // Restore Entries
        if (data.containsKey("entries")) {
          final entriesList = List<Map<String, dynamic>>.from(data["entries"]);
          for (final rawEntry in entriesList) {
            await txn.insert('entries', rawEntry);
          }
        }

        // Restore Payments
        if (data.containsKey("payments")) {
          final paymentsList = List<Map<String, dynamic>>.from(data["payments"]);
          for (final rawPayment in paymentsList) {
            await txn.insert('payments', rawPayment);
          }
        }
      });

      return "सफलतापूर्वक डेटा रीस्टोर हो गया!";
    } catch (e) {
      return "त्रुटि: रीस्टोर विफल रहा (${e.toString()})";
    }
  }
}
