import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../db/dao/entry_dao.dart';
import '../db/dao/settings_dao.dart';
import '../db/models/milk_entry.dart';
import '../services/backup_service.dart';

/// States for the entry flow.
abstract class EntryState {}

class EntryInitial extends EntryState {}

class EntryLoading extends EntryState {}

class EntrySaved extends EntryState {
  final String message;
  EntrySaved(this.message);
}

class EntryError extends EntryState {
  final String message;
  EntryError(this.message);
}

class EntryDuplicateFound extends EntryState {
  final MilkEntry existingEntry;
  final MilkEntry newEntry;
  EntryDuplicateFound({required this.existingEntry, required this.newEntry});
}

class EntryListLoaded extends EntryState {
  final List<MilkEntry> entries;
  final Map<String, double> monthlyTotals;
  EntryListLoaded({required this.entries, required this.monthlyTotals});
}

/// Cubit that manages daily milk entry operations.
class EntryCubit extends Cubit<EntryState> {
  final EntryDao _entryDao = EntryDao();
  final SettingsDao _settingsDao = SettingsDao();

  EntryCubit() : super(EntryInitial());

  /// Load recent entries + current month totals for home screen.
  Future<void> loadHomeData() async {
    emit(EntryLoading());
    final now = DateTime.now();
    final month = DateFormat('MM-yyyy').format(now);
    final recentEntries = await _entryDao.getRecentEntries(limit: 15);
    final totals = await _entryDao.getMonthlyDirectionalTotals(month);
    emit(EntryListLoaded(entries: recentEntries, monthlyTotals: totals));
  }

  /// Save a new milk entry — checks for duplicates first.
  Future<void> saveEntry({
    int? customerId,
    required String date,
    required String shift,
    required double qtyL,
    double? fatPct,
    double? snf,
    required double amount,
    String direction = 'sell',
  }) async {
    emit(EntryLoading());

    final newEntry = MilkEntry(
      customerId: customerId,
      date: date,
      shift: shift,
      qtyL: qtyL,
      fatPct: fatPct,
      snf: snf,
      amount: amount,
      direction: direction,
    );

    // Check for duplicate entry (same date + shift + customer)
    final existing = await _entryDao.findDuplicate(date, shift, customerId);
    if (existing != null) {
      emit(EntryDuplicateFound(existingEntry: existing, newEntry: newEntry));
      return;
    }

    await _entryDao.insertEntry(newEntry);
    await _settingsDao.incrementEntryCount();
    BackupService().autoSaveToPublicFolder();
    emit(EntrySaved('✅ एंट्री सेव हो गई!'));
  }

  /// Replace existing entry (when user chooses "बदलें" on duplicate).
  Future<void> replaceEntry(MilkEntry existing, MilkEntry newEntry) async {
    emit(EntryLoading());
    final updated = newEntry.copyWith(id: existing.id);
    await _entryDao.updateEntry(updated);
    BackupService().autoSaveToPublicFolder();
    emit(EntrySaved('✅ एंट्री अपडेट हो गई!'));
  }

  /// Add alongside existing (when user chooses "जोड़ें" on duplicate).
  Future<void> addAlongside(MilkEntry newEntry) async {
    emit(EntryLoading());
    await _entryDao.insertEntry(newEntry);
    await _settingsDao.incrementEntryCount();
    BackupService().autoSaveToPublicFolder();
    emit(EntrySaved('✅ नई एंट्री जोड़ दी गई!'));
  }

  /// Delete an entry.
  Future<void> deleteEntry(int entryId) async {
    await _entryDao.deleteEntry(entryId);
    BackupService().autoSaveToPublicFolder();
    await loadHomeData(); // refresh list
  }

  /// Edit an existing entry.
  Future<void> updateEntry(MilkEntry entry) async {
    emit(EntryLoading());
    await _entryDao.updateEntry(entry);
    BackupService().autoSaveToPublicFolder();
    emit(EntrySaved('✅ एंट्री अपडेट हो गई!'));
  }

  /// Check if review prompt should show (after 15 entries).
  Future<bool> shouldShowReview() async {
    final count = await _settingsDao.getEntryCount();
    final shown = await _settingsDao.isReviewShown();
    return count >= 15 && !shown;
  }

  /// Mark review as shown.
  Future<void> markReviewShown() async {
    await _settingsDao.setReviewShown();
  }
}
