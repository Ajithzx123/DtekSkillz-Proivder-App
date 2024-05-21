// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../app/generalImports.dart';

abstract class FetchStatisticsState {}

class FetchStatisticsInitial extends FetchStatisticsState {}

class FetchStatisticsInProgress extends FetchStatisticsState {}

class FetchStatisticsSuccess extends FetchStatisticsState {
  final StatisticsModel statistics;
  FetchStatisticsSuccess({
    required this.statistics,
  });
}

class FetchStatisticsFailure extends FetchStatisticsState {
  final String errorMessage;

  FetchStatisticsFailure(this.errorMessage);
}

class FetchStatisticsCubit extends Cubit<FetchStatisticsState> {
  final StatisticsRepository _statisticsRepository = StatisticsRepository();

  FetchStatisticsCubit() : super(FetchStatisticsInitial());

  Future<void> getStatistics() async {
    try {
      emit(FetchStatisticsInProgress());
      final StatisticsModel result = await _statisticsRepository.fetchStatistics();

      emit(FetchStatisticsSuccess(statistics: result));
    } catch (e) {
      emit(FetchStatisticsFailure(e.toString()));
    }
  }
}
