import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/backup_service.dart';

abstract class BackupState {}

class BackupInitial extends BackupState {}

class BackupInProgress extends BackupState {}

class BackupSuccess extends BackupState {
  final String message;
  BackupSuccess(this.message);
}

class BackupFailure extends BackupState {
  final String error;
  BackupFailure(this.error);
}

class BackupCubit extends Cubit<BackupState> {
  final BackupService _backupService = BackupService();

  BackupCubit() : super(BackupInitial());

  Future<void> runExport() async {
    emit(BackupInProgress());
    final success = await _backupService.exportBackup();
    if (success) {
      emit(BackupSuccess("बैकअप फाइल सफलतापूर्वक शेयर की गई!"));
    } else {
      emit(BackupFailure("बैकअप निर्यात करने में विफल रहा।"));
    }
  }

  Future<void> runImport() async {
    emit(BackupInProgress());
    final result = await _backupService.importBackup();
    if (result.contains("सफलतापूर्वक")) {
      emit(BackupSuccess(result));
    } else {
      emit(BackupFailure(result));
    }
  }

  Future<bool> runAutoDetectRestore() async {
    emit(BackupInProgress());
    final detected = await _backupService.detectExistingBackup();
    if (detected == null) {
      emit(BackupFailure("कोई पुराना ऑटो-बैकअप नहीं मिला।"));
      return false;
    }

    final success = await _backupService.restoreFromDetectedBackup(detected);
    if (success) {
      emit(BackupSuccess("🎉 आपका पूरा पुराना डेटा 1-क्लिक में रीस्टोर हो गया!"));
      return true;
    } else {
      emit(BackupFailure("रीस्टोर करने में समस्या आई।"));
      return false;
    }
  }
}
