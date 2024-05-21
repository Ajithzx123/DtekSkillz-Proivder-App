import '../../app/generalImports.dart';

abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInInProgress extends SignInState {}

class SignInSuccess extends SignInState {

  SignInSuccess({
    required this.providerDetails,
    required this.error,
    required this.message,
  });
  final ProviderDetails providerDetails;
  final bool error;
  final String message;
}

class SignInFailure extends SignInState {

  SignInFailure(this.errorMessage);
  final String errorMessage;
}

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInInitial());

  final AuthRepository _authRepository = AuthRepository();

  Future<void> SignIn(
      {required String phoneNumber, required String password, required String countryCode,}) async {
    try {
      emit(SignInInProgress());
      final Map<String, dynamic> response = await _authRepository.loginUser(
          phoneNumber: phoneNumber, password: password, countryCode: countryCode,);

      if (response['userDetails'] != null) {
        emit(SignInSuccess(
            providerDetails: response['userDetails'],
            error: response['error'],
            message: response['message'],),);
      } else {
        emit(SignInFailure(response['message']));
      }
    } catch (e) {
      emit(SignInFailure(e.toString()));
    }
  }

  void setInitial() {
    emit(SignInInitial());
  }
}
