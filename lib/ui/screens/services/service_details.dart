import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../app/generalImports.dart';

class ServiceDetails extends StatefulWidget {
  const ServiceDetails({
    super.key,
    required this.service,
  });
  final ServiceModel service;

  @override
  ServiceDetailsState createState() => ServiceDetailsState();

  static Route<ServiceDetails> route(RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;

    return CupertinoPageRoute(
      builder: (_) => ServiceDetails(
        service: arguments['serviceModel'],
      ),
    );
  }
}

class ServiceDetailsState extends State<ServiceDetails> {
  Map<String, String> allowNotAllowFilter = {'0': 'notAllowed', '1': 'allowed'};

  @override
  void initState() {
    context
        .read<FetchServiceReviewsCubit>()
        .fetchReviews(int.parse(widget.service.id!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        elevation: 1,
        centerTitle: true,
        title: CustomText(
          titleText: 'serviceDetailsLbl'.translate(context: context),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontColor: Theme.of(context).colorScheme.blackColor,
        ),
        leading: UiUtils.setBackArrow(
          context,
        ),
      ),
      body: mainWidget(),
    );
  }

  Widget mainWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryWidget(),
          showDivider(),
          descriptionWidget(),
          showDivider(),
          // durationWidget(),
          // showDivider(),
          // serviceDetailsWidget(),
          if (widget.service.otherImages != null &&
              widget.service.otherImages!.isNotEmpty)
            otherImagesWidget(),
          if (widget.service.files != null && widget.service.files!.isNotEmpty)
            filesImagesWidget(),
          if (widget.service.faqs != null && widget.service.faqs!.isNotEmpty)
            faqsWidget(),
          if (widget.service.longDescription != null &&
              widget.service.longDescription.toString().trim().isNotEmpty)
            longDescriotionWidget(),
          setRatingsAndReviews()
        ],
      ),
    );
  }

  Widget otherImagesWidget() {
    return CustomContainer(
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      cornerRadius: 15,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          showDivider(),
          const SizedBox(height: 10),
          CustomText(
            titleText: 'otherImages'.translate(context: context),
            fontWeight: FontWeight.w700,
            fontColor: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.service.otherImages!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.imagePreviewScreen,
                        arguments: {
                          'startFrom': index,
                          'isReviewType': false,
                          'dataURL': widget.service.otherImages!
                        },
                      ).then((Object? value) {
                        //locked in portrait mode only
                        SystemChrome.setPreferredOrientations(
                          [
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown
                          ],
                        );
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: UiUtils.setNetworkImage(
                        widget.service.otherImages![index],
                        ww: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filesImagesWidget() {
    return CustomContainer(
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      cornerRadius: 15,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          showDivider(),
          const SizedBox(height: 10),
          CustomText(
            titleText: 'files'.translate(context: context),
            fontWeight: FontWeight.w700,
            fontColor: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(widget.service.files!.length, (index) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      launchUrl(
                        Uri.parse(widget.service.files![index]),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Theme.of(context).colorScheme.lightGreyColor,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            UiUtils.extractFileName(
                              widget.service.files![index],
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!(index == widget.service.files!.length - 1))
                    const Divider(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget longDescriotionWidget() {
    return CustomContainer(
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      cornerRadius: 15,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          showDivider(),
          const SizedBox(height: 10),
          CustomText(
            titleText: 'serviceDescription'.translate(context: context),
            fontWeight: FontWeight.w700,
            fontColor: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const SizedBox(height: 10),
          HtmlWidget(widget.service.longDescription.toString()),
        ],
      ),
    );
  }

  Widget faqsWidget() {
    return CustomContainer(
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      cornerRadius: 15,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          showDivider(),
          const SizedBox(height: 10),
          CustomText(
            titleText: 'faqsFull'.translate(context: context),
            fontWeight: FontWeight.w700,
            fontColor: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const SizedBox(height: 10),
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: List.generate(
                  widget.service.faqs!.length,
                  (final int index) {
                    bool isExpanded = false;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          onExpansionChanged: (final bool value) {
                            setState(() {
                              isExpanded = value;
                            });
                          },
                          trailing: isExpanded
                              ? const Icon(
                                  Icons.keyboard_arrow_up_outlined,
                                )
                              : const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                ),
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          collapsedIconColor:
                              Theme.of(context).colorScheme.blackColor,
                          expandedAlignment: Alignment.topLeft,

                          title: Text(
                            widget.service.faqs![index].question ?? "",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.blackColor,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                          //controlAffinity: ListTileControlAffinity.leading,
                          children: <Widget>[
                            Text(
                              widget.service.faqs![index].answer ?? "",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .lightGreyColor,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget showDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).colorScheme.lightGreyColor,
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    Color? subTitleBackgroundColor,
    Color? subTitleColor,
    double? width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          titleText: title.translate(context: context),
          fontSize: 14,
          maxLines: 2,
          fontColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: width,
          decoration: BoxDecoration(
            color:
                subTitleBackgroundColor?.withOpacity(0.2) ?? Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: CustomText(
            titleText: subDetails,
            fontSize: 14,
            maxLines: 2,
            fontColor:
                subTitleColor ?? Theme.of(context).colorScheme.blackColor,
          ),
        ),
      ],
    );
  }

  Widget summaryWidget() {
    return CustomContainer(
      cornerRadius: 15,
      height: 170,
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: UiUtils.setNetworkImage(
                    widget.service.imageOfTheService!,
                    ww: 70,
                    hh: 90,
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: SizedBox(
                  height: 90,
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        titleText: widget.service.title!.firstUpperCase(),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        fontColor: Theme.of(context).colorScheme.blackColor,
                      ),
                      setStars(
                        double.parse(widget.service.rating!),
                        atCenter: Alignment.centerLeft,
                      ),
                      CustomText(
                        titleText:
                            "${"reviewsTab".translate(context: context)} (${widget.service.numberOfRatings})",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontColor: Theme.of(context).colorScheme.blackColor,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              if (widget.service.discountedPrice != '0')
                Expanded(
                  child: getTitleAndSubDetails(
                    title: 'discountPriceLbl',
                    subDetails:
                        "${Constant.systemCurrency}${widget.service.discountedPrice!}",
                  ),
                ),
              Expanded(
                child: getTitleAndSubDetails(
                  title: 'totalPriceLbl',
                  subDetails:
                      "${Constant.systemCurrency}${widget.service.price!}",
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget setStars(double ratings, {required Alignment atCenter}) {
    return RatingBar.readOnly(
      initialRating: ratings,
      isHalfAllowed: true,
      halfFilledIcon: Icons.star_half,
      filledIcon: Icons.star_rounded,
      emptyIcon: Icons.star_border_rounded,
      filledColor: AppColors.starRatingColor,
      halfFilledColor: AppColors.starRatingColor,
      emptyColor: Theme.of(context).colorScheme.lightGreyColor,
      aligns: atCenter,
      onRatingChanged: (double rating) {},
    );
  }

  Widget getTitle({required String title}) {
    return CustomText(
      titleText: title.translate(context: context),
      maxLines: 1,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      fontColor: Theme.of(context).colorScheme.blackColor,
    );
  }

  Widget descriptionWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.secondaryColor,
      ),
      padding: const EdgeInsets.all(10),
      child: getTitleAndSubDetails(
        title: 'aboutService',
        subDetails: widget.service.description!,
      ),
    );
  }

  Widget durationWidget() {
    return CustomContainer(
      cornerRadius: 15,
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            titleText: 'durationLbl'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                titleText: 'durationDescrLbl'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontColor: Theme.of(context).colorScheme.lightGreyColor,
              ),
              CustomText(
                titleText:
                    "${widget.service.duration!} ${"minutes".translate(context: context)}",
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontColor: Theme.of(context).colorScheme.blackColor,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                titleText: 'requiredMembers'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontColor: Theme.of(context).colorScheme.blackColor,
              ),
              CustomText(
                titleText: widget.service.numberOfMembersRequired!,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontColor: Theme.of(context).colorScheme.blackColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget serviceDetailsWidget() {
    print("door ${widget.service.isDoorStepAllowed!}");
    print("store ${widget.service.isStoreAllowed!}");
    return CustomContainer(
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      cornerRadius: 15,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            titleText: 'serviceDetailsLbl'.translate(context: context),
            fontWeight: FontWeight.w700,
            fontColor: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const SizedBox(height: 10),
          getTitleAndSubDetailsWithBackgroundColor(
            title: 'statusLbl',
            subDetails: widget.service.status!.translate(context: context),
            subTitleColor: widget.service.status!.capitalize() == 'Enable'
                ? AppColors.greenColor
                : AppColors.redColor,
            subTitleBackgroundColor:
                widget.service.status!.capitalize() == 'Enable'
                    ? AppColors.greenColor
                    : AppColors.redColor,
          ),
          const SizedBox(height: 10),
          setKeyValueRow(
            key: 'cancelableBeforeLbl'.translate(context: context),
            value:
                "${widget.service.cancelableTill!} ${"minutes".translate(context: context)}",
          ),
          const SizedBox(height: 10),
          setKeyValueRow(
            key: 'isCancelableLbl'.translate(context: context),
            value: allowNotAllowFilter[widget.service.isCancelable!]!
                .translate(context: context),
          ),
          const SizedBox(height: 10),
          setKeyValueRow(
            key: 'isPayLaterAllowed'.translate(context: context),
            value: allowNotAllowFilter[widget.service.isPayLaterAllowed!]!
                .translate(context: context),
          ),
          const SizedBox(height: 10),
          setKeyValueRow(
            key: 'atStoreAllowed'.translate(context: context),
            value: allowNotAllowFilter[widget.service.isStoreAllowed!]!
                .translate(context: context),
          ),
          const SizedBox(height: 10),
          setKeyValueRow(
            key: 'atDoorstepAllowed'.translate(context: context),
            value: allowNotAllowFilter[widget.service.isDoorStepAllowed!]!
                .translate(context: context),
          ),
          const SizedBox(height: 10),
          setKeyValueRow(
            key: 'taxTypeLbl'.translate(context: context),
            value: widget.service.taxType!
                .translate(context: context)
                .capitalize(),
          ),
        ],
      ),
    );
  }

  Widget getTitleAndSubDetailsWithBackgroundColor({
    required String title,
    required String subDetails,
    Color? subTitleBackgroundColor,
    Color? subTitleColor,
    double? width,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          titleText: title.translate(context: context),
          fontSize: 14,
          maxLines: 2,
          fontColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
        Container(
          width: width,
          constraints: const BoxConstraints(minWidth: 100),
          decoration: BoxDecoration(
            color:
                subTitleBackgroundColor?.withOpacity(0.2) ?? Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(5),
          child: Center(
            child: CustomText(
              titleText: subDetails,
              fontSize: 14,
              maxLines: 2,
              fontColor:
                  subTitleColor ?? Theme.of(context).colorScheme.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget setKeyValueRow({required String key, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          titleText: key,
          fontWeight: FontWeight.w400,
          fontColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
        CustomText(
          titleText: value,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontColor: Theme.of(context).colorScheme.blackColor,
        ),
      ],
    );
  }

  Widget setRatingsAndReviews() {
    return BlocBuilder<FetchServiceReviewsCubit, FetchServiceReviewsState>(
      builder: (BuildContext context, FetchServiceReviewsState state) {
        if (state is FetchServiceReviewsInProgress) {
          return const ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 100,
            ),
          );
        }

        if (state is FetchServiceReviewsFailure) {
          return Container();
        }

        if (state is FetchServiceReviewsSuccess) {
          if (state.reviews.isEmpty) {
            return Container();
          }
          return Column(
            children: [
              showDivider(),
              CustomContainer(
                bgColor: Theme.of(context).colorScheme.secondaryColor,
                cornerRadius: 15,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      titleText:
                          'reviewsRatingsLbl'.translate(context: context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontColor: Theme.of(context).colorScheme.blackColor,
                    ),
                    Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .lightGreyColor
                          .withOpacity(0.4),
                    ),
                    ratingsWidget(state),
                    Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .lightGreyColor
                          .withOpacity(0.4),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      // padding: const EdgeInsets.only(top: 5, bottom: 5),
                      physics: const NeverScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemBuilder: (BuildContext context, int index) {
                        final ReviewsModel rating = state.reviews[index];
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: UiUtils.setNetworkImage(
                                    rating.profileImage!,
                                    hh: 60,
                                    ww: 60,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomText(
                                              fontColor: Theme.of(context)
                                                  .colorScheme
                                                  .blackColor,
                                              titleText: rating.userName!,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                            width: 45,
                                            child: CustomIconButton(
                                              borderRadius: 5,
                                              imgName: 'star',
                                              titleText: rating.rating!,
                                              fontSize: 10,
                                              titleColor: Theme.of(context)
                                                  .colorScheme
                                                  .blackColor,
                                              bgColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryColor,
                                              iconColor: Theme.of(context)
                                                  .colorScheme
                                                  .blackColor,
                                              borderColor: Theme.of(context)
                                                  .colorScheme
                                                  .lightGreyColor,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      CustomText(
                                        titleText: rating.ratedOn
                                            .toString()
                                            .formatDateAndTime(),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        fontColor: Theme.of(context)
                                            .colorScheme
                                            .lightGreyColor,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      CustomText(
                                        titleText: rating.comment!,
                                        fontSize: 12,
                                        fontColor: Theme.of(context)
                                            .colorScheme
                                            .lightGreyColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (rating.images!.isNotEmpty)
                              SizedBox(
                                height: 65,
                                child: setReviewImages(reviewDetails: rating),
                              ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .lightGreyColor
                              .withOpacity(0.4),
                        );
                      },
                      itemCount: state.reviews.length,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }

  Widget setReviewImages({required ReviewsModel reviewDetails}) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: List.generate(
        reviewDetails.images!.length,
        (int index) => InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            Routes.imagePreviewScreen,
            arguments: {'reviewDetails': reviewDetails, 'startFrom': index},
          ).then((Object? value) {
            //locked in portrait mode only
            SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
            );
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
        ),
      ),
    );
  }

  Widget ratingsWidget(FetchServiceReviewsSuccess state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomText(
          titleText: state.ratings.averageRating!.length <= 4
              ? state.ratings.averageRating.toString()
              : state.ratings.averageRating.toString().substring(0, 4),
          fontColor: Theme.of(context).colorScheme.blackColor,
          fontSize: 20,
        ),
        setStars(
          double.parse(state.ratings.averageRating!),
          atCenter: Alignment.center,
        ),
        CustomText(
          titleText:
              "${"reviewsTab".translate(context: context)} (${state.total})",
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
      ],
    );
  }
}
