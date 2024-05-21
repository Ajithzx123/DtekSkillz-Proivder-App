// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class UpdateFCMState {}

class UpdateFCMInitial extends UpdateFCMState {}

class UpdateFCMInProgress extends UpdateFCMState {}

class UpdateFCMSuccess extends UpdateFCMState {
  final String error;
  final String message;

  UpdateFCMSuccess({
    required this.error,
    required this.message,
  });
}

class UpdateFCMFailure extends UpdateFCMState {
  final String errorMessage;

  UpdateFCMFailure(this.errorMessage);
}

class UpdateFCMCubit extends Cubit<UpdateFCMState> {
  final SettingsRepository _settingsRepository = SettingsRepository();

  UpdateFCMCubit() : super(UpdateFCMInitial());

  Future<void> updateFCMId({
    required final String fcmID,
    required final String platform,
  }) async {
    try {
      emit(UpdateFCMInProgress());
      final response = await _settingsRepository.updateFCM(fcmId: fcmID, platform: platform);
      print("calling api");
      emit(
        UpdateFCMSuccess(
          message: response['message'],
          error: response['error'].toString(),
        ),
      );
    } catch (e) {
      emit(UpdateFCMFailure(e.toString()));
    }
  }
}
