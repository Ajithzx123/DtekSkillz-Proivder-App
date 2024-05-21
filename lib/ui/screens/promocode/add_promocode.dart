import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/generalImports.dart';

class AddPromoCode extends StatefulWidget {
  const AddPromoCode({super.key, this.promocode});

  final PromocodeModel? promocode;

  @override
  AddPromoCodeState createState() => AddPromoCodeState();

  static Route<AddPromoCode> route(RouteSettings routeSettings) {
    final Map? arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => AddPromoCode(promocode: arguments?['promocode']),
    );
  }
}

class AddPromoCodeState extends State<AddPromoCode> {
  int currIndex = 1;
  int totalForms = 2;

  //form 1
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  Map? selectedDiscountType;
  ScrollController scrollController = ScrollController();
  late String? selectedStartDate = widget.promocode?.startDate?.split(" ").first,
      selectedEndDate = widget.promocode?.endDate?.split(" ").first;

  //
  late TextEditingController promocodeController =
      TextEditingController(text: widget.promocode?.promoCode);
  late TextEditingController startDtController = TextEditingController(
      text: widget.promocode?.startDate?.split(" ").first.toString().formatDate());
  late TextEditingController endDtController = TextEditingController(
      text: widget.promocode?.endDate?.split(" ").first.toString().formatDate());
  late TextEditingController noOfUserController =
      TextEditingController(text: widget.promocode?.noOfUsers);
  late TextEditingController minOrderAmtController =
      TextEditingController(text: widget.promocode?.minimumOrderAmount);
  late TextEditingController discountController =
      TextEditingController(text: widget.promocode?.discount);
  late TextEditingController discountTypeController =
      TextEditingController(text: widget.promocode?.discountType);
  late TextEditingController noOfRepeatUsageController =
      TextEditingController(text: widget.promocode?.noOfRepeatUsage);
  FocusNode promocodeFocus = FocusNode();
  FocusNode startDtFocus = FocusNode();
  FocusNode endDtFocus = FocusNode();
  FocusNode noOfUserFocus = FocusNode();
  FocusNode minOrderAmtFocus = FocusNode();
  FocusNode discountFocus = FocusNode();
  FocusNode discountTypeFocus = FocusNode();
  FocusNode maxDiscFocus = FocusNode();
  FocusNode messageFocus = FocusNode();
  FocusNode noOfRepeatUsage = FocusNode();
  PickImage pickImage = PickImage();

  bool isStatus = false;
  bool isRepeatUsage = false;

  late TextEditingController maxDiscController =
      TextEditingController(text: widget.promocode?.maxDiscountAmount);
  late TextEditingController messageController =
      TextEditingController(text: widget.promocode?.message);

  List<Map> discountTypesFilter = [];

