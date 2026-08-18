import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/dao/settings_dao.dart';

/// Global app state — holds mode, language, rate configuration, and reminders.
class AppState {
  final String mode; // 'kisan' or 'doodhwala'
  final String language; // 'hi' or 'en'
  final String rateType; // 'flat' or 'fat'
  final double flatRate;
  final double ratePerFatPoint;
  final bool isFirstRun;
  final bool isLoading;
  final String stateCode; // e.g. 'UP'
  final List<String> occupations; // ['dudh','pashu','kheti']

  // Reminder settings — Customizable
  final bool morningReminderEnabled;
  final String morningReminderTime; // format: "HH:mm"
  final bool eveningReminderEnabled;
  final String eveningReminderTime; // format: "HH:mm"

  // Theme settings — Light, Dark, System
  final String themeMode; // 'light', 'dark', 'system'

  // Font Scaling accessibility — 1.0 (Normal), 1.2 (Large), 1.4 (Extra Large)
  final double fontScale;

  const AppState({
    this.mode = 'doodhwala',
    this.language = 'hi',
    this.rateType = 'flat',
    this.flatRate = 60.0,
    this.ratePerFatPoint = 6.8,
    this.isFirstRun = true,
    this.isLoading = true,
    this.stateCode = 'UP',
    this.occupations = const [],
    this.morningReminderEnabled = true,
    this.morningReminderTime = '08:30',
    this.eveningReminderEnabled = true,
    this.eveningReminderTime = '20:30',
    this.themeMode = 'light',
    this.fontScale = 1.0,
  });

  AppState copyWith({
    String? mode,
    String? language,
    String? rateType,
    double? flatRate,
    double? ratePerFatPoint,
    bool? isFirstRun,
    bool? isLoading,
    String? stateCode,
    List<String>? occupations,
    bool? morningReminderEnabled,
    String? morningReminderTime,
    bool? eveningReminderEnabled,
    String? eveningReminderTime,
    String? themeMode,
    double? fontScale,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      language: language ?? this.language,
      rateType: rateType ?? this.rateType,
      flatRate: flatRate ?? this.flatRate,
      ratePerFatPoint: ratePerFatPoint ?? this.ratePerFatPoint,
      isFirstRun: isFirstRun ?? this.isFirstRun,
      isLoading: isLoading ?? this.isLoading,
      stateCode: stateCode ?? this.stateCode,
      occupations: occupations ?? this.occupations,
      morningReminderEnabled: morningReminderEnabled ?? this.morningReminderEnabled,
      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderEnabled: eveningReminderEnabled ?? this.eveningReminderEnabled,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
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
    String mode = 'kisan';
    String language = 'hi';
    String rateType = 'flat';
    double flatRate = 60.0;
    double ratePerFatPoint = 6.8;
    bool isFirstRun = false;
    String stateCode = 'UP';
    List<String> occupations = [];

    bool morningEnabled = true;
    String morningTime = '08:30';
    bool eveningEnabled = true;
    String eveningTime = '20:30';
    String themeMode = 'light';
    double fontScale = 1.0;

    try {
      // mode अब हमेशा 'doodhwala' — किसान/दूधवाला का बँटवारा हटा दिया गया।
      // ग्राहक हों तो ग्राहक-वाला flow अपने-आप दिखता है, न हों तो एंट्री
      // अपने खाते में जाती है। पुराना stored mode जान-बूझकर नहीं पढ़ते।
      mode = 'doodhwala';
      try { language = await _settingsDao.getLanguage(); } catch (_) {}
      try { rateType = await _settingsDao.getRateType(); } catch (_) {}
      try { flatRate = await _settingsDao.getFlatRate(); } catch (_) {}
      try { ratePerFatPoint = await _settingsDao.getRatePerFatPoint(); } catch (_) {}
      try { stateCode = await _settingsDao.getStateCode(); } catch (_) {}
      try { occupations = await _settingsDao.getOccupations(); } catch (_) {}
      try { morningEnabled = await _settingsDao.isMorningReminderEnabled(); } catch (_) {}
      try { morningTime = await _settingsDao.getMorningReminderTime(); } catch (_) {}
      try { eveningEnabled = await _settingsDao.isEveningReminderEnabled(); } catch (_) {}
      try { eveningTime = await _settingsDao.getEveningReminderTime(); } catch (_) {}
      try {
        final tm = await _settingsDao.getSetting('theme_mode');
        if (tm != null) themeMode = tm;
      } catch (_) {}
      try {
        final fs = await _settingsDao.getSetting('font_scale');
        if (fs != null) fontScale = double.tryParse(fs) ?? 1.0;
      } catch (_) {}

      try {
        isFirstRun = await _settingsDao.isFirstRun();
      } catch (_) {
        isFirstRun = true;
      }

      emit(AppState(
        mode: mode,
        language: language,
        rateType: rateType,
        flatRate: flatRate,
        ratePerFatPoint: ratePerFatPoint,
        isFirstRun: isFirstRun,
        isLoading: false,
        stateCode: stateCode,
        occupations: occupations,
        morningReminderEnabled: morningEnabled,
        morningReminderTime: morningTime,
        eveningReminderEnabled: eveningEnabled,
        eveningReminderTime: eveningTime,
        themeMode: themeMode,
        fontScale: fontScale,
      ));
    } catch (_) {
      emit(const AppState(isLoading: false, isFirstRun: false));
    }
  }

  /// Set the user's state (राज्य).
  Future<void> setStateCode(String code) async {
    await _settingsDao.setStateCode(code);
    emit(state.copyWith(stateCode: code));
  }

  /// Set the user's occupations (dudh/pashu/kheti).
  Future<void> setOccupations(List<String> occ) async {
    await _settingsDao.setOccupations(occ);
    emit(state.copyWith(occupations: occ));
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

  /// Update morning reminder configuration.
  Future<void> updateMorningReminder({bool? enabled, String? time}) async {
    if (enabled != null) {
      await _settingsDao.setMorningReminderEnabled(enabled);
    }
    if (time != null) {
      await _settingsDao.setMorningReminderTime(time);
    }
    emit(state.copyWith(
      morningReminderEnabled: enabled ?? state.morningReminderEnabled,
      morningReminderTime: time ?? state.morningReminderTime,
    ));
  }

  /// Update evening reminder configuration.
  Future<void> updateEveningReminder({bool? enabled, String? time}) async {
    if (enabled != null) {
      await _settingsDao.setEveningReminderEnabled(enabled);
    }
    if (time != null) {
      await _settingsDao.setEveningReminderTime(time);
    }
    emit(state.copyWith(
      eveningReminderEnabled: enabled ?? state.eveningReminderEnabled,
      eveningReminderTime: time ?? state.eveningReminderTime,
    ));
  }

  /// Mark first run as complete (after mode selection).
  Future<void> completeFirstRun() async {
    await _settingsDao.setFirstRunComplete();
    emit(state.copyWith(isFirstRun: false));
  }

  /// Update theme mode ('light', 'dark', 'system').
  Future<void> setThemeMode(String mode) async {
    await _settingsDao.setSetting('theme_mode', mode);
    emit(state.copyWith(themeMode: mode));
  }

  /// Update font scaling factor (1.0, 1.2, 1.4).
  Future<void> setFontScale(double scale) async {
    await _settingsDao.setSetting('font_scale', scale.toString());
    emit(state.copyWith(fontScale: scale));
  }
}
