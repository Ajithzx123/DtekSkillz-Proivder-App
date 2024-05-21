import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class ReviewsScreen extends StatefulWidget {

  const ReviewsScreen({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  ReviewsScreenState createState() => ReviewsScreenState();
}

class ReviewsScreenState extends State<ReviewsScreen> with AutomaticKeepAliveClientMixin {
  // double progress = 0.5;
  double twoStarVal = 20;
  double avg = 0;

  @override
  void initState() {
    context.read<FetchReviewsCubit>().fetchReviews();
    widget.scrollController.addListener(pageScrollListen);
    super.initState();
  }

  void pageScrollListen() {
    if (widget.scrollController.isEndReached()) {
      if (context.read<FetchReviewsCubit>().hasMoreReviews()) {
        context.read<FetchReviewsCubit>().fetchMoreReviews();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<FetchReviewsCubit>().fetchReviews();
          },
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            clipBehavior: Clip.none,
            physics: const AlwaysScrollableScrollPhysics(),
            child: BlocBuilder<FetchReviewsCubit, FetchReviewsState>(
              builder: (BuildContext context, FetchReviewsState state) {
                if (state is FetchReviewsSuccess) {}
                return Column(
                  children: [
                    ratingsSummary(state),
                    buildWidget(state),
                    const SizedBox(
                      height: 5,
                    ),
                    if (state is FetchReviewsSuccess) ...[
                      if (state.isLoadingMoreReviews)
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.accentColor,
                        )
                    ]
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget ratingsSummary(FetchReviewsState state) {
    if (state is FetchReviewsInProgress) {
      return const ShimmerLoadingContainer(
          child: CustomShimmerContainer(
        height: 125,
      ),);
    }

    if (state is FetchReviewsSuccess) {
      final double fiveStarPercentage = double.parse(state.ratings.rating5!) /
          double.parse(state.ratings.totalRatings!) *
          100;
      final double fourStarPercentage = double.parse(state.ratings.rating4!) /
          double.parse(state.ratings.totalRatings!) *
          100;
      final double threeStarPercentage = double.parse(state.ratings.rating3!) /
          double.parse(state.ratings.totalRatings!) *
          100;
      final double twoStarPercentage = double.parse(state.ratings.rating2!) /
          double.parse(state.ratings.totalRatings!) *
          100;
      final double oneStarPercentage = double.parse(state.ratings.rating1!) /
          double.parse(state.ratings.totalRatings!) *
          100;
      if (state.reviews.isEmpty) {
        return NoDataContainer(titleKey: 'noDataFound'.translate(context: context));
      }
      return CustomContainer(
        height: 120,
        cornerRadius: 10,
        bgColor: Theme.of(context).colorScheme.secondaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            totalReviews(state),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                setLinearProgressIndicator(semanticLbl: '5star', progressVal: fiveStarPercentage),
                setLinearProgressIndicator(semanticLbl: '4star', progressVal: fourStarPercentage),
                setLinearProgressIndicator(semanticLbl: '3star', progressVal: threeStarPercentage),
                setLinearProgressIndicator(semanticLbl: '2star', progressVal: twoStarPercentage),
                setLinearProgressIndicator(
                  semanticLbl: '1star',
                  progressVal: oneStarPercentage,
                ),
              ],
            )
          ],
        ),
      );
    }
    return Container();
  }

  Widget totalReviews(FetchReviewsSuccess state) {
    return SizedBox(
      height: 80,
      width: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomText(
            titleText: state.ratings.averageRating!.length <= 4
                ? state.ratings.averageRating.toString()
                : state.ratings.averageRating.toString().substring(0, 4),
            fontSize: 26,
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          SizedBox(
            // color: AppColors.whiteColor,
            child: RatingBar.readOnly(
              initialRating: double.parse(state.ratings.averageRating!),
              //2.5,
              isHalfAllowed: true,
              halfFilledIcon: Icons.star_half,
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              filledColor: AppColors.starRatingColor,
              halfFilledColor: AppColors.starRatingColor,
              emptyColor: AppColors.starRatingColor,
              onRatingChanged: (double rating) {},
            ),
          ),
          CustomText(
            titleText: '${"totalReviewsLbl".translate(context: context)} (${state.total})',
            fontSize: 10,
            fontColor: Theme.of(context).colorScheme.lightGreyColor,
          )
        ],
      ),
    );
  }

  Widget setLinearProgressIndicator({
    double height = 10,
    double width = 150,
    Color? bgColor,
    Animation<Color?>? valueColor = const AlwaysStoppedAnimation<Color>(AppColors.greenColor),
    required double progressVal,
    required String semanticLbl,
  }) {
    return Wrap(
      spacing: 5,
      children: [
        CustomText(
          titleText: semanticLbl.substring(0, 1),
          fontColor: Theme.of(context).colorScheme.blackColor,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(
          height: height,
          width: width,
          child: CustomTweenAnimation(
              curve: Curves.fastLinearToSlowEaseIn,
              beginValue: 0,
              endValue: progressVal.isNaN ? 0 : progressVal,
              durationInSeconds: 1,
              builder: (BuildContext context, double value, Widget? child) => ProgressBar(
                    max: 100,
                    current: value.isNaN ? 0 : value,
                  ),),
        ),
      ],
    );
  }

  Widget buildWidget(FetchReviewsState state) {
    if (state is FetchReviewsInProgress) {
      return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsetsDirectional.only(top: 20),
          itemCount: 8,
          physics: const NeverScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                height: 128.rh(context),
              ),),
            );
          },);
    }

    if (state is FetchReviewsFailure) {
      return Center(
          child: ErrorContainer(
              onTapRetry: () {
                context.read<FetchReviewsCubit>().fetchReviews();
              },
              errorMessage: state.errorMessage.translate(context: context),),);
    }

    if (state is FetchReviewsSuccess) {
      return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsetsDirectional.only(
          top: 20,
        ),
        itemCount: state.reviews.length,
        physics: const NeverScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        itemBuilder: (BuildContext context, int index) {
          final ReviewsModel review = state.reviews[index];
          final bool hasReviewText = state.reviews[index].comment?.isNotEmpty ?? false;
          return CustomContainer(
              padding: const EdgeInsetsDirectional.only(start: 10, end: 10, top: 8, bottom: 5),
              margin: const EdgeInsetsDirectional.only(bottom: 10),
              cornerRadius: 10,
              bgColor: Theme.of(context).colorScheme.secondaryColor,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      titleText: review.service_name!.firstUpperCase(),
                      fontSize: 14.0,
                      fontColor: Theme.of(context).colorScheme.blackColor,
                    ),
                  ),
                  UiUtils.setDivider(context: context, height: 1),
                  setDetailsRow(model: review, hasReviewText: hasReviewText),
                  if (review.images!.isNotEmpty)
                    SizedBox(height: 65, child: setReviewImages(reviewDetails: review)),
                ],
              ),);
        },
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
              height: 10,
            ),
      );
    }
    return Container();
  }

  Widget setReviewImages({required ReviewsModel reviewDetails}) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: List.generate(
          reviewDetails.images!.length,
          (int index) => InkWell(
                onTap: () => Navigator.pushNamed(context, Routes.imagePreviewScreen, arguments: {
                  'reviewDetails': reviewDetails,
                  'startFrom': index,
                  'isReviewType': true,
                  'dataURL': reviewDetails.images
                },).then((Object? value) {
                  //locked in portrait mode only
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],);
                }),
                child: Container(
                  height: 55,
                  width: 55,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomCachedNetworkImage(
                    imageUrl: reviewDetails.images![index],
                  ),
                ),
              ),),
    );
  }

  Widget setDetailsRow({required ReviewsModel model, required bool hasReviewText}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: UiUtils.setNetworkImage(model.profileImage!, hh: 60, ww: 60),
          ),

          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  titleText: model.userName ??"",
                  fontSize: 14.rf(context),
                  fontWeight: FontWeight.normal,
                  fontColor: Theme.of(context).colorScheme.blackColor,
                ),
                if (hasReviewText) ...[
                  const SizedBox(height: 5),
                  CustomText(
                    titleText: model.comment ??"",
                    fontSize: 12.rf(context),

                    fontColor: Theme.of(context).colorScheme.blackColor,
                  ),
                  const SizedBox(height: 5),
                ] else ...[
                  const SizedBox(height: 10),
                ],
                CustomText(
                  titleText: (model.ratedOn ??"").formatDateAndTime(),
                  fontSize: 10.rf(context),
                  fontColor: Theme.of(context).colorScheme.lightGreyColor,
                ),
              ],
            ),
          ),
          //Ratings
          SizedBox(
            height: 20,
            width: 50,
            child: CustomIconButton(
              onPressed: () {},
              imgName: 'star',
              titleText: model.rating!,
              fontSize: 10.0,
              borderRadius: 5,
              borderColor: Theme.of(context).colorScheme.lightGreyColor,
              iconColor: Theme.of(context).colorScheme.blackColor,
              titleColor: Theme.of(context).colorScheme.blackColor,
              bgColor: Theme.of(context).colorScheme.secondaryColor,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],);
  }

  @override
  bool get wantKeepAlive => true;
}
