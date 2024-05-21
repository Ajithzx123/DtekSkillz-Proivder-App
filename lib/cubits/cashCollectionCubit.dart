// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class CashCollectionState {}

class FetchCashCollectionInitial extends CashCollectionState {}

class CashCollectionFetchInProgress extends CashCollectionState {}

class CashCollectionFetchSuccess extends CashCollectionState {
  final bool isLoadingMore;
  final bool hasError;
  final int offset;
  final int total;
  final String totalPayableCommission;
  final List<CashCollectionModel> cashCollectionData;

  CashCollectionFetchSuccess({
    required this.isLoadingMore,
    required this.hasError,
    required this.offset,
    required this.total,
    required this.totalPayableCommission,
    required this.cashCollectionData,
  });

  CashCollectionFetchSuccess copyWith(
      {bool? isLoadingMore,
      bool? hasError,
      int? offset,
      int? total,
      List<CashCollectionModel>? cashCollectionData,
      String? totalPayableCommission,}) {
    return CashCollectionFetchSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      totalPayableCommission: totalPayableCommission ?? this.totalPayableCommission,
      offset: offset ?? this.offset,
      total: total ?? this.total,
      cashCollectionData: cashCollectionData ?? this.cashCollectionData,
    );
  }
}

class CashCollectionFetchFailure extends CashCollectionState {
  final String errorMessage;

  CashCollectionFetchFailure(this.errorMessage);
}

class CashCollectionCubit extends Cubit<CashCollectionState> {
  CashCollectionCubit() : super(FetchCashCollectionInitial());

  //
  final CommissionAmountRepository _commissionAmountRepository = CommissionAmountRepository();

  //
  Future<void> fetchCashCollection() async {
    try {
      //
      emit(CashCollectionFetchInProgress());
      //
      final Map<String, dynamic> parameter = {
        'provider_cash_recevied': 1,
        Api.order: Api.descending,
        Api.offset: '0',
        Api.limit: Constant.limit,
      };
      final DataOutput<CashCollectionModel> result =
          await _commissionAmountRepository.fetchCashCollectionHistory(parameter: parameter);
      //

      emit(CashCollectionFetchSuccess(
          totalPayableCommission: result.extraData?.data['totalPayableCommission'],
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          total: result.total,
          cashCollectionData: result.modelList,),);
    } catch (e) {
      emit(CashCollectionFetchFailure(e.toString()));
    }
  }

  Future<void> fetchMoreCashCollection() async {
    try {
      if (state is CashCollectionFetchSuccess) {
        if ((state as CashCollectionFetchSuccess).isLoadingMore) {
          return;
        }
        emit((state as CashCollectionFetchSuccess).copyWith(isLoadingMore: true));

        final Map<String, dynamic> parameter = {
          'provider_cash_recevied': 1,
          Api.offset: (state as CashCollectionFetchSuccess).offset,
          Api.limit: Constant.limit,
          Api.order: Api.descending
        };
        final DataOutput<CashCollectionModel> result =
            await _commissionAmountRepository.fetchCashCollectionHistory(parameter: parameter);

        (state as CashCollectionFetchSuccess).cashCollectionData.addAll(result.modelList);
        //
        emit(
          CashCollectionFetchSuccess(
            isLoadingMore: false,
            hasError: false,
            totalPayableCommission: (state as CashCollectionFetchSuccess).totalPayableCommission,
            cashCollectionData: (state as CashCollectionFetchSuccess).cashCollectionData,
            offset: (state as CashCollectionFetchSuccess).offset + Constant.limit,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as CashCollectionFetchSuccess).copyWith(
          isLoadingMore: false,
          hasError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is CashCollectionFetchSuccess) {
      return (state as CashCollectionFetchSuccess).offset <
          (state as CashCollectionFetchSuccess).total;
    }
    return false;
  }

  void emitSuccessState() {
    if (state is CashCollectionFetchSuccess) {
      final CashCollectionFetchSuccess successState = state as CashCollectionFetchSuccess;

      emit(CashCollectionFetchSuccess(
          isLoadingMore: successState.isLoadingMore,
          hasError: successState.hasError,
          offset: successState.offset,
          total: successState.total,
          totalPayableCommission: successState.totalPayableCommission,
          cashCollectionData: successState.cashCollectionData,),);
    }
  }
}
