// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class FetchSettlementHistoryState {}

class FetchSettlementHistoryInitial extends FetchSettlementHistoryState {}

class FetchSettlementHistoryInProgress extends FetchSettlementHistoryState {}

class FetchSettlementHistorySuccess extends FetchSettlementHistoryState {
  final bool isLoadingMore;
  final bool hasError;
  final int offset;
  final int total;
  final List<SettlementModel> settlementDetails;

  FetchSettlementHistorySuccess({
    required this.isLoadingMore,
    required this.hasError,
    required this.offset,
    required this.total,
    required this.settlementDetails,
  });

  FetchSettlementHistorySuccess copyWith({
    bool? isLoadingMore,
    bool? hasError,
    int? offset,
    int? total,
    List<SettlementModel>? settlementDetails,
  }) {
    return FetchSettlementHistorySuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      offset: offset ?? this.offset,
      total: total ?? this.total,
      settlementDetails: settlementDetails ?? this.settlementDetails,
    );
  }
}

class FetchSettlementHistoryFailure extends FetchSettlementHistoryState {
  final String errorMessage;

  FetchSettlementHistoryFailure(this.errorMessage);
}

class FetchSettlementHistoryCubit extends Cubit<FetchSettlementHistoryState> {
  FetchSettlementHistoryCubit() : super(FetchSettlementHistoryInitial());
  final CommissionAmountRepository _commissionAmountRepository = CommissionAmountRepository();

  Future<void> fetchSettlementHistory() async {
    try {
      emit(FetchSettlementHistoryInProgress());
      //
      final Map<String, dynamic> parameter = {
        Api.offset: '0',
        Api.limit: Constant.limit,
        Api.order: Api.descending
      };
      final DataOutput<SettlementModel> result =
          await _commissionAmountRepository.fetchSettlementHistory(parameter: parameter);
      //
      emit(FetchSettlementHistorySuccess(
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          total: result.total,
          settlementDetails: result.modelList,),);
    } catch (e) {
      emit(FetchSettlementHistoryFailure(e.toString()));
    }
  }

  Future<void> fetchMoreSettlementHistory() async {
    try {
      if (state is FetchSettlementHistorySuccess) {
        if ((state as FetchSettlementHistorySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchSettlementHistorySuccess).copyWith(isLoadingMore: true));

        final Map<String, dynamic> parameter = {
          Api.offset: (state as FetchSettlementHistorySuccess).offset,
          Api.limit: Constant.limit,
          Api.order: Api.descending
        };
        final DataOutput<SettlementModel> result =
            await _commissionAmountRepository.fetchSettlementHistory(parameter: parameter);

        (state as FetchSettlementHistorySuccess).settlementDetails.addAll(result.modelList);
        //
        emit(
          FetchSettlementHistorySuccess(
            isLoadingMore: false,
            hasError: false,
            settlementDetails: (state as FetchSettlementHistorySuccess).settlementDetails,
            offset: (state as FetchSettlementHistorySuccess).offset + Constant.limit,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchSettlementHistorySuccess).copyWith(
          isLoadingMore: false,
          hasError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchSettlementHistorySuccess) {
      return (state as FetchSettlementHistorySuccess).offset <
          (state as FetchSettlementHistorySuccess).total;
    }
    return false;
  }
}
