import '../../app/generalImports.dart';

abstract class ResendOtpState {}

class ResendOtpInitial extends ResendOtpState {}

class ResendOtpInProcess extends ResendOtpState {}

class ResendOtpSuccess extends ResendOtpState {}

class ResendOtpFail extends ResendOtpState {

  ResendOtpFail(this.error);
  final dynamic error;
}

class ResendOtpCubit extends Cubit<ResendOtpState> {

  ResendOtpCubit() : super(ResendOtpInitial());
  final AuthRepository authRepo = AuthRepository();

  Future<void> resendOtp(String phoneNumber, {VoidCallback? onOtpSent}) async {
    try {
      emit(ResendOtpInProcess());
      await authRepo.verifyPhoneNumber(
        phoneNumber,
        onError: (err) {
          emit(ResendOtpFail(err));
        },
        onCodeSent: () {
          onOtpSent?.call();
          emit(ResendOtpSuccess());
        },
      );
      // await Future.delayed(const Duration(milliseconds: 400));
    } on FirebaseAuthException catch (error) {
      emit(ResendOtpFail(error));
    }
  }

  void setDefaultOtpState() {
    emit(ResendOtpInitial());
  }
}
