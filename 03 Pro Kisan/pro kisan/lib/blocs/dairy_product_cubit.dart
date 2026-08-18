import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../db/dao/dairy_product_dao.dart';
import '../db/models/dairy_product_entry.dart';

/// State classes for DairyProductCubit.
abstract class DairyProductState {}

class DairyProductInitial extends DairyProductState {}

class DairyProductLoading extends DairyProductState {}

class DairyProductLoaded extends DairyProductState {
  final List<DairyProductEntry> todayEntries;
  final List<DairyProductEntry> monthlyEntries;
  final Map<String, double> monthlyTotals;

  DairyProductLoaded({
    required this.todayEntries,
    required this.monthlyEntries,
    required this.monthlyTotals,
  });
}

/// Cubit that manages dairy product entries.
class DairyProductCubit extends Cubit<DairyProductState> {
  final DairyProductDao _dao = DairyProductDao();

  DairyProductCubit() : super(DairyProductInitial());

  /// Load today's and monthly data.
  Future<void> loadData() async {
    emit(DairyProductLoading());

    try {
      final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final month = DateFormat('MM-yyyy').format(DateTime.now());

      final todayEntries = await _dao.getEntriesByDate(today);
      final monthlyEntries = await _dao.getMonthlyEntries(month);
      final monthlyTotals = await _dao.getMonthlyTotals(month);

      emit(DairyProductLoaded(
        todayEntries: todayEntries,
        monthlyEntries: monthlyEntries,
        monthlyTotals: monthlyTotals,
      ));
    } catch (_) {
      // Fallback to empty
      emit(DairyProductLoaded(
        todayEntries: [],
        monthlyEntries: [],
        monthlyTotals: {
          'totalMilkUsed': 0,
          'totalProductQty': 0,
          'totalAmount': 0,
          'entryCount': 0,
        },
      ));
    }
  }

  /// Add a new dairy product entry.
  Future<void> addEntry(DairyProductEntry entry) async {
    await _dao.insertEntry(entry);
    await loadData();
  }

  /// Delete a dairy product entry.
  Future<void> deleteEntry(int id) async {
    await _dao.deleteEntry(id);
    await loadData();
  }
}
