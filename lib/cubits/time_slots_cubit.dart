import '../../app/generalImports.dart';

abstract class TimeSlotState {}

class TimeSlotInitial extends TimeSlotState {}

class TimeSlotFetchInProgress extends TimeSlotState {}

class TimeSlotFetchSuccess extends TimeSlotState {

  TimeSlotFetchSuccess({required this.isError, required this.message, required this.slotsData});
  final List<TimeSlotModel> slotsData;
  final bool isError;
  final String message;
}

class TimeSlotFetchFailure extends TimeSlotState {

  TimeSlotFetchFailure({required this.errorMessage});
  final String errorMessage;
}

class TimeSlotCubit extends Cubit<TimeSlotState> {
  TimeSlotCubit() : super(TimeSlotInitial());
  // CartRepository cartRepository;
  final BookingsRepository _bookingsRepository = BookingsRepository();

  //
  //This method is used to fetch timeslot details
  Future<void> getTimeslotDetails({required DateTime selectedDate}) async {
    try {
      emit(TimeSlotFetchInProgress());

      _bookingsRepository.getAllTimeSlots(selectedDate.toString().split(' ')[0]).then(
        (DataOutput<TimeSlotModel> value) {
          emit(
            TimeSlotFetchSuccess(
              message: value.extraData!.data['message'],
              isError: value.extraData!.data['error'],
              slotsData: value.modelList,
            ),
          );
          // }).catchError((onError) {
        },
      );
    } catch (e, st) {
      emit(TimeSlotFetchFailure(errorMessage: st.toString()));
    }
  }
}
