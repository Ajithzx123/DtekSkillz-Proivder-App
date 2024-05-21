// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../../app/generalImports.dart';

abstract class CreatePromocodeState {}

class CreatePromocodeInitial extends CreatePromocodeState {}

class CreatePromocodeInProgress extends CreatePromocodeState {}

class CreatePromocodeSuccess extends CreatePromocodeState {
  final PromocodeModel promocode;
  final String? id;
  CreatePromocodeSuccess({
    this.id,
    required this.promocode,
  });
}

class CreatePromocodeFailure extends CreatePromocodeState {
  final String errorMessage;

  CreatePromocodeFailure(this.errorMessage);
}

class CreatePromocodeCubit extends Cubit<CreatePromocodeState> {
  final PromocodeRepository _promocodeRepository = PromocodeRepository();
  CreatePromocodeCubit() : super(CreatePromocodeInitial());

  Future<void> createPromocode(
    CreatePromocodeModel model,
  ) async {
    try {
      emit(CreatePromocodeInProgress());
      final result = await _promocodeRepository.createPromocode(
        model,
      );
      emit(CreatePromocodeSuccess(
          id: model.promo_id, promocode: PromocodeModel.fromJson(result[0]),),);
    } catch (e) {
      emit(CreatePromocodeFailure(e.toString()));
    }
  }
}
