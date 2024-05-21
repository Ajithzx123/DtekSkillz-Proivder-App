import '../../app/generalImports.dart';

abstract class RegisterProviderState {}

class RegisterProviderInitial extends RegisterProviderState {}

class RegisterProviderInProgress extends RegisterProviderState {}

class RegisterProviderSuccess extends RegisterProviderState {

  RegisterProviderSuccess({
    required this.isError,
    required this.message,
  });
  final bool isError;
  final String message;
}

class RegisterProviderFailure extends RegisterProviderState {

  RegisterProviderFailure({required this.errorMessage});
  final String errorMessage;
}

class RegisterProviderCubit extends Cubit<RegisterProviderState> {

  RegisterProviderCubit() : super(RegisterProviderInitial());
  final AuthRepository _authRepository = AuthRepository();

  //
  //This method is used to register provider
  Future<void> registerProvider({required Map<String, dynamic> parameter}) async {
    try {
      emit(RegisterProviderInProgress());
      //

      final Map<String, dynamic> responseData =
          await _authRepository.registerProvider(parameters: parameter, isAuthTokenRequired: false);

      //
      if (!responseData['error']) {
        emit(RegisterProviderSuccess(
            isError: responseData['error'], message: responseData['message'],),);
        return;
      }
      //
      emit(RegisterProviderFailure(errorMessage: responseData['message']));
    } catch (e, st) {

      emit(RegisterProviderFailure(errorMessage: st.toString()));
    }
  }
}
