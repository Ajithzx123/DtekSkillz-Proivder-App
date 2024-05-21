// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class DeleteServiceState {}

class DeleteServiceInitial extends DeleteServiceState {}

class DeleteServiceInProgress extends DeleteServiceState {}

class DeleteServiceSuccess extends DeleteServiceState {
  final int id;
  DeleteServiceSuccess({
    required this.id,
  });
}

class DeleteServiceFailure extends DeleteServiceState {
  final String errorMessage;

  DeleteServiceFailure(this.errorMessage);
}

class DeleteServiceCubit extends Cubit<DeleteServiceState> {
  DeleteServiceCubit() : super(DeleteServiceInitial());
  final ServiceRepository _repository = ServiceRepository();
  Future<void> deleteService(int id, {required VoidCallback onDelete}) async {
    try {
      emit(DeleteServiceInProgress());
      await _repository.deleteService(id: id);
      onDelete.call();
      emit(DeleteServiceSuccess(id: id));
    } catch (e) {
      emit(DeleteServiceFailure(e.toString()));
    }
  }
}
