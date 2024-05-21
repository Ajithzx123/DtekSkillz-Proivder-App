import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> with AutomaticKeepAliveClientMixin {
  int currFilter = 0;
  String? selectedStatus;

  List<Map> filters = []; //set  model  from  API  Response

  @override
  void didChangeDependencies() {
    filters = [
      {'id': '0', 'fName': 'all'.translate(context: context)},
      {'id': '1', 'fName': 'awaiting'.translate(context: context)},
      {'id': '2', 'fName': 'confirmed'.translate(context: context)},
      {'id': '3', 'fName': 'started'.translate(context: context)},
      {'id': '4', 'fName': 'rescheduled'.translate(context: context)},
      {'id': '5', 'fName': 'completed'.translate(context: context)},
      {'id': '6', 'fName': 'cancelled'.translate(context: context)},
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    filters = [
      {'id': '0', 'fName': 'all'.translate(context: context)},
      {'id': '1', 'fName': 'awaiting'.translate(context: context)},
      {'id': '2', 'fName': 'confirmed'.translate(context: context)},
      {'id': '3', 'fName': 'started'.translate(context: context)},
      {'id': '4', 'fName': 'rescheduled'.translate(context: context)},
      {'id': '5', 'fName': 'completed'.translate(context: context)},
      {'id': '6', 'fName': 'cancelled'.translate(context: context)},
    ];
    return DefaultTabController(
      length: filters.length,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          body: Column(
            children: [
              SizedBox(
                height: 55,
                child: _buildTabBar(context),
              ),
              Expanded(
                child: BookingsTabContent(
                  status: selectedStatus,
                  scrollController: widget.scrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: filters.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            if (currFilter == index) {
              return;
            }
            currFilter = index;
            setState(() {});

            switch (currFilter) {
              case 0:
                selectedStatus = null;
                break;
              case 1:
                selectedStatus = 'awaiting';
                break;
              case 2:
                selectedStatus = 'confirmed';
                break;
              case 3:
                selectedStatus = 'started';
                break;
              case 4:
                selectedStatus = 'rescheduled';
                break;
              case 5:
                selectedStatus = 'completed';
                break;
              case 6:
                selectedStatus = 'cancelled';
                break;
            }
            context.read<FetchBookingsCubit>().fetchBookings(selectedStatus);
          },
          child: Container(
            decoration: BoxDecoration(
              color: currFilter == index
                  ? Theme.of(context).colorScheme.accentColor
                  : Theme.of(context).colorScheme.secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            constraints: const BoxConstraints(minWidth: 90),
            height: 50,
            child: Center(
              child: Text(
                filters[index]['fName'],
                style: TextStyle(
                  color: currFilter == index
                      ? AppColors.whiteColors
                      : Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BookingsTabContent extends StatefulWidget {
  const BookingsTabContent({super.key, this.status, required this.scrollController});

  final String? status;
  final ScrollController scrollController;

  @override
  State<BookingsTabContent> createState() => _BookingsTabContentState();
}

class _BookingsTabContentState extends State<BookingsTabContent> {
  void pageScrollListen() {
    if (widget.scrollController.isEndReached()) {
      if (context.read<FetchBookingsCubit>().hasMoreData()) {
        context.read<FetchBookingsCubit>().fetchMoreBookings(widget.status);
      }
    }
  }

  @override
  void initState() {
    context.read<FetchBookingsCubit>().fetchBookings(widget.status);
    widget.scrollController.addListener(pageScrollListen);
    super.initState();
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    bool? isSubtitleBold,
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
          fontWeight: isSubtitleBold ?? false ? FontWeight.bold : FontWeight.normal,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FetchBookingsCubit>().fetchBookings(widget.status);
      },
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          child: BlocBuilder<FetchBookingsCubit, FetchBookingsState>(
            builder: (BuildContext context, FetchBookingsState state) {
              if (state is FetchBookingsInProgress) {
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsetsDirectional.all(16),
                  itemCount: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.0),
                      child: ShimmerLoadingContainer(
                        child: CustomShimmerContainer(
                          height: 170,
                        ),
                      ),
                    );
                  },
                );
              }

              if (state is FetchBookingsFailure) {
                return Center(
                  child: ErrorContainer(
                    onTapRetry: () {
                      context.read<FetchBookingsCubit>().fetchBookings(widget.status);
                    },
                    errorMessage: state.errorMessage.translate(context: context),
                  ),
                );
              }
              if (state is FetchBookingsSuccess) {
                if (state.bookings.isEmpty) {
                  return NoDataContainer(titleKey: 'noDataFound'.translate(context: context));
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      itemCount: state.bookings.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        final BookingsModel bookingModel = state.bookings[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.bookingDetails,
                              arguments: {'bookingsModel': bookingModel},
                            );
                          },
                          child: CustomContainer(
                            padding: const EdgeInsetsDirectional.all(15),
                            margin: const EdgeInsetsDirectional.only(bottom: 10),
                            cornerRadius: 18,
                            bgColor: Theme.of(context).colorScheme.secondaryColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: UiUtils.setNetworkImage(
                                          bookingModel.profileImage ?? '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: SizedBox(
                                        height: 70,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CustomText(
                                                  titleText: bookingModel.customer ?? '',
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  fontColor:
                                                      Theme.of(context).colorScheme.blackColor,
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment: AlignmentDirectional.centerEnd,
                                                    child: CustomText(
                                                      titleText:
                                                          "${Constant.systemCurrency}${bookingModel.finalTotal ?? " "}",
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w700,
                                                      fontColor:
                                                          Theme.of(context).colorScheme.blackColor,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            getTitleAndSubDetails(
                                              title: 'invoiceNumber',
                                              subDetails: bookingModel.invoiceNo ?? '',
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    getTitleAndSubDetails(
                                      title: 'mobileNumber',
                                      subDetails: bookingModel.customerNo ?? '',
                                    ),
                                    const Spacer(),
                                    getTitleAndSubDetails(
                                      title: 'dateAndTime',
                                      subDetails:
                                          "${bookingModel.dateOfService.toString().formatDate()}, ${(bookingModel.startingTime ?? "").toString().formatTime()}",
                                    ),
                                  ],
                                ),
                                if (bookingModel.addressId != "0") ...[
                                  const SizedBox(height: 10),
                                  getTitleAndSubDetails(
                                    title: 'addressLbl',
                                    subDetails: bookingModel.address.toString().removeExtraComma(),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                getTitleAndSubDetails(
                                  title: 'statusLbl',
                                  subDetails: bookingModel.status
                                      .toString()
                                      .translate(context: context)
                                      .capitalize(),
                                  isSubtitleBold: true,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => SizedBox(
                        height: 10.rh(context),
                      ),
                    ),
                    if (state.isLoadingMoreBookings)
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.accentColor,
                      )
                  ],
                );
                //,);//Flexible
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }
}
