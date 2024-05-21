// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class FetchReviewsState {}

class FetchReviewsInitial extends FetchReviewsState {}

class FetchReviewsInProgress extends FetchReviewsState {}

class FetchReviewsSuccess extends FetchReviewsState {
  final bool isLoadingMoreReviews;
  final bool loadingMoreReviewsError;
  final List<ReviewsModel> reviews;
  final RatingsModel ratings;
  final int offset;
  final int total;
  FetchReviewsSuccess(
      {required this.isLoadingMoreReviews,
      required this.loadingMoreReviewsError,
      required this.reviews,
      required this.offset,
      required this.total,
      required this.ratings,});

  FetchReviewsSuccess copyWith(
      {bool? isLoadingMoreReviews,
      bool? loadingMoreReviewsError,
      List<ReviewsModel>? bookings,
      int? offset,
      int? total,
      RatingsModel? ratings,}) {
    return FetchReviewsSuccess(
        isLoadingMoreReviews: isLoadingMoreReviews ?? this.isLoadingMoreReviews,
        loadingMoreReviewsError: loadingMoreReviewsError ?? this.loadingMoreReviewsError,
        reviews: bookings ?? reviews,
        offset: offset ?? this.offset,
        total: total ?? this.total,
        ratings: ratings ?? this.ratings,);
  }
}

class FetchReviewsFailure extends FetchReviewsState {
  final String errorMessage;

  FetchReviewsFailure(this.errorMessage);
}

class FetchReviewsCubit extends Cubit<FetchReviewsState> {
  FetchReviewsCubit() : super(FetchReviewsInitial());
  final ReviewsRepository _reviewsRepository = ReviewsRepository();
  //
  Future<void>fetchReviews() async {
    try {
      emit(FetchReviewsInProgress());
      final DataOutput<ReviewsModel> result = await _reviewsRepository.fetchReviews(offset: 0);

      emit(FetchReviewsSuccess(
          reviews: result.modelList,
          isLoadingMoreReviews: false,
          loadingMoreReviewsError: false,
          offset: 0,
          ratings: result.extraData?.data,
          total: result.total,),);
    } catch (e) {
      emit(FetchReviewsFailure(e.toString()));
    }
  }

  Future<void> fetchMoreReviews() async {
    if (state is FetchReviewsSuccess) {
      try {
        if ((state as FetchReviewsSuccess).isLoadingMoreReviews) {
          return;
        }
        emit((state as FetchReviewsSuccess).copyWith(isLoadingMoreReviews: true));

        final DataOutput<ReviewsModel> result = await _reviewsRepository.fetchReviews(
            offset: (state as FetchReviewsSuccess).offset + Constant.limit,);

        final FetchReviewsSuccess reviewsState = state as FetchReviewsSuccess;

        reviewsState.reviews.addAll(result.modelList);

        emit(FetchReviewsSuccess(
            isLoadingMoreReviews: false,
            loadingMoreReviewsError: false,
            reviews: reviewsState.reviews,
            offset: (state as FetchReviewsSuccess).offset + Constant.limit,
            ratings: result.extraData?.data,
            total: result.total,),);
      } catch (e) {
        emit((state as FetchReviewsSuccess)
            .copyWith(isLoadingMoreReviews: false, loadingMoreReviewsError: true),);
      }
    }
  }

  bool hasMoreReviews() {
    if (state is FetchReviewsSuccess) {
      return (state as FetchReviewsSuccess).offset < (state as FetchReviewsSuccess).total;
    }

    return false;
  }
}
