import '../../app/generalImports.dart';

enum AuthenticationState { initial, authenticated, unAuthenticated, firstTime }

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState.initial) {
    _checkIfAuthenticated();
  }

  void _checkIfAuthenticated() {
    final bool userAuthenticated = HiveUtils.isUserAuthenticated();

    if (userAuthenticated) {
      emit(AuthenticationState.authenticated);
    } else {
      //When user installs app for first time then this state will be emitted.
      if (HiveUtils.isUserFirstTime()) {
        emit(AuthenticationState.firstTime);
      } else {
        emit(AuthenticationState.unAuthenticated);
      }
    }
  }

  void setUnAuthenticated() {
    emit(AuthenticationState.unAuthenticated);
  }
}
