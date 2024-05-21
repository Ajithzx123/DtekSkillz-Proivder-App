// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class DeletePromocodeState {}

class DeletePromocodeInitial extends DeletePromocodeState {}

class DeletePromocodeInProgress extends DeletePromocodeState {}

class DeletePromocodeSuccess extends DeletePromocodeState {
  final int id;
  DeletePromocodeSuccess({
    required this.id,
  });
}

class DeletePromocodeFailure extends DeletePromocodeState {
  final String errorMessage;

  DeletePromocodeFailure(this.errorMessage);
}

class DeletePromocodeCubit extends Cubit<DeletePromocodeState> {
  DeletePromocodeCubit() : super(DeletePromocodeInitial());
  final PromocodeRepository _promocodeRepository = PromocodeRepository();
  Future<void> deletePromocode(int id, {required VoidCallback onDelete}) async {
    try {
      emit(DeletePromocodeInProgress());
      await _promocodeRepository.deletePromocode(id);

      onDelete.call();
      emit(DeletePromocodeSuccess(id: id));
    } catch (e) {
      emit(DeletePromocodeFailure(e.toString()));
    }
  }
}
