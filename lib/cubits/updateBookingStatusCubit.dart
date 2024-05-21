// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class UpdateBookingStatusState {}

class UpdateBookingStatusInitial extends UpdateBookingStatusState {}

class UpdateBookingStatusInProgress extends UpdateBookingStatusState {}

class UpdateBookingStatusSuccess extends UpdateBookingStatusState {
  final int orderId;
  final String status;
  final String error;
  final String message;
  final List<dynamic> imagesList;

  UpdateBookingStatusSuccess({
    required this.orderId,
    required this.status,
    required this.error,
    required this.message,
    required this.imagesList,
  });
}

class UpdateBookingStatusFailure extends UpdateBookingStatusState {
  final String errorMessage;

  UpdateBookingStatusFailure(this.errorMessage);
}

class UpdateBookingStatusCubit extends Cubit<UpdateBookingStatusState> {
  final BookingsRepository _bookingsRepository = BookingsRepository();

  UpdateBookingStatusCubit() : super(UpdateBookingStatusInitial());

  Future<void> updateBookingStatus({
    required int orderId,
    required int customerId,
    required String status,
    required String otp,
    List<Map<String, dynamic>>? proofData,
    String? time,
    String? date,
  }) async {
    try {

      emit(UpdateBookingStatusInProgress());
      //
      final Map<String, dynamic> response = await _bookingsRepository.updateBookingStatus(
          customerId: customerId,
          orderId: orderId,
          status: status,
          otp: otp,
          date: date,
          time: time,
          proofData: proofData,);
      //

      emit(UpdateBookingStatusSuccess(
          message: response['message'],
          error: response['error'].toString(),
          orderId: orderId,
          status: status,
          imagesList: response['data'] ?? [],),);
    } catch (e) {
      emit(UpdateBookingStatusFailure(e.toString()));
    }
  }
}
