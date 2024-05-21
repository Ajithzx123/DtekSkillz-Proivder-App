// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class FetchBookingsState {}

class FetchBookingsInitial extends FetchBookingsState {}

class FetchBookingsInProgress extends FetchBookingsState {}

class FetchBookingsSuccess extends FetchBookingsState {
  final bool isLoadingMoreBookings;
  final bool loadingMoreBookingsError;
  final List<BookingsModel> bookings;
  final int offset;
  final int total;

  FetchBookingsSuccess({
    required this.isLoadingMoreBookings,
    required this.loadingMoreBookingsError,
    required this.bookings,
    required this.offset,
    required this.total,
  });

  FetchBookingsSuccess copyWith({
    bool? isLoadingMoreBookings,
    bool? loadingMoreBookingsError,
    List<BookingsModel>? bookings,
    int? offset,
    int? total,
  }) {
    return FetchBookingsSuccess(
      isLoadingMoreBookings: isLoadingMoreBookings ?? this.isLoadingMoreBookings,
      loadingMoreBookingsError: loadingMoreBookingsError ?? this.loadingMoreBookingsError,
      bookings: bookings ?? this.bookings,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchBookingsFailure extends FetchBookingsState {
  final String errorMessage;

  FetchBookingsFailure(this.errorMessage);
}

class FetchBookingsCubit extends Cubit<FetchBookingsState> {
  FetchBookingsCubit() : super(FetchBookingsInitial());
  final BookingsRepository _bookingsRepository = BookingsRepository();

  Future<void> fetchBookings(String? status) async {
    try {
      emit(FetchBookingsInProgress());

      final DataOutput<BookingsModel> result =
          await _bookingsRepository.fetchBooking(offset: 0, status: status);

      emit(FetchBookingsSuccess(
          isLoadingMoreBookings: false,
          loadingMoreBookingsError: false,
          bookings: result.modelList,
          offset: 0,
          total: result.total,),);
    } catch (e) {
      emit(FetchBookingsFailure(e.toString()));
    }
  }

  Future<void> fetchMoreBookings(String? status) async {
    try {
      if (state is FetchBookingsSuccess) {
        if ((state as FetchBookingsSuccess).isLoadingMoreBookings) {
          return;
        }
        emit((state as FetchBookingsSuccess).copyWith(isLoadingMoreBookings: true));
        final DataOutput<BookingsModel> result = await _bookingsRepository.fetchBooking(
            offset: (state as FetchBookingsSuccess).offset + Constant.limit, status: status,);

        final FetchBookingsSuccess bookingsState = state as FetchBookingsSuccess;
        bookingsState.bookings.addAll(result.modelList);
        emit(FetchBookingsSuccess(
            isLoadingMoreBookings: false,
            loadingMoreBookingsError: false,
            bookings: bookingsState.bookings,
            offset: (state as FetchBookingsSuccess).offset + Constant.limit,
            total: result.total,),);
      }
    } catch (e) {
      emit((state as FetchBookingsSuccess)
          .copyWith(isLoadingMoreBookings: false, loadingMoreBookingsError: true),);
    }
  }

  void updateBookingDetailsLocally(
      {required String bookingID,
      required String bookingStatus,
      List<dynamic>? listOfUploadedImages,}) {
    //

    if (state is FetchBookingsSuccess) {
      //
      final List<BookingsModel> bookings = (state as FetchBookingsSuccess).bookings;
      final int indexInList = bookings.indexWhere((BookingsModel element) {
        return element.id == bookingID;
      });
      //update the status
      bookings[indexInList].status = bookingStatus;
      //update the uploaded images according to the status
      if (bookingStatus == 'started') {
        bookings[indexInList].workStartedProof = listOfUploadedImages ?? [];
      } else if (bookingStatus == 'completed') {
        bookings[indexInList].workCompletedProof = listOfUploadedImages ?? [];
      }

      emit((state as FetchBookingsSuccess).copyWith(bookings: bookings));
      //
    }
  }

  bool hasMoreData() {
    if (state is FetchBookingsSuccess) {
      return (state as FetchBookingsSuccess).offset < (state as FetchBookingsSuccess).total;
    }
    return false;
  }
}
