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
}
