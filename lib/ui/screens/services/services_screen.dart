import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  ServicesScreenState createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  //
  double? minFilterRange;
  double? maxFilterRange;
  ServiceFilterDataModel? filters;

  //
  String prevVal = '';

  Timer? _searchDelay;
  String previouseSearchQuery = '';

  //
  late TextEditingController searchController = TextEditingController()
    ..addListener(searchServiceListener);

  late final AnimationController _filterButtonOpacityAnimation =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  //
  ValueNotifier<bool> isScrolling = ValueNotifier(false);

  @override
  void initState() {
    context.read<FetchServicesCubit>().fetchServices(filter: filters);
    context.read<FetchServiceCategoryCubit>().fetchCategories();
    context.read<FetchTaxesCubit>().fetchTaxes();
    widget.scrollController.addListener(_pageScrollListener);
    super.initState();
  }

  void _pageScrollListener() {
    if (widget.scrollController.position.pixels > 7 && !isScrolling.value) {
      isScrolling.value = true;
    } else if (widget.scrollController.position.pixels < 7 &&
        isScrolling.value) {
      isScrolling.value = false;
    }
    if (widget.scrollController.isEndReached()) {
      if (context.read<FetchServicesCubit>().hasMoreServices()) {
        context.read<FetchServicesCubit>().fetchMoreServices(filter: filters);
      }
    }
  }

  void searchServiceListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

  void searchCallAfterDelay() {
    if (searchController.text != '') {
      _searchDelay = Timer(const Duration(milliseconds: 500), searchService);
    } else {
      context.read<FetchServicesCubit>().fetchServices();
    }
  }

  Future<void> searchService() async {
    if (searchController.text.isNotEmpty) {
      if (previouseSearchQuery != searchController.text) {
        context.read<FetchServicesCubit>().searchService(searchController.text);
        previouseSearchQuery = searchController.text;
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    isScrolling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        body: Stack(
          children: [
            mainWidget(),
            ValueListenableBuilder(
              valueListenable: isScrolling,
              builder: (BuildContext context, Object? value, Widget? child) {
                return Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryColor,
                    boxShadow: isScrolling.value
                        ? [
                            BoxShadow(
                              offset: const Offset(0, 0.75),
                              spreadRadius: 1,
                              blurRadius: 5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .blackColor
                                  .withOpacity(0.2),
                            )
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child:
                      Align(alignment: Alignment.topCenter, child: topWidget()),
                );
              },
            )
          ],
        ),
        floatingActionButton: const AddFloatingButton(
          routeNm: Routes.createService,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget topWidget() {
    return BlocConsumer<FetchServicesCubit, FetchServicesState>(
      listener: (BuildContext context, FetchServicesState state) {
        if (state is FetchServicesSuccess) {
          _filterButtonOpacityAnimation.forward();
        }
      },
      builder: (BuildContext context, FetchServicesState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              setSearchbar(),
              if (state is FetchServicesSuccess) ...{
                AnimatedBuilder(
                  animation: _filterButtonOpacityAnimation,
                  builder: (BuildContext context, Widget? c) {
                    return AnimatedOpacity(
                      duration: _filterButtonOpacityAnimation.duration!,
                      opacity: _filterButtonOpacityAnimation.value,
                      child: setFilterButton(
                        maxRange: state.maxFilterRange + 1,
                        minRange: state.minFilterRange,
                      ),
                    );
                  },
                )
              }
            ],
          ),
        );
      },
    );
  }

  Widget setSearchbar() {
    return CustomContainer(
      width: 250.rw(context),
      height: 35,
      cornerRadius: 10,
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      child: TextFormField(
        controller: searchController,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          fillColor: Theme.of(context).colorScheme.blackColor,
          hintText: 'searchServicesLbl'.translate(context: context),
          hintStyle:
              TextStyle(color: Theme.of(context).colorScheme.lightGreyColor),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.lightGreyColor,
          ),
        ),
        textAlignVertical: TextAlignVertical.center,
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  Widget setFilterButton({required double minRange, required double maxRange}) {
    return SizedBox(
      height: 35.rh(context),
      width: 83.rw(context),
      child: CustomIconButton(
        textDirection: TextDirection.rtl,
        imgName: 'filter',
        titleText: 'filterBtnLbl'.translate(context: context),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        iconColor: Theme.of(context).colorScheme.accentColor,
        titleColor: Theme.of(context).colorScheme.accentColor,
        bgColor: Theme.of(context).colorScheme.secondaryColor,
        onPressed: () async {
          final result = await showModalBottomSheet(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            context: context,
            builder: (BuildContext context) {
              return BlocProvider.value(
                value: BlocProvider.of<FetchServiceCategoryCubit>(context),
                child: Builder(
                  builder: (BuildContext context) {
                    return FilterByBottomSheet(
                      minRange: minRange,
                      maxRange: maxRange,
                      selectedMinRange: double.parse(
                        filters?.minBudget ?? minRange.toString(),
                      ),
                      selectedMaxRange: double.parse(
                        filters?.maxBudget ?? maxRange.toString(),
                      ),
                      selectedRating: filters?.rating,
                    );
                  },
                ),
              );
            },
          );

          if (result != null) {
            filters = result;

            setState(() {});
            Future.delayed(Duration.zero, () {
              context.read<FetchServicesCubit>().fetchServices(filter: result);
            });
          }
        },
      ),
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    bool? showRatingIcon,
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
        Row(
          children: [
            Visibility(
              visible: showRatingIcon ?? false,
              child: const Icon(
                Icons.star_outlined,
                color: AppColors.starRatingColor,
                size: 20,
              ),
            ),
            CustomText(
              titleText: subDetails,
              fontSize: 14,
              maxLines: 2,
              fontColor: Theme.of(context).colorScheme.blackColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget mainWidget() {
    return BlocListener<DeleteServiceCubit, DeleteServiceState>(
      listener: (BuildContext context, DeleteServiceState deleteServiceState) {
        if (deleteServiceState is DeleteServiceSuccess) {
          context
              .read<FetchServicesCubit>()
              .deleteServiceFromCubit(deleteServiceState.id);
          UiUtils.showMessage(
            context,
            'serviceDeleatedSuccess'.translate(context: context),
            MessageType.success,
          );
        }
        if (deleteServiceState is DeleteServiceFailure) {
          UiUtils.showMessage(
            context,
            deleteServiceState.errorMessage.translate(context: context),
            MessageType.error,
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<FetchServicesCubit>().fetchServices(filter: filters);
          context.read<FetchTaxesCubit>().fetchTaxes();
          context.read<FetchServiceCategoryCubit>().fetchCategories();
        },
        child: BlocBuilder<FetchServicesCubit, FetchServicesState>(
          builder: (BuildContext context, FetchServicesState state) {
            if (state is FetchServicesFailure) {
              return Center(
                child: ErrorContainer(
                  onTapRetry: () {
                    context
                        .read<FetchServicesCubit>()
                        .fetchServices(filter: filters);
                    context.read<FetchTaxesCubit>().fetchTaxes();
                  },
                  errorMessage: state.errorMessage.translate(context: context),
                ),
              );
            }
            if (state is FetchServicesSuccess) {
              if (state.services.isEmpty) {
                return Center(
                  child: NoDataContainer(
                    titleKey: 'noDataFound'.translate(context: context),
                  ),
                );
              }
              return SingleChildScrollView(
                clipBehavior: Clip.none,
                controller: widget.scrollController,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 75,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        bottom: 15,
                        left: 15,
                        right: 15,
                      ),
                      itemCount: state.services.length,
                      physics: const NeverScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemBuilder: (BuildContext context, int index) {
                        final ServiceModel service = state.services[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.serviceDetails,
                              arguments: {'serviceModel': service},
                            );
                          },
                          child: CustomContainer(
                            padding: const EdgeInsets.all(15),
                            margin:
                                const EdgeInsetsDirectional.only(bottom: 10),
                            bgColor:
                                Theme.of(context).colorScheme.secondaryColor,
                            cornerRadius: 10,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // getTitleAndSubDetails(
                                    //   title: 'priceLbl'.translate(context: context),
                                    //   subDetails: "${Constant.systemCurrency}${service.price ?? " "}",
                                    // ),
                                    // const SizedBox(
                                    //   width: 15,
                                    // ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            titleText:
                                                "Service Name : ${service.title!.capitalize()}",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontColor: Theme.of(context)
                                                .colorScheme
                                                .blackColor,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    getTitleAndSubDetails(
                                                      title: 'rating'.translate(
                                                        context: context,
                                                      ),
                                                      subDetails: service
                                                                  .rating!
                                                                  .length >
                                                              3
                                                          ? service.rating!
                                                              .substring(0, 3)
                                                          : service.rating!,
                                                      showRatingIcon: true,
                                                    ),
                                                    // const SizedBox(height: 10),
                                                    // getTitleAndSubDetails(
                                                    //   title: 'durationLbl'.translate(
                                                    //     context: context,
                                                    //   ),
                                                    //   subDetails: "${service.duration ?? '0'}  ${"minutes".translate(context: context)}",
                                                    // ),
                                                    // const SizedBox(height: 10),
                                                    // showButton(
                                                    //   imageName: 'edit',
                                                    //   titleName: 'editBtnLbl'.translate(
                                                    //     context: context,
                                                    //   ),
                                                    //   color: Theme.of(context).colorScheme.accentColor,
                                                    //   onPressed: () {
                                                    //     FocusScope.of(context).unfocus();
                                                    //     Navigator.pushNamed(
                                                    //       context,
                                                    //       Routes.createService,
                                                    //       arguments: {
                                                    //         'service': service,
                                                    //       },
                                                    //     );
                                                    //   },
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    getTitleAndSubDetails(
                                                      title:
                                                          'statusLbl'.translate(
                                                        context: context,
                                                      ),
                                                      subDetails:
                                                          (service.status ?? '')
                                                              .translate(
                                                                  context:
                                                                      context),
                                                    ),
                                                    // const SizedBox(height: 10),
                                                    // getTitleAndSubDetails(
                                                    //   title: 'personLabel'.translate(
                                                    //     context: context,
                                                    //   ),
                                                    //   subDetails: service.numberOfMembersRequired ?? '',
                                                    // ),
                                                    // const SizedBox(height: 10),
                                                    // showButton(
                                                    //   imageName: 'delete',
                                                    //   titleName: 'deleteBtnLbl'.translate(
                                                    //     context: context,
                                                    //   ),
                                                    //   onPressed: () {
                                                    //     clickOfDeleteButton(
                                                    //       serviceId: service.id!,
                                                    //     );
                                                    //   },
                                                    //   color: AppColors.redColor,
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              getTitleAndSubDetails(
                                                title: 'priceLbl'.translate(
                                                    context: context),
                                                subDetails:
                                                    "${Constant.systemCurrency}${service.price ?? " "}",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    showButton(
                                      imageName: 'edit',
                                      titleName: 'editBtnLbl'.translate(
                                        context: context,
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .accentColor,
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        Navigator.pushNamed(
                                          context,
                                          Routes.createService,
                                          arguments: {
                                            'service': service,
                                          },
                                        );
                                      },
                                    ),
                                    showButton(
                                      imageName: 'delete',
                                      titleName: 'deleteBtnLbl'.translate(
                                        context: context,
                                      ),
                                      onPressed: () {
                                        clickOfDeleteButton(
                                          serviceId: service.id!,
                                        );
                                      },
                                      color: AppColors.redColor,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        height: 10,
                      ),
                    ),
                    if (state.isLoadingMoreServices)
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.accentColor,
                      )
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
                children: [
                  const SizedBox(
                    height: 65,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsetsDirectional.all(16),
                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ShimmerLoadingContainer(
                          child: CustomShimmerContainer(
                            height: 120.rh(context),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget setImage({required String imageURL}) {
    return CustomContainer(
      cornerRadius: 10,
      bgColor: Colors.transparent,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: UiUtils.setNetworkImage(
            imageURL,
            ww: 75,
            hh: 105,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget showButton({
    required String imageName,
    required String titleName,
    void Function()? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: 84,
      height: 30,
      child: CustomIconButton(
        imgName: imageName,
        iconColor: color,
        titleText: titleName,
        fontSize: 12.0,
        borderRadius: 5,
        titleColor: color,
        borderColor: Colors.transparent,
        bgColor: color.withOpacity(0.3),
        onPressed: onPressed,
      ),
    );
  }

  void clickOfDeleteButton({required String serviceId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return CustomDialogs.showConfirmDialoge(
          progressColor: AppColors.whiteColors,
          context: context,
          showProgress: context.watch<DeleteServiceCubit>().state
              is DeleteServiceInProgress,
          confirmButtonColor: AppColors.redColor,
          confirmButtonName: 'delete'.translate(context: context),
          cancleButtonName: 'cancle'.translate(context: context),
          title: 'deleteService'.translate(context: context),
          description: 'deleteServiceDescription'.translate(context: context),
          onConfirmed: () {
            //
            if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable()) {
              UiUtils.showDemoModeWarning(context: context);
              return;
            }
            //
            //delete service from here
            context.read<DeleteServiceCubit>().deleteService(
              int.parse(serviceId),
              onDelete: () {
                Navigator.pop(context);
              },
            );
          },
          onCancled: () {},
        );
      },
    );
  }

  Widget setButtons(ServiceModel service) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          height: 30,
          child: CustomIconButton(
            imgName: 'edit',
            iconColor: Theme.of(context).colorScheme.accentColor,
            titleText: 'editBtnLbl'.translate(context: context),
            fontSize: 12.0,
            titleColor: Theme.of(context).colorScheme.accentColor,
            borderColor: Theme.of(context).colorScheme.lightGreyColor,
            bgColor: Colors.transparent,
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pushNamed(
                context,
                Routes.createService,
                arguments: {
                  'service': service,
                },
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 84,
          height: 30,
          child: CustomIconButton(
            imgName: 'delete',
            iconColor: Theme.of(context).colorScheme.accentColor,
            titleText: 'deleteBtnLbl'.translate(context: context),
            fontSize: 12.0,
            bgColor: Colors.transparent,
            titleColor: Theme.of(context).colorScheme.accentColor,
            borderColor: Theme.of(context).colorScheme.lightGreyColor,
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: Colors.black.withOpacity(0.4),
                builder: (BuildContext context) {
                  return CustomDialogs.showConfirmDialoge(
                    progressColor: AppColors.whiteColors,
                    context: context,
                    showProgress: context.watch<DeleteServiceCubit>().state
                        is DeleteServiceInProgress,
                    confirmButtonColor: AppColors.redColor,
                    confirmButtonName: 'delete'.translate(context: context),
                    cancleButtonName: 'cancle'.translate(context: context),
                    title: 'deleteService'.translate(context: context),
                    description:
                        'deleteServiceDescription'.translate(context: context),
                    onConfirmed: () {
                      //
                      if (context
                          .read<FetchSystemSettingsCubit>()
                          .isDemoModeEnable()) {
                        UiUtils.showDemoModeWarning(context: context);
                        return;
                      }
                      //
                      //delete service from here
                      context.read<DeleteServiceCubit>().deleteService(
                        int.parse(service.id!),
                        onDelete: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                    onCancled: () {},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
