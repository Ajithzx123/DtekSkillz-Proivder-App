// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';
import '../../../utils/checkURLType.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key, required this.bookingsModel});

  final BookingsModel bookingsModel;

  @override
  BookingDetailsState createState() => BookingDetailsState();

  static Route<BookingDetails> route(RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => BookingDetails(
        bookingsModel: arguments['bookingsModel'],
      ),
    );
  }
}

class BookingDetailsState extends State<BookingDetails> {
  ScrollController? scrollController = ScrollController();
  Map<String, String>? currentStatusOfBooking;
  Map<String, String>? temporarySelectedStatusOfBooking;
  int totalServiceQuantity = 0;

  DateTime? selectedRescheduleDate;
  String? selectedRescheduleTime;
  List<Map<String, String>> filters = [];
  List<Map<String, dynamic>>? selectedProofFiles;

  @override
  void initState() {
    scrollController!.addListener(() => setState(() {}));
    _getTotalQuantity();
    Future.delayed(Duration.zero, () {
      filters = [
        {
          'value': '1',
          'title': 'awaiting'.translate(context: context),
        },
        {
          'value': '2',
          'title': 'confirmed'.translate(context: context),
        },
        {
          'value': '3',
          'title': 'started'.translate(context: context),
        },
        {'value': '4', 'title': 'rescheduled'.translate(context: context)},
        {
          'value': '5',
          'title': 'completed'.translate(context: context),
        },
        {
          'value': '6',
          'title': 'cancelled'.translate(context: context),
        },
      ];
    });
    _getTranslatedInitialStatus();
    super.initState();
  }

  void _getTotalQuantity() {
    widget.bookingsModel.services?.forEach(
      (Services service) {
        totalServiceQuantity += int.parse(service.quantity!);
      },
    );
    setState(
      () {},
    );
  }

  void _getTranslatedInitialStatus() {
    Future.delayed(Duration.zero, () {
      final String? initialStatusValue = getStatusForApi
          .where((Map<String, String> e) => e['title'] == widget.bookingsModel.status)
          .toList()[0]['value'];
      currentStatusOfBooking = filters.where((Map<String, String> element) {
        return element['value'] == initialStatusValue;
      }).toList()[0];

      setState(() {});
    });
  }

// Don't translate this because we need to send this title in api;
  List<Map<String, String>> getStatusForApi = [
    {'value': '1', 'title': 'awaiting'},
    {'value': '2', 'title': 'confirmed'},
    {'value': '3', 'title': 'started'},
    {'value': '4', 'title': 'rescheduled'},
    {'value': '5', 'title': 'completed'},
    {'value': '6', 'title': 'cancelled'},
  ];

