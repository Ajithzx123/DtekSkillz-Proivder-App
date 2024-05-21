import '../../app/generalImports.dart';

abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordInProgress extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {

  ChangePasswordSuccess({required this.errorMessage, required this.error});
  final String errorMessage;
  final bool error;
}

class ChangePasswordFailure extends ChangePasswordState {

  ChangePasswordFailure({required this.errorMessage, required this.error});
  final String errorMessage;
  final bool error;
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());

  final AuthRepository _authRepository = AuthRepository();

  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      emit(ChangePasswordInProgress());
      //
      final Map<String, dynamic> response =
          await _authRepository.changePassword(newPassword: newPassword, oldPassword: oldPassword);
      if (!response['error']) {
        //
        emit(ChangePasswordSuccess(error: response['error'], errorMessage: response['message']));
        //
      } else {
        //
        emit(ChangePasswordFailure(error: response['error'], errorMessage: response['message']));
        //
      }
    } catch (e) {
      emit(ChangePasswordFailure(error: true, errorMessage: e.toString()));
    }
  }
}