  @override
  void dispose() {
    promocodeController.dispose();
    startDtController.dispose();
    endDtController.dispose();
    noOfUserController.dispose();
    minOrderAmtController.dispose();
    discountController.dispose();
    discountTypeController.dispose();
    noOfRepeatUsageController.dispose();
    promocodeFocus.dispose();
    endDtFocus.dispose();
    noOfUserFocus.dispose();
    minOrderAmtFocus.dispose();
    discountFocus.dispose();
    discountTypeFocus.dispose();
    maxDiscFocus.dispose();
    messageFocus.dispose();
    noOfRepeatUsage.dispose();
    pickImage.dispose();
    maxDiscController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _chooseImage() {
    pickImage.pick();
  }

  void onAddPromoCode() {
    UiUtils.removeFocus();
    final FormState? form = formKey1.currentState; //default value
    if (form == null) return;
    //
    form.save();
    //
    if (form.validate()) {
      if (pickImage.pickedFile != null || widget.promocode?.image != null) {
        //need to add more field in create promocode model
        final CreatePromocodeModel createPromocode = CreatePromocodeModel(
          promo_id: widget.promocode?.id,
          promoCode: promocodeController.text,
          startDate: selectedStartDate.toString(),
          endDate: selectedEndDate.toString(),
          // startDate: startDtController.text,
          // endDate: endDtController.text,
          minimumOrderAmount: minOrderAmtController.text,
          discountType: selectedDiscountType?['value'],
          discount: discountController.text,
          maxDiscountAmount: maxDiscController.text,
          message: messageController.text,
          repeat_usage: (isRepeatUsage == false) ? '0' : '1',
          status: (isStatus == false) ? '0' : '1',
          no_of_users: noOfUserController.text,
          no_of_repeat_usage: noOfRepeatUsageController.text,
          image: pickImage.pickedFile,
        );

        //
        if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable()) {
          UiUtils.showDemoModeWarning(context: context);
          return;
        }
        //
        context.read<CreatePromocodeCubit>().createPromocode(
              createPromocode,
            );
      } else {
        FocusScope.of(context).unfocus();

        //show if image is not picked
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('imageRequired'.translate(context: context)),
              content: Text('pleaseSelectImage'.translate(context: context)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('ok'.translate(context: context)),
                )
              ],
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    if (widget.promocode?.status != null) {
      if (widget.promocode?.status == '0') {
        isStatus = false;
      } else {
        isStatus = true;
      }
    }
    if (widget.promocode?.repeatUsage != null) {
      if (widget.promocode?.repeatUsage == '0') {
        isRepeatUsage = false;
      } else {
        isRepeatUsage = true;
      }
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    discountTypesFilter = [
      {'value': 'percentage', 'title': 'percentage'.translate(context: context)},
      {'value': 'amount', 'title': 'amount'.translate(context: context)}
    ];

    if (widget.promocode?.discountType != null) {
      selectedDiscountType = discountTypesFilter
          .where((Map element) => element['value'] == widget.promocode?.discountType)
          .toList()[0];
    }

    super.didChangeDependencies();
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
          titleText: widget.promocode?.id != null
              ? 'editPromoCodeTitleLbl'.translate(context: context)
              : 'addPromoCodeTitleLbl'.translate(context: context),
          fontColor: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.bold,
        ),
        leading: UiUtils.setBackArrow(context),
      ),
      body: BlocListener<CreatePromocodeCubit, CreatePromocodeState>(
        listener: (BuildContext context, CreatePromocodeState state) {
          if (state is CreatePromocodeFailure) {
            UiUtils.showMessage(
                context, state.errorMessage.translate(context: context), MessageType.error);
          }
          if (state is CreatePromocodeSuccess) {
            UiUtils.showMessage(
              context,
              state.id == null
                  ? 'createPromocodeSuccess'.translate(context: context)
                  : 'updatePromocode'.translate(context: context),
              MessageType.success,
              onMessageClosed: () {
                if (state.id != null) {
                  ///update id state id is not null because it will be update if we have passed id.
                  context.read<FetchPromocodesCubit>().updatePromocode(state.promocode, state.id!);
                } else {
                  context.read<FetchPromocodesCubit>().addPromocodeToCubit(state.promocode);
                }
                Navigator.pop(context);
              },
            );
          }
        },
        child: screenBuilder(currIndex),
      ),
    );
  }

  Widget screenBuilder(int currentPage) {
    return Stack(
      children: [
        SingleChildScrollView(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15 + UiUtils.bottomButtonSpacing),
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: PromoCodeForm(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: bottomNavigation(),
        )
      ],
    );
  }

  Widget PromoCodeForm() {
    return Form(
      key: formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'promocodeLbl'.translate(context: context),
            controller: promocodeController,
            currNode: promocodeFocus,
            validator: (String? value) => Validator.nullCheck(value),
            // backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            nextFocus: messageFocus,
          ),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'messageLbl'.translate(context: context),
            controller: messageController,
            currNode: messageFocus,
            nextFocus: startDtFocus,
            //backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            textInputType: TextInputType.multiline,
            validator: (String? value) => Validator.nullCheck(value),
          ),
          CustomText(
            titleText: 'imageLbl'.translate(context: context),
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          const SizedBox(
            height: 5,
          ),
          pickImage.ListenImageChange(
            (BuildContext context, image) {
              if (image == null) {
                if (widget.promocode?.image != null) {
                  return GestureDetector(
                    onTap: _chooseImage,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: SizedBox(
                            height: 200,
                            width: MediaQuery.sizeOf(context).width,
                            child: CustomCachedNetworkImage(imageUrl: widget.promocode!.image!),
                          ),
                        ),
                        SizedBox(
                          height: 210,
                          width: MediaQuery.sizeOf(context).width - 5,
                          child: DashedRect(
                            color: Theme.of(context).colorScheme.blackColor,
                            strokeWidth: 2.0,
                            gap: 4.0,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                    onTap: _chooseImage,
                    child: SetDottedBorderWithHint(
                      height: 100,
                      width: MediaQuery.sizeOf(context).width - 35,
                      radius: 7,
                      str: 'chooseImgLbl'.translate(context: context),
                      strPrefix: '',
                      borderColor: Theme.of(context).colorScheme.blackColor,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(3.0),
                child: GestureDetector(
                  onTap: _chooseImage,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 200,
                        width: MediaQuery.sizeOf(context).width,
                        child: Image.file(
                          image,
                        ),
                      ),
                      SizedBox(
                        height: 210,
                        width: MediaQuery.sizeOf(context).width - 5,
                        child: DashedRect(
                          color: Theme.of(context).colorScheme.blackColor,
                          strokeWidth: 2.0,
                          gap: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'startDateLbl'.translate(context: context),
                  controller: startDtController,
                  //backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                  currNode: startDtFocus,
                  nextFocus: endDtFocus,
                  validator: (String? value) => Validator.nullCheck(value),
                  callback: () => onDateTap(
                    isStartDate: true,
                    startDtController,
                  ),
                  isReadOnly: true,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'endDateLbl'.translate(context: context),
                  controller: endDtController,
                  currNode: endDtFocus,
                  nextFocus: minOrderAmtFocus,
                  // backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                  callback: () {
                    if (startDtController.text.isEmpty) {
                      FocusScope.of(context).unfocus();
                      UiUtils.showMessage(
                        context,
                        'selectStartDateFirst'.translate(context: context),
                        MessageType.warning,
                      );
                      return;
                    }
                    onDateTap(
                      endDtController,
                      isStartDate: false,
                    );
                  },
                  validator: (String? value) => Validator.nullCheck(value),
                  isReadOnly: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'minOrderAmtLbl'.translate(context: context),
                  controller: minOrderAmtController,
                  allowOnlySingleDecimalPoint: true,
                  currNode: minOrderAmtFocus,
                  nextFocus: noOfUserFocus,
                  validator: (String? value) => Validator.nullCheck(value),
                  // backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                  textInputType: TextInputType.number,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'noOfUserLbl'.translate(context: context),
                  controller: noOfUserController,
                  currNode: noOfUserFocus,
                  nextFocus: discountFocus,
                  inputFormatters: UiUtils.allowOnlyDigits(),
                  textInputType: TextInputType.number,
                  validator: (String? value) => Validator.nullCheck(value),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'discountLbl'.translate(context: context),
                  controller: discountController,
                  textInputType: TextInputType.phone,
                  allowOnlySingleDecimalPoint: true,
                  //   backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                  currNode: discountFocus,
                  nextFocus: discountTypeFocus,
                  validator: (String? value) => Validator.nullCheck(value),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: UiUtils.setTitleAndTFF(
                  context,
                  isReadOnly: true,
                  titleText: 'discTypeLbl'.translate(context: context),
                  //   backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                  controller: discountTypeController,
                  validator: (String? value) {
                    if (selectedDiscountType == null) {
                      return 'chooseDiscountType'.translate(context: context);
                    }
                    return null;
                  },
                  currNode: discountTypeFocus,
                  nextFocus: maxDiscFocus,
                  callback: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialogs.showSelectDialoge(
                          selectedValue: selectedDiscountType?['value'],
                          itemList: discountTypesFilter,
                        );
                      },
                    );
                    discountTypeController.text = result['title'];

                    selectedDiscountType = result;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'maxDiscAmtLbl'.translate(context: context),
                  controller: maxDiscController,
                  currNode: maxDiscFocus,
                  nextFocus: noOfRepeatUsage,
                  allowOnlySingleDecimalPoint: true,
                  textInputType: TextInputType.number,
                  validator: (String? value) {
                    return Validator.nullCheck(value);
                  },
                ),
              ),
              if (isRepeatUsage) ...[
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: UiUtils.setTitleAndTFF(
                    context,
                    titleText: 'noOfrepeat'.translate(context: context),
                    controller: noOfRepeatUsageController,
                    currNode: noOfRepeatUsage,
                    inputFormatters: UiUtils.allowOnlyDigits(),
                    forceUnfocus: true,
                    validator: (String? p0) => Validator.nullCheck(p0),
                    textInputType: TextInputType.number,
                  ),
                )
              ]
            ],
          ),
          setTitleAndSwitch(
            isAllowed: isRepeatUsage,
            titleText: 'repeatUsageLbl'.translate(context: context),
          ),
          setTitleAndSwitch(
            isAllowed: isStatus,
            titleText: 'statusLbl'.translate(context: context),
          ),
        ],
      ),
    );
  }

  Future<void> onDateTap(
    TextEditingController dateInput, {
    required bool isStartDate,
  }) async {
    final DateTime? initialDate =
        isStartDate ? null : DateTime.parse('$selectedStartDate 00:00:00.000');
    //
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: initialDate ?? DateTime.now().subtract(Duration.zero), //1
      lastDate: DateTime.now().add(const Duration(days: UiUtils.noOfDaysAllowToCreatePromoCode)),
    );

    if (pickedDate != null) {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (isStartDate) {
        selectedStartDate = formattedDate;
      } else {
        selectedEndDate = formattedDate;
      }
      setState(() {
        dateInput.text = formattedDate.formatDate(); //set output date to TextField value.
      });
    }
  }

  Widget setTitleAndSwitch({required String titleText, required bool isAllowed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomText(
            titleText: titleText,
            fontWeight: FontWeight.w400,
            fontColor: Theme.of(context).colorScheme.blackColor,
            fontSize: 18.0,
          ),
        ),
        CupertinoSwitch(
          value: isAllowed,
          //with Cupertino Switch only
          onChanged: (bool val) {
            if (titleText == 'statusLbl'.translate(context: context)) {
              isStatus = val;
            } else if (titleText == 'repeatUsageLbl'.translate(context: context)) {
              isRepeatUsage = val;
            }
            setState(() {});
          },
        )
      ],
    );
  }

  Padding bottomNavigation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 15, right: 15),
      child: CustomRoundedButton(
        widthPercentage: 1,
        textSize: 14,
        height: 55,
        titleColor: AppColors.whiteColors,
        onTap: (context.watch<CreatePromocodeCubit>().state is CreatePromocodeInProgress)
            ? () {}
            : onAddPromoCode,
        backgroundColor: Theme.of(context).colorScheme.accentColor,
        buttonTitle: widget.promocode?.id != null
            ? 'editPromoCodeTitleLbl'.translate(context: context)
            : 'addPromoCodeTitleLbl'.translate(context: context),
        showBorder: true,
        child: (context.watch<CreatePromocodeCubit>().state is CreatePromocodeInProgress)
            ? CircularProgressIndicator(
                color: AppColors.whiteColors,
              )
            : null,
      ),
    );
  }
}
