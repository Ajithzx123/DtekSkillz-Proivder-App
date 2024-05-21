//Cubit
import '../../app/generalImports.dart';

class VerifyPhoneNumberFromAPICubit extends Cubit<VerifyPhoneNumberFromAPIState> {

  VerifyPhoneNumberFromAPICubit({required this.authenticationRepository})
      : super(VerifyPhoneNumberFromAPIInitial());
  AuthRepository authenticationRepository;

  Future<void> verifyPhoneNumberFromAPI({required String mobileNumber, required String countryCode}) async {
    emit(VerifyPhoneNumberFromAPIInProgress());

    try {
      final Map<String, dynamic> value = await authenticationRepository.verifyUserMobileNumberFromAPI(
          mobileNumber: mobileNumber, countryCode: countryCode,);
      //if error is true means number already exists,
      emit(VerifyPhoneNumberFromAPISuccess(
          error: value['error'], message: value['message'], messageCode: value['messageCode'],),);
    } catch (e) {
      emit(VerifyPhoneNumberFromAPIFailure(errorMessage: e.toString()));
    }
  }
}

//State

abstract class VerifyPhoneNumberFromAPIState {}

class VerifyPhoneNumberFromAPIInitial extends VerifyPhoneNumberFromAPIState {}

class VerifyPhoneNumberFromAPIInProgress extends VerifyPhoneNumberFromAPIState {
  VerifyPhoneNumberFromAPIInProgress();
}

class VerifyPhoneNumberFromAPISuccess extends VerifyPhoneNumberFromAPIState {

  VerifyPhoneNumberFromAPISuccess(
      {required this.error, required this.message, required this.messageCode,});
  //if error is true then mobile number is already registered

  final bool error;
  final String messageCode;
  final String message;
}

class VerifyPhoneNumberFromAPIFailure extends VerifyPhoneNumberFromAPIState {

  VerifyPhoneNumberFromAPIFailure({required this.errorMessage});
  final String errorMessage;
}
