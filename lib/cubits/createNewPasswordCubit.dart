import '../../app/generalImports.dart';

abstract class CreateNewPasswordState {}

class CreateNewPasswordInitial extends CreateNewPasswordState {}

class CreateNewPasswordInProgress extends CreateNewPasswordState {}

class CreateNewPasswordSuccess extends CreateNewPasswordState {}

class CreateNewPasswordFailure extends CreateNewPasswordState {

  CreateNewPasswordFailure(this.errorMessage);
  final String errorMessage;
}

class CreateNewPasswordCubit extends Cubit<CreateNewPasswordState> {
  CreateNewPasswordCubit() : super(CreateNewPasswordInitial());

  final AuthRepository _authRepository = AuthRepository();

  Future createNewPassword(
      {required String countryCode,
      required String mobileNumber,
      required String newPassword,}) async {
    //
    try {
      //
      emit(CreateNewPasswordInProgress());
      //
      await _authRepository.createNewPassword(
          countryCode: countryCode, newPassword: newPassword, mobileNumber: mobileNumber,);

      emit(CreateNewPasswordSuccess());
    } catch (e) {
      emit(CreateNewPasswordFailure(e.toString()));
    }
  }
}
