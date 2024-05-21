// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class FetchWithdrawalRequestState {}

class FetchWithdrawalRequestInitial extends FetchWithdrawalRequestState {}

class FetchWithdrawalRequestInProgress extends FetchWithdrawalRequestState {}

class FetchWithdrawalRequestSuccess extends FetchWithdrawalRequestState {
  final bool isLoadingMore;
  final bool hasError;
  final int offset;
  final int total;
  final List<WithdrawalModel> withdrawals;
  FetchWithdrawalRequestSuccess({
    required this.isLoadingMore,
    required this.hasError,
    required this.offset,
    required this.total,
    required this.withdrawals,
  });

  FetchWithdrawalRequestSuccess copyWith({
    bool? isLoadingMore,
    bool? hasError,
    int? offset,
    int? total,
    List<WithdrawalModel>? withdrawals,
  }) {
    return FetchWithdrawalRequestSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      offset: offset ?? this.offset,
      total: total ?? this.total,
      withdrawals: withdrawals ?? this.withdrawals,
    );
  }
}

class FetchWithdrawalRequestFailure extends FetchWithdrawalRequestState {
  final String errorMessage;

  FetchWithdrawalRequestFailure(this.errorMessage);
}

class FetchWithdrawalRequestCubit extends Cubit<FetchWithdrawalRequestState> {
  FetchWithdrawalRequestCubit() : super(FetchWithdrawalRequestInitial());
  final CommissionAmountRepository _commissionAmountRepository = CommissionAmountRepository();
  Future<void> fetchWithdrawals() async {
    try {
      emit(FetchWithdrawalRequestInProgress());
      final Map<String, dynamic> parameter = {
        Api.offset: '0',
        Api.limit: Constant.limit,
        Api.order: Api.descending
      };

      final DataOutput<WithdrawalModel> result =
          await _commissionAmountRepository.fetchWithdrawalRequests(parameter: parameter);
      emit(FetchWithdrawalRequestSuccess(
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          total: result.total,
          withdrawals: result.modelList,),);
    } catch (e) {
      emit(FetchWithdrawalRequestFailure(e.toString()));
    }
  }

  Future<void> fetchMoreWithdrawals() async {
    try {
      if (state is FetchWithdrawalRequestSuccess) {
        if ((state as FetchWithdrawalRequestSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchWithdrawalRequestSuccess).copyWith(isLoadingMore: true));

        final Map<String, dynamic> parameter = {
          Api.offset: (state as FetchWithdrawalRequestSuccess).offset,
          Api.limit: Constant.limit,
          Api.order: Api.descending
        };

        final DataOutput<WithdrawalModel> result =
            await _commissionAmountRepository.fetchWithdrawalRequests(parameter: parameter);

        final FetchWithdrawalRequestSuccess withdrawalState = state as FetchWithdrawalRequestSuccess;
        withdrawalState.withdrawals.addAll(result.modelList);
        emit(
          FetchWithdrawalRequestSuccess(
            isLoadingMore: false,
            hasError: false,
            withdrawals: withdrawalState.withdrawals,
            offset: (state as FetchWithdrawalRequestSuccess).offset + Constant.limit,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchWithdrawalRequestSuccess).copyWith(
          isLoadingMore: false,
          hasError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchWithdrawalRequestSuccess) {
      return (state as FetchWithdrawalRequestSuccess).offset <
          (state as FetchWithdrawalRequestSuccess).total;
    }
    return false;
  }
}
