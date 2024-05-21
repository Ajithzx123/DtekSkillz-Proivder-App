import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/generalImports.dart';

class CalenderBottomSheet extends StatefulWidget {
  const CalenderBottomSheet({super.key, required this.advanceBookingDays});

  final String advanceBookingDays;

  @override
  State<CalenderBottomSheet> createState() => _CalenderBottomSheetState();
}

class _CalenderBottomSheetState extends State<CalenderBottomSheet> with TickerProviderStateMixin {
  PageController _pageController = PageController();
 List<String> listOfMonths = [
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december"
  ];

  String? selectedMonth;
  String? selectedYear;
  late DateTime focusDate, selectedDate;
  String? selectedTime;
  int? selectedTimeSlotIndex;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<Offset> calenderAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-1, 0),
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ),
  );

  late final Animation<Offset> timeSlotAnimation = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ),
  );

  TextStyle _getDayHeadingStyle() {
    return TextStyle(
      color: Theme.of(context).colorScheme.blackColor,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: 22.0,
    );
  }

  void fetchTimeSlots() {
    context.read<TimeSlotCubit>().getTimeslotDetails(selectedDate: selectedDate);
  }

  @override
  void initState() {
    focusDate = DateTime.now();
    selectedDate = DateTime.now();
    selectedMonth = listOfMonths[DateTime.now().month - 1];
    selectedYear = DateTime.now().year.toString();

    Future.delayed(Duration.zero).then((value) {
      fetchTimeSlots();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop({'selectedDate': selectedDate, 'selectedTime': selectedTime});
        return true;
      },
      child: StatefulBuilder(
        builder: (BuildContext context, setStater) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,

            child: Stack(
              children: [
                SlideTransition(
                  position: calenderAnimation,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _getSelectDateHeadingWithMonthAndYear(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: _getCalender(setStater),
                                  )
                                ],
                              ),
                            ),
                          ),
                     //     _getSelectedDateContainer(),
                          _getCloseAndTimeSlotNavigateButton()
                        ],
                      ),
                    ),
                  ),
                ),
                SlideTransition(
                  position: timeSlotAnimation,
                  child: Align(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getSelectTimeSlotHeadingWithDate(),
                          Expanded(
                            child: BlocConsumer<TimeSlotCubit, TimeSlotState>(
                              listener: (final context, final state) {
                                if (state is TimeSlotFetchSuccess) {
                                  if (state.isError) {
                                    UiUtils.showMessage(
                                      context,
                                      state.message,
                                      MessageType.warning,
                                    );
                                  }
                                }
                              },
                              builder: (final context, final state) {
                                //timeslot background color
                                final Color disabledTimeSlotColor = Theme.of(context)
                                    .colorScheme
                                    .lightGreyColor
                                    .withOpacity(0.35);
                                final Color selectedTimeSlotColor =
                                    Theme.of(context).colorScheme.accentColor;
                                final Color defaultTimeSlotColor =
                                    Theme.of(context).colorScheme.primaryColor;

                                //timeslot border color
                                final Color disabledTimeSlotBorderColor = Theme.of(context)
                                    .colorScheme
                                    .lightGreyColor
                                    .withOpacity(0.35);
                                final Color selectedTimeSlotBorderColor =
                                    Theme.of(context).colorScheme.accentColor;
                                final Color defaultTimeSlotBorderColor =
                                    Theme.of(context).colorScheme.blackColor;

                                //timeslot text color
                                final Color disabledTimeSlotTextColor =
                                    Theme.of(context).colorScheme.blackColor;
                                final Color selectedTimeSlotTextColor = AppColors.whiteColors;
                                final Color defaultTimeSlotTextColor =
                                    Theme.of(context).colorScheme.blackColor;

                                if (state is TimeSlotFetchSuccess) {
                                  return state.isError
                                      ? Center(
                                    child: Text(state.message),
                                  )
                                      : GridView.count(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10,
                                    ),
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 2.7,
                                    children: List<Widget>.generate(
                                      state.slotsData.length,
                                          (index) {
                                        return InkWell(
                                          onTap: () {
                                            if (state.slotsData[index].isAvailable ==
                                                0) {
                                              return;
                                            }

                                            selectedTime = state.slotsData[index].time;
                                          //  message = state.slotsData[index].message;
                                            selectedTimeSlotIndex = index;
                                            setState(() {});
                                          },
                                          child: slotItemContainer(
                                            backgroundColor:
                                            state.slotsData[index].isAvailable == 0
                                                ? disabledTimeSlotColor
                                                : selectedTimeSlotIndex == index
                                                ? selectedTimeSlotColor
                                                : defaultTimeSlotColor,
                                            borderColor:
                                            state.slotsData[index].isAvailable == 0
                                                ? disabledTimeSlotBorderColor
                                                : selectedTimeSlotIndex == index
                                                ? selectedTimeSlotBorderColor
                                                : defaultTimeSlotBorderColor,
                                            titleColor:
                                            state.slotsData[index].isAvailable == 0
                                                ? disabledTimeSlotTextColor
                                                : selectedTimeSlotIndex == index
                                                ? selectedTimeSlotTextColor
                                                : defaultTimeSlotTextColor,
                                            title: (state.slotsData[index].time ?? "")
                                                .formatTime(),
                                          ),
                                        );
                                      },
                                    ) +
                                        <Widget>[
                                          InkWell(
                                            onTap: () {
                                              displayTimePicker(context);
                                            },
                                            child: slotItemContainer(
                                                backgroundColor:
                                                Colors.transparent,
                                                titleColor:
                                                Theme.of(context).colorScheme.accentColor,
                                                borderColor:
                                                Theme.of(context).colorScheme.accentColor,
                                                title:selectedTime ?? "addSlot".translate(context: context)),
                                          )
                                        ],
                                  );
                                }
                                if (state is TimeSlotFetchFailure) {
                                  return ErrorContainer(
                                    onTapRetry: () {
                                      fetchTimeSlots();
                                    },
                                    errorMessage: state.errorMessage.translate(context: context),
                                  );
                                }
                                return Center(
                                  child: Text("loading".translate(context: context)),
                                );
                              },
                            ),
                          ),
                          //   _getSelectedCustomTimeSlotContainer(),
                          _getBackAndContinueNavigateButton()
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget slotItemContainer({
    required Color backgroundColor,
    required Color borderColor,
    required Color titleColor,
    required String title,
  }) {
    return Container(
      width: 150,
      height: 20,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        border: Border.all(
          width: 0.5,
          color: borderColor,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: titleColor),
        ),
      ),
    );
  }

