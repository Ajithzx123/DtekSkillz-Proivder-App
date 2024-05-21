import 'package:edemand_partner/app/generalImports.dart';

abstract class DeleteAccountState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountInProgress extends DeleteAccountState {}

class DeleteAccountSuccess extends DeleteAccountState {}

class DeleteAccountFailure extends DeleteAccountState {

  DeleteAccountFailure(this.errorMessage);
  final String errorMessage;
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(DeleteAccountInitial());

  final AuthRepository _authRepository = AuthRepository();
  Future deleteAccount() async {
    try {
      emit(DeleteAccountInProgress());
      await _authRepository.deleteUserAccount();
      await HiveUtils.clear();
      emit(DeleteAccountSuccess());
    } catch (e) {
      emit(DeleteAccountFailure(e.toString()));
    }
  }
}
