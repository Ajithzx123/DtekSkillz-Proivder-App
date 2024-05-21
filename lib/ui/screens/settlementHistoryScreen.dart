import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class SettlementHistoryScreen extends StatefulWidget {
  const SettlementHistoryScreen({super.key});

  @override
  SettlementHistoryScreenState createState() => SettlementHistoryScreenState();

  static Route<SettlementHistoryScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => FetchSettlementHistoryCubit(),
        child: const SettlementHistoryScreen(),
      ),
    );
  }
}

class SettlementHistoryScreenState extends State<SettlementHistoryScreen> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);

  ValueNotifier<bool> isScrolling = ValueNotifier(false);
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    context.read<FetchSettlementHistoryCubit>().fetchSettlementHistory();
    super.initState();
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
      if (context.read<FetchSettlementHistoryCubit>().hasMoreData()) {
        context.read<FetchSettlementHistoryCubit>().fetchMoreSettlementHistory();
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
          titleText: 'settlementHistory'.translate(context: context),
          fontColor: Theme.of(context).colorScheme.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: UiUtils.setBackArrow(context),
        actions: [
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
                          'settlementDescription'.translate(context: context),
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
                Timer(const Duration(seconds: 5), () => overlayEntry?.remove());
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

  Widget getTitleAndDetails({required String title, required String subDetails}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          titleText: title.translate(context: context),
          fontSize: 14,
          fontColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
        const SizedBox(width: 2),
        CustomText(
          titleText: subDetails,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontColor: Theme.of(context).colorScheme.blackColor,
        ),
      ],
    );
  }

  Widget showSettlementHistoryList({
    required List<SettlementModel> settlementData,
    required bool isLoadingMore,
  }) {
    return Column(
      children: [
        if (settlementData.isEmpty) ...[
          Center(child: NoDataContainer(titleKey: 'noDataFound'.translate(context: context)))
        ],
        if (settlementData.isNotEmpty) ...[
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
                  itemCount: settlementData.length,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getTitleAndDetails(
                                title: 'amount',
                                subDetails:
                                    "${Constant.systemCurrency}${settlementData[index].amount ?? "0"}",
                              ),
                              getTitleAndDetails(
                                title: 'date',
                                subDetails: settlementData[index].date!.formatDate(),
                              ),
                              Container(
                                height: 25,
                                width: 75,
                                decoration: BoxDecoration(
                                  color: AppColors.greenColor.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: CustomText(
                                    titleText: settlementData[index].status!.capitalize(),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontColor: Theme.of(context).colorScheme.blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          getTitleAndDetails(
                            title: 'message',
                            subDetails: '${settlementData[index].message}',
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
      ],
    );
  }

  Widget mainWidget() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FetchSettlementHistoryCubit>().fetchSettlementHistory();
      },
      child: BlocBuilder<FetchSettlementHistoryCubit, FetchSettlementHistoryState>(
        builder: (BuildContext context, FetchSettlementHistoryState state) {
          if (state is FetchSettlementHistoryFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<FetchSettlementHistoryCubit>().fetchSettlementHistory();
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          if (state is FetchSettlementHistorySuccess) {
            return Stack(
              children: [
                if (state.settlementDetails.isEmpty) ...[
                  Center(
                    child: NoDataContainer(
                      titleKey: 'settlementHistoryNotFound'.translate(context: context),
                    ),
                  )
                ],
                if (state.settlementDetails.isNotEmpty) ...[
                  showSettlementHistoryList(
                    settlementData: state.settlementDetails,
                    isLoadingMore: state.isLoadingMore,
                  )
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
                              'amountReceivable'.translate(context: context),
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
                                  (context.watch<FetchSystemSettingsCubit>().state
                                          as FetchSystemSettingsSuccess)
                                      .availableAmount
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
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            itemCount: 8,
            physics: const NeverScrollableScrollPhysics(),
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
        },
      ),
    );
  }
}
