import 'package:flutter/material.dart';

import '../../app/generalImports.dart';
import '../../utils/checkURLType.dart';
import 'customVideoPlayer/playVideoScreen.dart';
import 'package:intl/intl.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    required this.reviewDetails,
    required this.startFrom,
    required this.isReviewType,
    required this.dataURL,
  });

  final ReviewsModel? reviewDetails;
  final int startFrom;
  final bool isReviewType;
  final List<dynamic> dataURL;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();

  static Route route(RouteSettings settings) {
    final Map arguments = settings.arguments as Map;
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return ImagePreview(
          reviewDetails: arguments['reviewDetails'] ?? ReviewsModel(),
          startFrom: arguments['startFrom'],
          isReviewType: arguments['isReviewType'],
          dataURL: arguments['dataURL'],
        );
      },
    );
  }
}

class _ImagePreviewState extends State<ImagePreview> with TickerProviderStateMixin {
  //
  ValueNotifier<bool> isShowData = ValueNotifier(true);

//
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> opacityAnimation = Tween<double>(
    begin: 1,
    end: 0,
  ).animate(
    CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
    ),
  );

  //
  late final PageController _pageController = PageController(initialPage: widget.startFrom);

  @override
  void dispose() {
    isShowData.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.dataURL.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    if (widget.isReviewType) {
                      isShowData.value = !isShowData.value;

                      if (isShowData.value) {
                        animationController.forward();
                      } else {
                        animationController.reverse();
                      }
                    }
                  },
                  child: UrlTypeHelper.getType(widget.dataURL[index]) == UrlType.image
                      ? CustomCachedNetworkImage(imageUrl: widget.dataURL[index])
                      : PlayVideoScreen(
                          videoURL: widget.dataURL[index],
                        ),
                );
              },
            ),
            PositionedDirectional(
              start: 5,
              top: 10,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (BuildContext context, Widget? child) => Opacity(
                  opacity: opacityAnimation.value,
                  child: Container(
                    height: 35,
                    width: 35,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: UiUtils.setSVGImage(
                          context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                              ? Directionality.of(context)
                                      .toString()
                                      .contains(TextDirection.RTL.value.toLowerCase())
                                  ? 'back_arrow_dark_ltr'
                                  : 'back_arrow_dark'
                              : Directionality.of(context)
                                      .toString()
                                      .contains(TextDirection.RTL.value.toLowerCase())
                                  ? 'back_arrow_light_ltr'
                                  : 'back_arrow_light',
                          height: 25,
                          width: 25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isReviewType) ...[
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (BuildContext context, Widget? child) => Opacity(
                    opacity: opacityAnimation.value,
                    child: Container(
                      constraints:
                          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.3),
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.blackColor.withOpacity(0.35),
                            offset: const Offset(0, 0.75),
                            spreadRadius: 5,
                            blurRadius: 25,
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            minRadius: 15,
                            maxRadius: 20,
                            child: CustomCachedNetworkImage(
                              imageUrl: widget.reviewDetails!.profileImage ?? '',
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          SingleChildScrollView(
                            clipBehavior: Clip.none,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  widget.reviewDetails!.comment ?? '',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                                StarRating(
                                  rating: double.parse(widget.reviewDetails!.rating!),
                                  onRatingChanged: (double rating) => rating,
                                ),
                                Text(
                                  "${widget.reviewDetails!.userName ?? ""}, ${widget.reviewDetails!.ratedOn!.convertToAgo(context: context)}",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondaryColor,
                                    fontSize: 12,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
