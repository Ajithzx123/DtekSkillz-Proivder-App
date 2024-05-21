// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class FetchSubscriptionsState {}

class FetchSubscriptionsInitial extends FetchSubscriptionsState {}

class FetchSubscriptionsInProgress extends FetchSubscriptionsState {}

class FetchSubscriptionsSuccess extends FetchSubscriptionsState {
  final bool isLoadingMoreSubscriptions;
  final bool loadingMoreSubscriptionError;
  final List<SubscriptionInformation> subscriptionsData;
  final int totalSubscriptions;

  FetchSubscriptionsSuccess({
    required this.isLoadingMoreSubscriptions,
    required this.loadingMoreSubscriptionError,
    required this.subscriptionsData,
    required this.totalSubscriptions,
  });

  FetchSubscriptionsSuccess copyWith({
    final bool? isLoadingMoreSubscriptions,
    final bool? loadingMoreSubscriptionError,
    final List<SubscriptionInformation>? subscriptionsData,
    final int? offset,
    final int? totalSubscriptions,
  }) {
    return FetchSubscriptionsSuccess(
      isLoadingMoreSubscriptions: isLoadingMoreSubscriptions ?? this.isLoadingMoreSubscriptions,
      loadingMoreSubscriptionError:
          loadingMoreSubscriptionError ?? this.loadingMoreSubscriptionError,
      subscriptionsData: subscriptionsData ?? this.subscriptionsData,
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
    );
  }
}

class FetchSubscriptionsFailure extends FetchSubscriptionsState {
  final String errorMessage;

  FetchSubscriptionsFailure(this.errorMessage);
}

class FetchSubscriptionsCubit extends Cubit<FetchSubscriptionsState> {
  //
  FetchSubscriptionsCubit() : super(FetchSubscriptionsInitial());

  final SubscriptionsRepository _subscriptionsRepository = SubscriptionsRepository();

  Future<void> fetchSubscriptions() async {
    try {
      emit(FetchSubscriptionsInProgress());

      final Map<String, dynamic> subscriptionsData =
          await _subscriptionsRepository.fetchSubscriptionsList();

      emit(
        FetchSubscriptionsSuccess(
          isLoadingMoreSubscriptions: false,
          loadingMoreSubscriptionError: false,
          subscriptionsData: subscriptionsData['data'],
          totalSubscriptions: int.parse(subscriptionsData['total']),
        ),
      );
    } catch (e) {
      emit(FetchSubscriptionsFailure(e.toString()));
    }
  }

  bool hasMoreData() {
    if (state is FetchSubscriptionsSuccess) {
      return (state as FetchSubscriptionsSuccess).subscriptionsData.length <
          (state as FetchSubscriptionsSuccess).totalSubscriptions;
    }
    return false;
  }
}