//
  Future displayTimePicker(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = '${time.hour}:${time.minute}:00';
        selectedTimeSlotIndex = null;
      });
    }
  }

  //
  Widget _getSelectedCustomTimeSlotContainer() {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 5),
      width: MediaQuery.sizeOf(context).width * 0.9,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(13)),
        color: Theme.of(context).colorScheme.secondaryColor,
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            displayTimePicker(context);
          },
          child: Text(
            selectedTime != null
                ? '$selectedTime'
                : 'checkOnCustomTime'.translate(context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSelectTimeSlotHeadingWithDate() {
    final String monthName = listOfMonths[selectedDate.month - 1].translate(context: context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
          topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
        ),
      ),

      child: Row(
        children: [
          Text(
            'selectTimeSlot'.translate(context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
            ),
            height: 30,
            width: 110,
            child: Center(
              child: Text(
                '${selectedDate.day}-$monthName-${selectedDate.year}',
                style: TextStyle(color: Theme.of(context).colorScheme.accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSelectDateHeadingWithMonthAndYear() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
          topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
        ),
      ),
      child: Row(
        children: [
          Text(
            'selectDate'.translate(context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(7)),
                  border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
                ),
                height: 30,
                width: 70,
                child: Center(
                  child: Text(
                    '$selectedMonth'.translate(context: context),
                    style: TextStyle(color: Theme.of(context).colorScheme.accentColor),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(7)),
                  border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
                ),
                height: 30,
                width: 70,
                child: Center(
                  child: Text(
                    '$selectedYear',
                    style: TextStyle(color: Theme.of(context).colorScheme.accentColor),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getCalender(StateSetter setStater) {
    return Flexible(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.45,
        child: TableCalendar(
          onCalendarCreated: (PageController pageController) {
            _pageController = pageController;
          },
          headerVisible: false,
          currentDay: selectedDate,
          onPageChanged: (DateTime date) {
            //
            //add 0, if month is 1,2,3...9, to make it as 01,02...09 digit
            final String newIndex = (date.month).toString().padLeft(2, '0');

            selectedYear = date.year.toString();
            selectedMonth = listOfMonths[date.month - 1];
            //we are adding first date of month as focusDate
            focusDate = DateTime.parse('$selectedYear-$newIndex-01 00:00:00.000Z');
            //
            //If focus date is before of current date then we will add current date as focus date
            if (focusDate.isBefore(DateTime.now())) {
              focusDate = DateTime.now();
            }
            setState(() {});
          },
          onDaySelected: (DateTime date, DateTime date1) {
            //  focusDate = DateTime.parse(date.toString());
            selectedDate = DateTime.parse(date.toString());
            setStater(() {});
            fetchTimeSlots();
          },
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(Duration(days: int.parse(widget.advanceBookingDays))),
          focusedDay: focusDate,
          daysOfWeekHeight: 50,
          daysOfWeekStyle: DaysOfWeekStyle(
            dowTextFormatter: (DateTime date, locale) => DateFormat.E(locale).format(date)[0],
            weekendStyle: _getDayHeadingStyle(),
            weekdayStyle: _getDayHeadingStyle(),
          ),
        ),
      ),
    );
  }

  Widget _getSelectedDateContainer() {
    final String monthName = listOfMonths[selectedDate.month - 1].translate(context: context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      width: MediaQuery.sizeOf(context).width * 0.9,
      height: 50,
      decoration:  BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(13)),
        color: AppColors.whiteColors,
      ),
      child: Center(
        child: Text(
          '${selectedDate.day}-$monthName-${selectedDate.year}',
          style:  TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Row _getCloseAndTimeSlotNavigateButton() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .pop({'selectedDate': selectedDate, 'selectedTime': selectedTime});
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1c343f53),
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  )
                ],
                color: Theme.of(context).colorScheme.secondaryColor,
              ),
              child: Center(
                child: Text(
                  'close'.translate(context: context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              _controller.forward();
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1c343f53),
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  )
                ],
                color: Theme.of(context).colorScheme.accentColor,
              ),
              child: // Apply Filter
                  Center(
                child: Text(
                  'selectTimeSlot'.translate(context: context),
                  style: TextStyle(
                    color: AppColors.whiteColors,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Row _getBackAndContinueNavigateButton() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              _controller.reverse();
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1c343f53),
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  )
                ],
                color: Theme.of(context).colorScheme.secondaryColor,
              ),
              child: Center(
                child: Text(
                  'back'.translate(context: context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .pop({'selectedDate': selectedDate, 'selectedTime': selectedTime});
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1c343f53),
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  )
                ],
                color: Theme.of(context).colorScheme.accentColor,
              ),
              child: Center(
                child: Text(
                  'continue'.translate(context: context),
                  style: TextStyle(
                    color: AppColors.whiteColors,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
