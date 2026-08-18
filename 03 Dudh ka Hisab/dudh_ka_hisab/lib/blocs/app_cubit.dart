import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/dao/settings_dao.dart';

/// Global app state — holds mode, language, and rate configuration.
class AppState {
  final String mode; // 'kisan' or 'doodhwala'
  final String language; // 'hi' or 'en'
  final String rateType; // 'flat' or 'fat'
  final double flatRate;
  final double ratePerFatPoint;
  final bool isFirstRun;
  final bool isLoading;

  const AppState({
    this.mode = 'kisan',
    this.language = 'hi',
    this.rateType = 'flat',
    this.flatRate = 60.0,
    this.ratePerFatPoint = 6.8,
    this.isFirstRun = true,
    this.isLoading = true,
  });

  AppState copyWith({
    String? mode,
    String? language,
    String? rateType,
    double? flatRate,
    double? ratePerFatPoint,
    bool? isFirstRun,
    bool? isLoading,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      language: language ?? this.language,
      rateType: rateType ?? this.rateType,
      flatRate: flatRate ?? this.flatRate,
      ratePerFatPoint: ratePerFatPoint ?? this.ratePerFatPoint,
      isFirstRun: isFirstRun ?? this.isFirstRun,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isKisanMode => mode == 'kisan';
  bool get isDoodhwalaMode => mode == 'doodhwala';
  bool get isFatBased => rateType == 'fat';
}

/// Cubit that manages global app configuration.
class AppCubit extends Cubit<AppState> {
  final SettingsDao _settingsDao = SettingsDao();

  AppCubit() : super(const AppState());

  /// Load all settings from database on app start.
  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));

    final mode = await _settingsDao.getMode();
    final language = await _settingsDao.getLanguage();
    final rateType = await _settingsDao.getRateType();
    final flatRate = await _settingsDao.getFlatRate();
    final ratePerFatPoint = await _settingsDao.getRatePerFatPoint();
    final isFirstRun = await _settingsDao.isFirstRun();

    emit(AppState(
      mode: mode,
      language: language,
      rateType: rateType,
      flatRate: flatRate,
      ratePerFatPoint: ratePerFatPoint,
      isFirstRun: isFirstRun,
      isLoading: false,
    ));
  }

  /// Switch between किसान and दूधवाला mode.
  Future<void> setMode(String mode) async {
    await _settingsDao.setMode(mode);
    emit(state.copyWith(mode: mode));
  }

  /// Change app language.
  Future<void> setLanguage(String langCode) async {
    await _settingsDao.setLanguage(langCode);
    emit(state.copyWith(language: langCode));
  }

  /// Update flat rate.
  Future<void> setFlatRate(double rate) async {
    await _settingsDao.setFlatRate(rate);
    emit(state.copyWith(flatRate: rate));
  }

  /// Update rate per fat point.
  Future<void> setRatePerFatPoint(double rate) async {
    await _settingsDao.setRatePerFatPoint(rate);
    emit(state.copyWith(ratePerFatPoint: rate));
  }

  /// Switch rate type (flat / fat-based).
  Future<void> setRateType(String type) async {
    await _settingsDao.setRateType(type);
    emit(state.copyWith(rateType: type));
  }

  /// Mark first run as complete (after mode selection).
  Future<void> completeFirstRun() async {
    await _settingsDao.setFirstRunComplete();
    emit(state.copyWith(isFirstRun: false));
  }
}
