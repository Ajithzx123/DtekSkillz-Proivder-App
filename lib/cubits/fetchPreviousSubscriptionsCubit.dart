// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class FetchPreviousSubscriptionsState {}

class FetchPreviousSubscriptionsInitial extends FetchPreviousSubscriptionsState {}

class FetchPreviousSubscriptionsInProgress extends FetchPreviousSubscriptionsState {}

class FetchPreviousSubscriptionsSuccess extends FetchPreviousSubscriptionsState {
  final bool isLoadingMoreSubscriptions;
  final bool loadingMoreSubscriptionError;
  final List<SubscriptionInformation> subscriptionsData;
  final int totalSubscriptions;

  FetchPreviousSubscriptionsSuccess({
    required this.isLoadingMoreSubscriptions,
    required this.loadingMoreSubscriptionError,
    required this.subscriptionsData,
    required this.totalSubscriptions,
  });

  FetchPreviousSubscriptionsSuccess copyWith({
    final bool? isLoadingMoreSubscriptions,
    final bool? loadingMoreSubscriptionError,
    final List<SubscriptionInformation>? subscriptionsData,
    final int? offset,
    final int? totalSubscriptions,
  }) {
    return FetchPreviousSubscriptionsSuccess(
      isLoadingMoreSubscriptions: isLoadingMoreSubscriptions ?? this.isLoadingMoreSubscriptions,
      loadingMoreSubscriptionError:
          loadingMoreSubscriptionError ?? this.loadingMoreSubscriptionError,
      subscriptionsData: subscriptionsData ?? this.subscriptionsData,
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
    );
  }
}

class FetchPreviousSubscriptionsFailure extends FetchPreviousSubscriptionsState {
  final String errorMessage;

  FetchPreviousSubscriptionsFailure(this.errorMessage);
}

class FetchMorePreviousSubscriptionsFailure extends FetchPreviousSubscriptionsState {
  final String errorMessage;

  FetchMorePreviousSubscriptionsFailure(this.errorMessage);
}

class FetchPreviousSubscriptionsCubit extends Cubit<FetchPreviousSubscriptionsState> {
  //
  FetchPreviousSubscriptionsCubit() : super(FetchPreviousSubscriptionsInitial());

  final SubscriptionsRepository _subscriptionsRepository = SubscriptionsRepository();

  Future<void> fetchPreviousSubscriptions() async {
    try {
      emit(FetchPreviousSubscriptionsInProgress());

      final Map<String, dynamic> subscriptionsData =
          await _subscriptionsRepository.fetchPreviousSubscriptionsList(offset: "0");

      emit(
        FetchPreviousSubscriptionsSuccess(
          isLoadingMoreSubscriptions: false,
          loadingMoreSubscriptionError: false,
          subscriptionsData: subscriptionsData['data'],
          totalSubscriptions: int.parse(subscriptionsData['total']),
        ),
      );
    } catch (e) {
      emit(FetchPreviousSubscriptionsFailure(e.toString()));
    }
  }

  Future<void> fetchMorePreviousSubscriptions() async {
    try {
      final FetchPreviousSubscriptionsSuccess currentState =
          state as FetchPreviousSubscriptionsSuccess;
      //
      if(currentState.isLoadingMoreSubscriptions){
        return;
      }
      emit(
        currentState.copyWith(
          isLoadingMoreSubscriptions: true,
        ),
      );
      //
      final Map<String, dynamic> subscriptionsData = await _subscriptionsRepository
          .fetchPreviousSubscriptionsList(offset: currentState.subscriptionsData.length.toString());

      final List<SubscriptionInformation> oldSubscriptions = currentState.subscriptionsData;
      oldSubscriptions.addAll(subscriptionsData['data']);
      emit(
        currentState.copyWith(
          isLoadingMoreSubscriptions: false,
          loadingMoreSubscriptionError: false,
          subscriptionsData: oldSubscriptions,
          totalSubscriptions: int.parse(subscriptionsData['total']),
        ),
      );
    } catch (e) {
      emit(FetchMorePreviousSubscriptionsFailure(e.toString()));
    }
  }

  bool hasMoreData() {
    if (state is FetchPreviousSubscriptionsSuccess) {
      return (state as FetchPreviousSubscriptionsSuccess).subscriptionsData.length <
          (state as FetchPreviousSubscriptionsSuccess).totalSubscriptions;
    }
    return false;
  }
}
