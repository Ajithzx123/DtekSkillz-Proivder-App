// ignore_for_file: file_names

import '../../app/generalImports.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpInProcess extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {

  VerifyOtpSuccess(this.signInCredential);
  UserCredential signInCredential;
}

class VerifyOtpFail extends VerifyOtpState {

  VerifyOtpFail(this.error);
  final dynamic error;
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {

  VerifyOtpCubit() : super(VerifyOtpInitial());
  final AuthRepository authRepo = AuthRepository();

  Future<void> verifyOtp(String otp) async {
    try {
      emit(VerifyOtpInProcess());
      await authRepo.verifyOtp(
          code: otp,
          onVerificationSuccess: (UserCredential signinCredential) {
            emit(VerifyOtpSuccess(signinCredential));
          },);
    } on FirebaseAuthException catch (error) {
      emit(VerifyOtpFail(error));
    }
  }

  void setInitialState() {
    if (state is VerifyOtpFail) {
      emit(VerifyOtpInitial());
    }
    if (state is VerifyOtpSuccess) {
      emit(VerifyOtpInitial());
    }
  }
}