  Future<void> _onDropDownClick(filters) async {
    //get current status of booking
    if (widget.bookingsModel.status != null && temporarySelectedStatusOfBooking == null) {
      currentStatusOfBooking = getStatusForApi
          .where((Map<String, String> e) => e['title'] == widget.bookingsModel.status)
          .toList()[0];
    } else {
      currentStatusOfBooking = temporarySelectedStatusOfBooking;
    }

    //show bottomSheet to select new status
    var selectedStatusOfBooking = await UiUtils.showModelBottomSheets(
      context: context,
      child: UpdateStatusBottomSheet(
        selectedItem: currentStatusOfBooking!,
        itemValues: [...filters],
      ),
    );
    print("satus us $selectedStatusOfBooking");
    if (selectedStatusOfBooking?['selectedStatus'] != null) {
      //
      //if selectedStatus is started then show uploadFiles bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'started'.translate(context: context)) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) =>
              UploadProofBottomSheet(preSelectedFiles: selectedProofFiles),
        ).then((value) {
          selectedProofFiles = value;
          setState(() {});
        });
      }
      //
      //if selectedStatus is completed then show uploadFiles bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'completed'.translate(context: context)) {
        //
        await showModalBottomSheet(
          context: context,
          builder: (BuildContext context) =>
              UploadProofBottomSheet(preSelectedFiles: selectedProofFiles),
        ).then((value) {
          selectedProofFiles = value;
          setState(() {});
        });
        //
        //if OTP validation is required then show OTP dialog
        if (currentStatusOfBooking?['title'] != 'completed'.translate(context: context) &&
            context.read<FetchSystemSettingsCubit>().isOrderOTPVerificationEnable()) {
          await getOTPDialog(
            otp: widget.bookingsModel.otp ?? '0',
            onOTPConfirmed: () {
              Navigator.pop(context);
              temporarySelectedStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
              currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
            },
          );
        } else {
          temporarySelectedStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
          currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
        }
      } else {
        temporarySelectedStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
        currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
      }

      //
      //if selectedStatus is reschedule then show select new date and time bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'rescheduled'.translate(context: context)) {
        final Map? result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          enableDrag: true,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.sizeOf(context).height * 0.7,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child:
                  CalenderBottomSheet(advanceBookingDays: widget.bookingsModel.advanceBookingDays!),
            );
          },
        );

        selectedRescheduleDate = result?['selectedDate'];
        selectedRescheduleTime = result?['selectedTime'];

        if (selectedRescheduleDate == null || selectedRescheduleTime == null) {
          selectedStatusOfBooking = getStatusForApi[0];
          temporarySelectedStatusOfBooking = getStatusForApi[0];
          currentStatusOfBooking = getStatusForApi[0];
          setState(() {});
        }
      } else {
        //reset the values if choose different one
        selectedRescheduleDate = null;
        selectedRescheduleTime = null;
      }
    }
    setState(() {});
  }

  // ignore: always_declare_return_types
  getOTPDialog({required String otp, required VoidCallback onOTPConfirmed}) {
    final TextEditingController otpController = TextEditingController();
    final GlobalKey<FormState> otpFormKey = GlobalKey();
    //

    final AlertDialog data = CustomDialogs.showTextFieldDialoge(
      context,
      formKey: otpFormKey,
      controller: otpController,
      textInputType: TextInputType.number,
      title: 'otp'.translate(context: context),
      hintText: 'enterOTP'.translate(context: context),
      message: 'pleaseEnterOTPGivenByCustomer'.translate(context: context),
      showProgress: false,
      confirmButtonColor: Theme.of(context).colorScheme.accentColor,
      validator: (String value) {
        if (value.trim().isEmpty) {
          return 'pleaseEnterOTP';
        }
        if (value.trim() != otp || value.trim() == '0') {
          return 'invalidOTP';
        }
      },
      onCancled: () {
        Navigator.pop(context);
      },
      onConfirmed: onOTPConfirmed,
    );
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return data;
      },
    ).then((value) => null);
  }

  @override
  void didChangeDependencies() {
    //  _getTranslatedInitialStatus();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return context.read<UpdateBookingStatusCubit>().state is! UpdateBookingStatusInProgress;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          elevation: 1,
          centerTitle: true,
          leading: UiUtils.setBackArrow(
            context,
            canGoBack:
                context.watch<UpdateBookingStatusCubit>().state is! UpdateBookingStatusInProgress,
          ),
          title: Text(
            'bookingDetails'.translate(context: context),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.blackColor,
            ),
          ),
        ),

        body: mainWidget(), //mainWidget(),

        bottomNavigationBar: bottomBarWidget(),
      ),
    );
  }

  Widget onMapsBtn() {
    return InkWell(
      onTap: () async {
        try {
          await launchUrl(
            Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${widget.bookingsModel.latitude},${widget.bookingsModel.longitude}',
            ),
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          UiUtils.showMessage(
            context,
            'somethingWentWrong'.translate(context: context),
            MessageType.error,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.accentColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          'onMapsLbl'.translate(context: context),
          style: TextStyle(color: Theme.of(context).colorScheme.accentColor),
        ),
      ),
    );
  }

  Widget bottomBarWidget() {
    return BlocConsumer<UpdateBookingStatusCubit, UpdateBookingStatusState>(
      listener: (BuildContext context, UpdateBookingStatusState state) {
        if (state is UpdateBookingStatusFailure) {
          UiUtils.showMessage(
              context, state.errorMessage.translate(context: context), MessageType.error);
        }
        if (state is UpdateBookingStatusSuccess) {
          if (state.error == 'true') {
            //empty selected images for proof

            //
            UiUtils.showMessage(
              context,
              state.message.translate(context: context),
              MessageType.error,
            );
            setState(() {
              selectedProofFiles = [];
            });
            return;
          }
          //
          context.read<FetchBookingsCubit>().updateBookingDetailsLocally(
                bookingID: state.orderId.toString(),
                bookingStatus: state.status,
                listOfUploadedImages: state.imagesList,
              );

          UiUtils.showMessage(
            context,
            'updatedSuccessfully'.translate(context: context),
            MessageType.success,
          );
        }
      },
      builder: (BuildContext context, UpdateBookingStatusState state) {
        Widget? child;
        if (state is UpdateBookingStatusInProgress) {
          child = CircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        }
        return Container(
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              height: (selectedRescheduleDate == null || selectedRescheduleTime == null) ? 50 : 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedRescheduleDate != null && selectedRescheduleTime != null) ...[
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'selectedDate'.translate(context: context),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(selectedRescheduleDate.toString().split(' ')[0])
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'selectedTime'.translate(context: context),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(selectedRescheduleTime ?? '')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: CustomFormDropdown(
                            initialTitle:
                                currentStatusOfBooking?['title'].toString().firstUpperCase() ??
                                    widget.bookingsModel.status.toString().firstUpperCase(),
                            selectedValue: currentStatusOfBooking?['title'],
                            onTap: () {
                              _onDropDownClick(filters);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 3,
                          child: CustomRoundedButton(
                            showBorder: false,
                            buttonTitle: 'update'.translate(context: context),
                            backgroundColor: Theme.of(context).colorScheme.accentColor,
                            widthPercentage: 1,
                            height: 50.rh(context),
                            textSize: 14,
                            child: child,
                            onTap: () {
                              if (state is UpdateBookingStatusInProgress) {
                                return;
                              }
                              Map<String, String>? bookingStatus;
                              //
                              final List<Map<String, String>> selectedBookingStatus =
                                  getStatusForApi.where(
                                (Map<String, String> element) {
                                  return element['value'] == currentStatusOfBooking?['value'];
                                },
                              ).toList();

                              if (selectedBookingStatus.isNotEmpty) {
                                bookingStatus = selectedBookingStatus[0];
                              }

                              context.read<UpdateBookingStatusCubit>().updateBookingStatus(
                                    orderId: int.parse(widget.bookingsModel.id!),
                                    customerId: int.parse(widget.bookingsModel.customerId!),
                                    status: bookingStatus?['title'] ?? widget.bookingsModel.status!,
                                    //OTP validation applied locally, so status is completed then OTP verified already, so directly passing the OTP
                                    otp: widget.bookingsModel.otp ?? '',
                                    date: selectedRescheduleDate.toString().split(' ')[0],
                                    time: selectedRescheduleTime,
                                    proofData: selectedProofFiles,
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget mainWidget() {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customerInfoWidget(),
          bookingDateAndTimeWidget(),
          Visibility(
            visible: widget.bookingsModel.workStartedProof!.isNotEmpty,
            child: uploadedProofWidget(
              title: 'workStartedProof',
              proofData: widget.bookingsModel.workStartedProof!,
            ),
          ),
          Visibility(
            visible: widget.bookingsModel.workCompletedProof!.isNotEmpty,
            child: uploadedProofWidget(
              title: 'workCompletedProof',
              proofData: widget.bookingsModel.workCompletedProof!,
            ),
          ),
          bookingDetailsWidget(),
          notesWidget(),
          serviceDetailsWidget(),
          pricingWidget()
        ],
      ),
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    Color? subTitleBackgroundColor,
    Color? subTitleColor,
    double? width,
    Function()? onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != '') ...[
            CustomText(
              titleText: title.translate(context: context),
              fontSize: 14,
              maxLines: 2,
              fontColor: Theme.of(context).colorScheme.lightGreyColor,
            ),
            const SizedBox(
              height: 5,
            ),
          ],
          Container(
            width: width,
            decoration: BoxDecoration(
              color: subTitleBackgroundColor?.withOpacity(0.2) ?? Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: CustomText(
              titleText: subDetails,
              fontSize: 14,
              maxLines: 2,
              fontColor: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
            ),
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
            color: subTitleBackgroundColor?.withOpacity(0.2) ?? Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(5),
          child: CustomText(
            titleText: subDetails,
            fontSize: 14,
            maxLines: 2,
            fontColor: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
          ),
        ),
      ],
    );
  }

  Widget showDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).colorScheme.lightGreyColor,
    );
  }

  Widget getTitle({
    required String title,
    String? subTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          titleText: title.translate(context: context),
          maxLines: 1,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontColor: Theme.of(context).colorScheme.blackColor,
        ),
        if (subTitle != null) ...[
          const SizedBox(
            height: 5,
          ),
          CustomText(
            titleText: subTitle.translate(context: context),
            maxLines: 1,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontColor: Theme.of(context).colorScheme.lightGreyColor,
          )
        ]
      ],
    );
  }

  Widget customerInfoWidget() {
    return CustomContainer(
      cornerRadius: 0,
      //padding: const EdgeInsets.only(top: 15),
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: getTitle(title: 'customerDetails'),
          ),
          showDivider(),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: UiUtils.setNetworkImage(
                              widget.bookingsModel.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                titleText: widget.bookingsModel.customer ?? '',
                                fontWeight: FontWeight.w500,
                                fontColor: Theme.of(context).colorScheme.blackColor,
                              ),
                              const SizedBox(height: 10),
                              if (widget.bookingsModel.addressId != "0") ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: getTitleAndSubDetails(
                                        title: 'addressLbl',
                                        subDetails: widget.bookingsModel.address ?? '',
                                        onTap: () {
                                          if (Constant.showOnMapsButton) {
                                            return;
                                          }
                                          try {
                                            launchUrl(
                                                Uri.parse(
                                                    'https://www.google.com/maps/search/?api=1&query=${widget.bookingsModel.latitude},${widget.bookingsModel.longitude}'),
                                                mode: LaunchMode.externalApplication);
                                          } catch (e) {
                                            UiUtils.showMessage(
                                                context,
                                                "somethingWentWrong".translate(context: context),
                                                MessageType.error);
                                          }
                                        },
                                      ),
                                    ),
                                    if (Constant.showOnMapsButton) onMapsBtn()
                                  ],
                                ),
                              ] else ...[
                                getTitleAndSubDetails(
                                  title: 'serviceBookedAt'.translate(context: context),
                                  subDetails: widget.bookingsModel.addressId == "0"
                                      ? 'atStore'.translate(context: context)
                                      : "atDoorstep".translate(context: context),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: getTitleAndSubDetails(
                            title: 'mobileNumber'.translate(context: context),
                            subDetails: widget.bookingsModel.customerNo ?? '',
                            onTap: () {
                              try {
                                launchUrl(Uri.parse("tel:${widget.bookingsModel.customerNo}"));
                              } catch (e) {
                                UiUtils.showMessage(
                                    context,
                                    "somethingWentWrong".translate(context: context),
                                    MessageType.error);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: getTitleAndSubDetails(
                            title: 'email'.translate(context: context),
                            subDetails: widget.bookingsModel.customerEmail ?? '',
                            onTap: () {
                              try {
                                launchUrl(
                                    Uri.parse("mailto:${widget.bookingsModel.customerEmail}"));
                              } catch (e) {
                                UiUtils.showMessage(
                                    context,
                                    "somethingWentWrong".translate(context: context),
                                    MessageType.error);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              showDivider(),
            ],
          ),
        ],
      ),
    );
  }

  Widget bookingDateAndTimeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: getTitle(
                  title: 'bookingDateAndTime',
                  subTitle: widget.bookingsModel.multipleDaysBooking!.isNotEmpty
                      ? 'bookingScheduledForMultipleDays'
                      : null,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: getTitleAndSubDetails(
                      title: 'serviceDate'.translate(context: context),
                      subDetails: (widget.bookingsModel.dateOfService ?? '').formatDate(),
                    ),
                  ),
                  Expanded(
                    child: getTitleAndSubDetails(
                      title: 'starting'.translate(context: context),
                      subDetails: (widget.bookingsModel.startingTime ?? '').formatTime(),
                    ),
                  ),
                  Expanded(
                    child: getTitleAndSubDetails(
                      title: 'ending'.translate(context: context),
                      subDetails: (widget.bookingsModel.endingTime ?? '').formatTime(),
                    ),
                  ),
                ],
              ),
              if (widget.bookingsModel.multipleDaysBooking!.isNotEmpty) ...[
                for (int i = 0; i < widget.bookingsModel.multipleDaysBooking!.length; i++) ...{
                  Row(
                    children: [
                      Expanded(
                        child: getTitleAndSubDetails(
                          title: '',
                          subDetails: (widget.bookingsModel.multipleDaysBooking![i]
                                      .multipleDayDateOfService ??
                                  '')
                              .formatDate(),
                        ),
                      ),
                      Expanded(
                        child: getTitleAndSubDetails(
                          title: '',
                          subDetails: (widget.bookingsModel.multipleDaysBooking![i]
                                      .multipleDayStartingTime ??
                                  '')
                              .formatTime(),
                        ),
                      ),
                      Expanded(
                        child: getTitleAndSubDetails(
                          title: '',
                          subDetails:
                              (widget.bookingsModel.multipleDaysBooking![i].multipleEndingTime ??
                                      '')
                                  .formatTime(),
                        ),
                      ),
                    ],
                  ),
                }
              ]
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        showDivider(),
      ],
    );
  }

  Widget uploadedProofWidget({required String title, required List<dynamic> proofData}) {
    return CustomContainer(
      cornerRadius: 15,
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTitle(title: title.translate(context: context)),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: List.generate(proofData.length, (int index) {
                    return Container(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsetsDirectional.only(end: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.imagePreviewScreen,
                            arguments: {
                              'startFrom': index,
                              'isReviewType': false,
                              'dataURL': proofData
                            },
                          ).then((Object? value) {
                            //locked in portrait mode only
                            SystemChrome.setPreferredOrientations(
                              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
                            );
                          });
                        },
                        child: UrlTypeHelper.getType(proofData[index]) == UrlType.image
                            ? CustomCachedNetworkImage(
                                imageUrl: proofData[index],
                                height: 50,
                                width: 50,
                              )
                            : UrlTypeHelper.getType(proofData[index]) == UrlType.video
                                ? Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Theme.of(context).colorScheme.accentColor,
                                    ),
                                  )
                                : Container(),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          showDivider(),
        ],
      ),
    );
  }

  Widget bookingDetailsWidget() {
    return CustomContainer(
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      cornerRadius: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTitle(title: 'bookingDetailsLbl'.translate(context: context)),
                const SizedBox(
                  height: 10,
                ),
                getTitleAndSubDetails(
                  title: 'invoiceNumber',
                  subDetails: widget.bookingsModel.invoiceNo ?? '',
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            child: getTitleAndSubDetailsWithBackgroundColor(
                              title: 'statusLbl',
                              subDetails: widget.bookingsModel.status
                                  .toString()
                                  .translate(context: context)
                                  .capitalize(),
                              subTitleBackgroundColor: AppColors.redColor,
                              subTitleColor: AppColors.redColor,
                              width: constraints.maxWidth - 10,
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return getTitleAndSubDetailsWithBackgroundColor(
                            title: 'paymentMethodLbl',
                            subDetails: widget.bookingsModel.paymentMethod
                                .toString()
                                .translate(context: context)
                                .capitalize(),
                            subTitleBackgroundColor: Theme.of(context).colorScheme.accentColor,
                            subTitleColor: Theme.of(context).colorScheme.accentColor,
                            width: constraints.maxWidth,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          showDivider(),
        ],
      ),
    );
  }

  Widget serviceDetailsWidget() {
    return CustomContainer(
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      cornerRadius: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTitle(title: 'serviceDetailsLbl'),
                setServiceRowValues(title: ''.translate(context: context), quantity: '', price: ''),
                for (Services service in widget.bookingsModel.services!) ...[
                  setServiceRowValues(
                    title: service.serviceTitle!,
                    quantity: service.quantity!,
                    price: service.discountPrice != "0" ? service.discountPrice! : service.price!,
                  ),
                  const SizedBox(
                    height: 5,
                  )
                ],
                UiUtils.setDivider(context: context),
                setServiceRowValues(
                  title: 'totalPriceLbl'.translate(context: context),
                  quantity: totalServiceQuantity.toString(),
                  isTitleBold: true,
                  price: (double.parse(widget.bookingsModel.total!.toString().replaceAll(",", "")) -
                          double.parse(
                            widget.bookingsModel.taxAmount!.toString().replaceAll(",", ""),
                          ))
                      .toString(),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
          showDivider()
        ],
      ),
    );
  }

  Widget setServiceRowValues({
    required String title,
    required String quantity,
    required String price,
    bool? isTitleBold,
    FontWeight? priceFontWeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: CustomText(
            titleText: title,
            fontSize: 14,
            fontWeight: (isTitleBold ?? false)
                ? FontWeight.bold
                : ((title != 'serviceDetailsLbl'.translate(context: context))
                    ? FontWeight.w400
                    : FontWeight.w700),
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
        ),
        if (quantity != '')
          Expanded(
            flex: 2,
            child: CustomText(
              textAlign: TextAlign.end,
              titleText: (title == 'totalPriceLbl'.translate(context: context) ||
                      title == 'totalServicePriceLbl'.translate(context: context))
                  ? "${"totalQtyLbl".translate(context: context)} $quantity"
                  : (title == 'gstLbl'.translate(context: context) ||
                          title == 'taxLbl'.translate(context: context))
                      ? quantity.formatPercentage()
                      : (title == 'couponDiscLbl'.translate(context: context))
                          ? "${quantity.formatPercentage()} ${"offLbl".translate(context: context)}"
                          : "${"qtyLbl".translate(context: context)} $quantity",
              fontSize: 14,
              fontColor: Theme.of(context).colorScheme.lightGreyColor,
            ),
          )
        else
          const SizedBox.shrink(),
        if (price != '')
          Expanded(
            child: CustomText(
              textAlign: TextAlign.end,
              titleText: UiUtils.getPriceFormat(context, double.parse(price.replaceAll(',', ''))),
              fontSize: (title == 'totalPriceLbl'.translate(context: context)) ? 14 : 14,
              fontWeight: priceFontWeight ?? FontWeight.w500,
              fontColor: Theme.of(context).colorScheme.blackColor,
            ),
          )
        else
          const SizedBox.shrink()
      ],
    );
  }

  Widget notesWidget() {
    if (widget.bookingsModel.remarks == '') {
      return const SizedBox(
        height: 10,
      );
    }
    return Column(
      children: [
        CustomContainer(
          cornerRadius: 15,
          bgColor: Theme.of(context).colorScheme.secondaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: getTitle(title: 'notesLbl'),
                    ),
                    CustomText(
                      titleText: widget.bookingsModel.remarks ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontColor: Theme.of(context).colorScheme.lightGreyColor,
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              showDivider()
            ],
          ),
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }

  Widget pricingWidget() {
    return CustomContainer(
      bgColor: Theme.of(context).colorScheme.secondaryColor,
      cornerRadius: 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getTitle(title: 'pricingLbl'),
            const SizedBox(height: 10),
            setServiceRowValues(
              title: 'totalServicePriceLbl'.translate(context: context),
              quantity: totalServiceQuantity.toString(),
              price: (double.parse(widget.bookingsModel.total!.toString().replaceAll(",", "")) -
                      double.parse(
                        widget.bookingsModel.taxAmount!.toString().replaceAll(",", ""),
                      ))
                  .toString(),
            ),
            if (widget.bookingsModel.promoDiscount != '0') ...[
              setServiceRowValues(
                title: 'couponDiscLbl'.translate(context: context),
                quantity:
                    widget.bookingsModel.promoCode == '' ? '--' : widget.bookingsModel.promoCode!,
                price: widget.bookingsModel.promoDiscount!,
              ),
            ],
            if (widget.bookingsModel.taxAmount != '' && widget.bookingsModel.taxAmount != null)
              setServiceRowValues(
                title: "taxLbl".translate(context: context),
                price: widget.bookingsModel.taxAmount.toString(),
                quantity: "",
              ),
            const SizedBox(height: 5),
            if (widget.bookingsModel.visitingCharges != "0")
              setServiceRowValues(
                title: 'visitingCharge'.translate(context: context),
                quantity: '',
                price: widget.bookingsModel.visitingCharges!,
              ),
            const SizedBox(height: 5),
            UiUtils.setDivider(context: context),
            setServiceRowValues(
              title: 'totalAmtLbl'.translate(context: context),
              quantity: '',
              isTitleBold: true,
              priceFontWeight: FontWeight.bold,
              price: widget.bookingsModel.finalTotal!,
            ),
          ],
        ),
      ),
    );
  }
}
