import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CashCollectionScreen extends StatefulWidget {
  const CashCollectionScreen({super.key});

  @override
  CashCollectionScreenState createState() => CashCollectionScreenState();

  static Route<CashCollectionScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<CashCollectionCubit>(
            create: (BuildContext context) => CashCollectionCubit(),
          ),
          BlocProvider<AdminCollectCashCollectionHistoryCubit>(
            create: (BuildContext context) => AdminCollectCashCollectionHistoryCubit(),
          )
        ],
        child: const CashCollectionScreen(),
      ),
    );
  }
}

class CashCollectionScreenState extends State<CashCollectionScreen> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);

  String selectedFilter = 'cashCollectedByAdmin';
  ValueNotifier<bool> isScrolling = ValueNotifier(false);
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    isScrolling.dispose();
    overlayEntry?.remove();
    overlayEntry?.dispose();
    super.dispose();
  }

  void _pageScrollListen() {
    if (_pageScrollController.position.pixels > 7 && !isScrolling.value) {
      isScrolling.value = true;
    } else if (_pageScrollController.position.pixels < 7 && isScrolling.value) {
      isScrolling.value = false;
    }
    if (_pageScrollController.isEndReached()) {
      if (selectedFilter == 'cashCollectedByAdmin' &&
          context.read<AdminCollectCashCollectionHistoryCubit>().hasMoreData()) {
        context
            .read<AdminCollectCashCollectionHistoryCubit>()
            .fetchAdminCollectedMoreCashCollection();
      } else if (selectedFilter == 'cashReceived' &&
          context.read<CashCollectionCubit>().hasMoreData()) {
        context.read<CashCollectionCubit>().fetchMoreCashCollection();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        title: CustomText(
          titleText: 'cashCollection'.translate(context: context),
          fontColor: Theme.of(context).colorScheme.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: UiUtils.setBackArrow(context),
        actions: [
          IconButton(
            onPressed: () {
              UiUtils.showModelBottomSheets(
                context: context,
                enableDrag: true,
                isScrollControlled: false,
                child: FilterCashCollectionBottomSheet(
                  selectedItem: selectedFilter,
                ),
              ).then((value) {
                selectedFilter = value['selectedFilter'];
                setState(() {});

                //if data already loaded then we will emit the success state
                if (selectedFilter == 'cashCollectedByAdmin' &&
                    context.read<AdminCollectCashCollectionHistoryCubit>().state
                        is AdminCollectCashCollectionHistoryFetchSuccess) {
                  context.read<AdminCollectCashCollectionHistoryCubit>().emitSuccessState();
                  return;
                } else if (selectedFilter == 'cashReceived' &&
                    context.read<CashCollectionCubit>().state is CashCollectionFetchSuccess) {
                  context.read<CashCollectionCubit>().emitSuccessState();
                  return;
                }
                loadData();
              });
            },
            icon: Icon(Icons.filter_list_rounded, color: Theme.of(context).colorScheme.blackColor),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: IconButton(
              onPressed: () {
                if (overlayEntry?.mounted ?? false) {
                  return;
                }
                overlayEntry = OverlayEntry(
                  builder: (BuildContext context) => Positioned.directional(
                    textDirection: Directionality.of(context),
                    end: 10,
                    top: MediaQuery.sizeOf(context).height * .10,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * .9,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryColor,
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 0.5,
                            spreadRadius: 0.5,
                            color: Colors.black54,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'cashCollectionDescription'.translate(context: context),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                Overlay.of(context).insert(overlayEntry!);
                Timer(const Duration(seconds: 5), () => overlayEntry!.remove());
              },
              icon: Icon(
                Icons.help_outline_outlined,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          )
        ],
      ),
      body: mainWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget setTitleAndSubDetails({required String title, required String subTitle}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomText(
            titleText: title.translate(context: context),
            fontSize: 14,
            maxLines: 1,
            fontWeight: FontWeight.w400,
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
        ),
        const Expanded(child: SizedBox(width: 5)),
        Expanded(
          flex: 6,
          child: CustomText(
            titleText: subTitle,
            fontSize: 11,
            maxLines: 3,
            fontWeight: FontWeight.w400,
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
        ),
      ],
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
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
        CustomText(
          titleText: subDetails,
          fontSize: 14,
          maxLines: 2,
          fontColor: Theme.of(context).colorScheme.blackColor,
        ),
      ],
    );
  }

  Widget showCashCollectionList({
    required List<CashCollectionModel> cashCollectionData,
    required String payableCommissionAmount,
    required bool isLoadingMore,
  }) {
    return Stack(
      children: [
        if (cashCollectionData.isEmpty) ...[
          Center(child: NoDataContainer(titleKey: 'noDataFound'.translate(context: context)))
        ],
        if (cashCollectionData.isNotEmpty) ...[
          SingleChildScrollView(
            controller: _pageScrollController,
            clipBehavior: Clip.none,
            child: Column(
              children: [
                const SizedBox(
                  height: 110,
                ),
                ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemCount: cashCollectionData.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return CustomContainer(
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsetsDirectional.all(10),
                      bgColor: Theme.of(context).colorScheme.secondaryColor,
                      cornerRadius: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (cashCollectionData[index].orderID != '') ...[
                                CustomText(
                                  titleText: 'orderID'.translate(context: context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontColor: Theme.of(context).colorScheme.lightGreyColor,
                                ),
                                const SizedBox(width: 2),
                                CustomText(
                                  titleText: cashCollectionData[index].orderID!,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontColor: Theme.of(context).colorScheme.blackColor,
                                ),
                              ],
                              const Spacer(),
                              Container(
                                height: 25,
                                width: MediaQuery.sizeOf(context).width * 0.3,
                                decoration: BoxDecoration(
                                  color: cashCollectionData[index].status == 'paid'
                                      ? AppColors.starRatingColor.withOpacity(0.2)
                                      : AppColors.greenColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: CustomText(
                                    titleText: cashCollectionData[index]
                                        .status!
                                        .translate(context: context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontColor: cashCollectionData[index].status == 'paid'
                                        ? AppColors.starRatingColor
                                        : AppColors.greenColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: getTitleAndSubDetails(
                                  title: 'amount',
                                  subDetails:
                                      "${Constant.systemCurrency}${cashCollectionData[index].commissionAmount ?? "0"}",
                                ),
                              ),
                              Expanded(
                                child: getTitleAndSubDetails(
                                  title: 'date',
                                  subDetails: (cashCollectionData[index].date ?? "").formatDate(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          getTitleAndSubDetails(
                            title: 'message',
                            subDetails: '${cashCollectionData[index].message}',
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(
                    height: 10,
                  ),
                ),
                if (isLoadingMore) ...[
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.accentColor,
                  )
                ]
              ],
            ),
          ),
        ],
        Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder(
            valueListenable: isScrolling,
            builder: (BuildContext context, Object? value, Widget? child) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryColor,
                boxShadow: isScrolling.value
                    ? [
                        BoxShadow(
                          offset: const Offset(0, 0.75),
                          spreadRadius: 1,
                          blurRadius: 5,
                          color: Theme.of(context).colorScheme.blackColor.withOpacity(0.2),
                        )
                      ]
                    : [],
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                height: 95,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'amountPayable'.translate(context: context),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.whiteColors,
                      ),
                    ),
                    Text(
                      UiUtils.getPriceFormat(
                        context,
                        double.parse(
                          (payableCommissionAmount == 'null' ? '0.0' : payableCommissionAmount)
                              .replaceAll(',', ''),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.whiteColors,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void loadData() {
    if (selectedFilter == 'cashCollectedByAdmin') {
      context.read<AdminCollectCashCollectionHistoryCubit>().fetchAdminCollectedCashCollection();
    } else if (selectedFilter == 'cashReceived') {
      context.read<CashCollectionCubit>().fetchCashCollection();
    }
  }

  Widget showLoadingShimmerEffect() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: 8,
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: MediaQuery.sizeOf(context).height * 0.18,
            ),
          ),
        );
      },
    );
  }

  Widget mainWidget() {
    return RefreshIndicator(
      onRefresh: () async {
        loadData();
      },
      child: (selectedFilter == 'cashCollectedByAdmin')
          ? BlocBuilder<AdminCollectCashCollectionHistoryCubit,
              AdminCollectCashCollectionHistoryState>(
              builder: (BuildContext context, AdminCollectCashCollectionHistoryState state) {
                if (state is AdminCollectCashCollectionHistoryStateFailure) {
                  return Center(
                    child: ErrorContainer(
                      onTapRetry: () {
                        context
                            .read<AdminCollectCashCollectionHistoryCubit>()
                            .fetchAdminCollectedCashCollection();
                      },
                      errorMessage: state.errorMessage,
                    ),
                  );
                }
                if (state is AdminCollectCashCollectionHistoryFetchSuccess) {
                  return showCashCollectionList(
                    cashCollectionData: state.cashCollectionData,
                    payableCommissionAmount: state.totalPayableCommission,
                    isLoadingMore: state.isLoadingMore,
                  );
                }
                return showLoadingShimmerEffect();
              },
            )
          : BlocBuilder<CashCollectionCubit, CashCollectionState>(
              builder: (BuildContext context, CashCollectionState state) {
                if (state is CashCollectionFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      onTapRetry: () {
                        context.read<CashCollectionCubit>().fetchCashCollection();
                      },
                      errorMessage: state.errorMessage,
                    ),
                  );
                }
                if (state is CashCollectionFetchSuccess) {
                  return showCashCollectionList(
                    payableCommissionAmount: state.totalPayableCommission,
                    cashCollectionData: state.cashCollectionData,
                    isLoadingMore: state.isLoadingMore,
                  );
                }
                return showLoadingShimmerEffect();
              },
            ),
    );
  }
}

class FilterCashCollectionBottomSheet extends StatefulWidget {
  const FilterCashCollectionBottomSheet({super.key, required this.selectedItem});

  final String selectedItem;

  @override
  State<FilterCashCollectionBottomSheet> createState() => _FilterCashCollectionBottomSheetState();
}

class _FilterCashCollectionBottomSheetState extends State<FilterCashCollectionBottomSheet> {
  late String filterBy = widget.selectedItem;

  Widget getFilterOption({
    required String filterOptionName,
  }) {
    return InkWell(
      onTap: () {
        filterBy = filterOptionName;
        setState(() {});
        Navigator.pop(context, {'selectedFilter': filterBy});
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filterOptionName.translate(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.blackColor,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.start,
            ),
            const Spacer(),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: filterBy == filterOptionName
                    ? Theme.of(context).colorScheme.blackColor
                    : Colors.transparent,
                border: Border.all(width: 0.5, color: Theme.of(context).colorScheme.lightGreyColor),
                shape: BoxShape.circle,
              ),
              child: filterBy == filterOptionName
                  ? Icon(
                      size: 18,
                      Icons.done_rounded,
                      color: Theme.of(context).colorScheme.secondaryColor,
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
          topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: MediaQuery.sizeOf(context).width,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
                topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
              ),
            ),
            child: Center(
              child: CustomText(
                titleText: 'filterBtnLbl'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontColor: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          ),
          getFilterOption(filterOptionName: 'cashCollectedByAdmin'),
          const Divider(),
          getFilterOption(filterOptionName: 'cashReceived'),
        ],
      ),
    );
  }
}
