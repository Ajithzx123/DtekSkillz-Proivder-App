// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class FetchServiceReviewsState {}

class FetchServiceReviewsInitial extends FetchServiceReviewsState {}

class FetchServiceReviewsInProgress extends FetchServiceReviewsState {}

class FetchServiceReviewsSuccess extends FetchServiceReviewsState {
  final bool isLoadingMoreReviews;
  final bool loadingMoreReviewsError;
  final List<ReviewsModel> reviews;
  final RatingsModel ratings;
  final int offset;
  final int total;
  FetchServiceReviewsSuccess({
    required this.isLoadingMoreReviews,
    required this.loadingMoreReviewsError,
    required this.reviews,
    required this.ratings,
    required this.offset,
    required this.total,
  });
}

class FetchServiceReviewsFailure extends FetchServiceReviewsState {
  final String errorMessage;

  FetchServiceReviewsFailure(this.errorMessage);
}

class FetchServiceReviewsCubit extends Cubit<FetchServiceReviewsState> {
  FetchServiceReviewsCubit() : super(FetchServiceReviewsInitial());
  final ServiceRepository _serviceRepository = ServiceRepository();
  Future<void> fetchReviews(int id) async {
    try {
      emit(FetchServiceReviewsInProgress());
      final DataOutput<ReviewsModel> result = await _serviceRepository.fetchReviews(id, offset: 0);

      emit(FetchServiceReviewsSuccess(
          reviews: result.modelList,
          isLoadingMoreReviews: false,
          loadingMoreReviewsError: false,
          offset: 0,
          ratings: result.extraData?.data,
          total: result.total,),);
    } catch (e) {
      emit(FetchServiceReviewsFailure(e.toString()));
    }
  }
}
