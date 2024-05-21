import 'package:edemand_partner/ui/widgets/htmlEditor.dart';
import 'package:edemand_partner/utils/appQuickActions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';

import '../../../app/generalImports.dart';
import '../../../utils/location.dart';
import '../../widgets/bottomSheets/showImagePickerOptionBottomSheet.dart';
import 'map.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key, required this.isEditing, this.service});
  final bool isEditing;
  final ServiceModel? service;
  @override
  RegistrationFormState createState() => RegistrationFormState();

  static Route<RegistrationForm> route(RouteSettings routeSettings) {
    final Map<String, dynamic> parameters =
        routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<EditProviderDetailsCubit>(
            create: (BuildContext context) => EditProviderDetailsCubit(),
          ),
          BlocProvider<CreateServiceCubit>(
            create: (BuildContext context) => CreateServiceCubit(),
          ),
        ],
        child: RegistrationForm(
          isEditing: parameters['isEditing'],
        ),
      ),
    );
  }
}

class RegistrationFormState extends State<RegistrationForm>
    with ChangeNotifier {
  int totalForms = 8;

  int currentIndex = 1;
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey4 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey5 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey6 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey7 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey8 = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();
  HtmlEditorController htmlController = HtmlEditorController();

  ///form1
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode userNmFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobNoFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  Map<String, dynamic> pickedLocalImages = {
    'nationalIdImage': '',
    'addressIdImage': '',
    'passportIdImage': '',
    'logoImage': '',
    'bannerImage': ''
  };

  ///form2
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController aboutCompanyController = TextEditingController();
  TextEditingController visitingChargesController = TextEditingController();
  TextEditingController advanceBookingDaysController = TextEditingController();
  TextEditingController numberOfMemberController = TextEditingController();
  //AAA
  TextEditingController educationqualificationController =
      TextEditingController();
  TextEditingController yearsofExperienceController = TextEditingController();
  TextEditingController specializedController = TextEditingController();

  FocusNode aboutCompanyFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode latitudeFocus = FocusNode();
  FocusNode longitudeFocus = FocusNode();
  FocusNode companyNmFocus = FocusNode();
  //AAA
  FocusNode educationFocus = FocusNode();
  FocusNode yearsExpFocus = FocusNode();
  FocusNode specilizedInFocus = FocusNode();

  FocusNode visitingChargeFocus = FocusNode();
  FocusNode advanceBookingDaysFocus = FocusNode();
  FocusNode numberOfMemberFocus = FocusNode();
  Map? selectCompanyType;
  Map companyType = {'0': 'Individual', '1': 'Organisation'};

  ///form3
  List<bool> isChecked =
      List<bool>.generate(7, (int index) => false); //7 = daysOfWeek.length
  List<TimeOfDay> selectedStartTime = [];
  List<TimeOfDay> selectedEndTime = [];

  late List<String> daysOfWeek = [
    'sunLbl'.translate(context: context),
    'monLbl'.translate(context: context),
    'tueLbl'.translate(context: context),
    'wedLbl'.translate(context: context),
    'thuLbl'.translate(context: context),
    'friLbl'.translate(context: context),
    'satLbl'.translate(context: context),
  ];

  late List<String> daysInWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  ///form4
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController taxNameController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController upiController = TextEditingController();

  FocusNode bankNameFocus = FocusNode();
  FocusNode bankCodeFocus = FocusNode();
  FocusNode bankAccountNumberFocus = FocusNode();
  FocusNode accountNameFocus = FocusNode();
  FocusNode accountNumberFocus = FocusNode();
  FocusNode taxNameFocus = FocusNode();
  FocusNode taxNumberFocus = FocusNode();
  FocusNode upiFocus = FocusNode();

  PickImage pickLogoImage = PickImage();
  PickImage pickBannerImage = PickImage();
  PickImage pickAddressProofImage = PickImage();
  PickImage pickPassportImage = PickImage();
  PickImage pickNationalIdImage = PickImage();

  ProviderDetails? providerData;
  bool? isIndividualType;

  String? longDescription;
  ValueNotifier<List<String>> pickedOtherImages = ValueNotifier([]);
  List<String>? previouslyAddedOtherImages = [];

  @override
  void initState() {
    super.initState();

    initializeData();
  }

  void initializeData() {
    Future.delayed(Duration.zero).then((value) {
      //
      providerData = context.read<ProviderDetailsCubit>().providerDetails;
      //
      userNameController.text = providerData?.user?.username ?? '';
      emailController.text = providerData?.user?.email ?? '';
      mobileNumberController.text =
          "${providerData?.user?.countryCode ?? ""} ${providerData?.user?.phone ?? ""}";
      companyNameController.text =
          providerData?.providerInformation?.companyName ?? '';
      aboutCompanyController.text =
          providerData?.providerInformation?.about ?? '';
      //AAA
      educationqualificationController.text =
          providerData?.providerInformation?.educationQul ?? '';
      yearsofExperienceController.text =
          providerData?.providerInformation?.yearsofExp ?? '';
      specializedController.text =
          providerData?.providerInformation?.speclizedIn ?? '';

      //
      bankNameController.text = providerData?.bankInformation?.bankName ?? '';
      bankCodeController.text = providerData?.bankInformation?.bankCode ?? '';
      accountNameController.text =
          providerData?.bankInformation?.accountName ?? '';
      accountNumberController.text =
          providerData?.bankInformation?.accountNumber ?? '';
      taxNameController.text = providerData?.bankInformation?.taxName ?? '';
      taxNumberController.text = providerData?.bankInformation?.taxNumber ?? '';
      upiController.text = providerData?.bankInformation?.upi ?? '';
      //
      cityController.text = providerData?.locationInformation?.city ?? '';
      addressController.text = providerData?.locationInformation?.address ?? '';
      latitudeController.text =
          providerData?.locationInformation?.latitude ?? '';
      longitudeController.text =
          providerData?.locationInformation?.longitude ?? '';
      companyNameController.text =
          providerData?.providerInformation?.companyName ?? '';
      //AAA
      educationqualificationController.text =
          providerData?.providerInformation?.educationQul ?? '';
      yearsofExperienceController.text =
          providerData?.providerInformation?.yearsofExp ?? '';
      specializedController.text =
          providerData?.providerInformation?.speclizedIn ?? '';
      aboutCompanyController.text =
          providerData?.providerInformation?.about ?? '';
      visitingChargesController.text =
          providerData?.providerInformation?.visitingCharges ?? '';
      advanceBookingDaysController.text =
          providerData?.providerInformation?.advanceBookingDays ?? '';
      numberOfMemberController.text =
          providerData?.providerInformation?.numberOfMembers ?? '';
      selectCompanyType = providerData?.providerInformation?.type == '1'
          ? {'title': 'Individual', 'value': '0'}
          : {'title': 'Organization', 'value': '1'};
      isIndividualType = providerData?.providerInformation?.type == '1';
      //add elements in TimeOfDay List
      for (int i = 0; i < daysInWeek.length; i++) {
        //assign Default time @ start
        final List<String> startTime =
            (providerData?.workingDays?[i].startTime ?? '09:00:00').split(':');
        final List<String> endTime =
            (providerData?.workingDays?[i].endTime ?? '18:00:00').split(':');

        final int startTimeHour = int.parse(startTime[0]);
        final int startTimeMinute = int.parse(startTime[1]);
        selectedStartTime.insert(
          i,
          TimeOfDay(hour: startTimeHour, minute: startTimeMinute),
        );
        //
        final int endTimeHour = int.parse(endTime[0]);
        final int endTimeMinute = int.parse(endTime[1]);
        selectedEndTime.insert(
          i,
          TimeOfDay(hour: endTimeHour, minute: endTimeMinute),
        );
        isChecked[i] = providerData?.workingDays?[i].isOpen == 1;
      }

      longDescription = providerData?.providerInformation?.longDescription;
      previouslyAddedOtherImages =
          providerData?.providerInformation?.otherImages;
    });
    setState(() {});
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    mobileNumberController.dispose();
    companyNameController.dispose();
    visitingChargesController.dispose();
    advanceBookingDaysController.dispose();
    numberOfMemberController.dispose();
    aboutCompanyController.dispose();
    cityController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    addressController.dispose();
    bankNameController.dispose();
    bankCodeController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    taxNumberController.dispose();
    taxNameController.dispose();
    upiController.dispose();
    pickedLocalImages.clear();
    pickedOtherImages.dispose();
    educationqualificationController.dispose();
    yearsofExperienceController.dispose();
    specializedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (currentIndex > 1) {
              currentIndex--;
              pickedLocalImages = pickedLocalImages;
              setState(() {});
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryColor,
            appBar: AppBar(
              elevation: 1,
              centerTitle: true,
              title: CustomText(
                titleText: widget.isEditing
                    ? 'editDetails'.translate(context: context)
                    : 'completeKYCDetails'.translate(context: context),
                fontColor: Theme.of(context).colorScheme.blackColor,
                fontWeight: FontWeight.bold,
              ),
              leading: widget.isEditing
                  ? UiUtils.setBackArrow(
                      context,
                      onTap: () {
                        if (currentIndex > 1) {
                          currentIndex--;
                          pickedLocalImages = pickedLocalImages;
                          setState(() {});
                          return;
                        }
                        Navigator.pop(context);
                      },
                    )
                  : null,
              backgroundColor: Theme.of(context).colorScheme.secondaryColor,
              actions: <Widget>[
                PageNumberIndicator(
                  currentIndex: currentIndex,
                  total: totalForms,
                )
              ],
            ),
            bottomNavigationBar: bottomNavigation(currentIndex: currentIndex),
            body: screenBuilder(currentIndex),
          ),
        ),
      ),
    );
  }

  Padding bottomNavigation({required int currentIndex}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentIndex > 1) ...[
            Expanded(
              child: nextPrevBtnWidget(
                isNext: false,
                currentIndex: currentIndex,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: nextPrevBtnWidget(isNext: true, currentIndex: currentIndex),
          ),
        ],
      ),
    );
  }

  BlocConsumer<EditProviderDetailsCubit, EditProviderDetailsState>
      nextPrevBtnWidget({required bool isNext, required int currentIndex}) {
    return BlocConsumer<EditProviderDetailsCubit, EditProviderDetailsState>(
      listener: (BuildContext context, EditProviderDetailsState state) async {
        if (state is EditProviderDetailsSuccess) {
          UiUtils.showMessage(
            context,
            'detailsUpdatedSuccessfully'.translate(context: context),
            MessageType.success,
          );
          //

          //
          if (widget.isEditing) {
            context
                .read<ProviderDetailsCubit>()
                .setUserInfo(state.providerDetails);
            Future.delayed(const Duration(seconds: 1)).then((value) {
              Navigator.pop(context);
            });
          } else {
            await HiveUtils.logoutUser(
              onLogout: () {
                //
                // Notificat0ionService.disposeListeners();
                AppQuickActions.clearShortcutItems();
                context.read<AuthenticationCubit>().setUnAuthenticated();
                //
              },
            );
            //
            Future.delayed(const Duration(seconds: 1)).then((value) {
              Navigator.pushReplacementNamed(
                context,
                Routes.successScreen,
                arguments: {
                  'title': 'detailsSubmitted'.translate(context: context),
                  'message': 'detailsHasBeenSubmittedWaitForAdminApproval'
                      .translate(context: context),
                  'imageName': 'registration'
                },
              );
            });
          }
        } else if (state is EditProviderDetailsFailure) {
          print('submition is faild');
          UiUtils.showMessage(
            context,
            state.errorMessage.translate(context: context),
            MessageType.error,
          );
        }
      },
      builder: (BuildContext context, EditProviderDetailsState state) {
        Widget? child;
        if (state is EditProviderDetailsInProgress) {
          child = CircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        } else if (state is EditProviderDetailsSuccess ||
            state is EditProviderDetailsFailure) {
          child = null;
        }
        return CustomRoundedButton(
          widthPercentage: isNext ? 1 : 0.5,
          backgroundColor: isNext
              ? Theme.of(context).colorScheme.accentColor
              : Theme.of(context).colorScheme.primaryColor,
          buttonTitle: isNext && currentIndex >= totalForms
              ? 'submitBtnLbl'.translate(context: context)
              : isNext
                  ? 'nxtBtnLbl'.translate(context: context)
                  : 'prevBtnLbl'.translate(context: context),
          showBorder: isNext ? false : true,
          borderColor: Theme.of(context).colorScheme.blackColor,
          titleColor: isNext
              ? AppColors.whiteColors
              : Theme.of(context).colorScheme.blackColor,
          onTap: () => state is EditProviderDetailsInProgress
              ? () {}
              : onNextPrevBtnClick(isNext: isNext, currentPage: currentIndex),
          child: isNext && currentIndex >= totalForms ? child : null,
        );
      },
    );
  }

  Future<void> onNextPrevBtnClick({
    required bool isNext,
    required int currentPage,
  }) async {
    if (currentPage == 3) {
      final tempText = await htmlController.getText();

      if (tempText.trim().isNotEmpty) {
        longDescription = tempText;
      }
    }
    if (isNext) {
      FormState? form = formKey1.currentState; //default value
      switch (currentPage) {
        case 2:
          form = formKey2.currentState;
          break;
        case 4:
          form = formKey4.currentState;
          break;
        case 5:
          form = formKey5.currentState;
          break;
        case 6:
          form = formKey6.currentState;
          break;
        case 7:
          form = formKey7.currentState;
          break;
        case 8:
          form = formKey8.currentState;
          break;
        default:
          form = formKey1.currentState;
          break;
      }
      if (currentPage != 3) {
        if (form == null) return;
        form.save();
      }

      if (currentPage == 3 || form!.validate()) {
        if (currentPage < totalForms) {
          currentIndex++;
          if (currentPage != 3) {
            scrollController.jumpTo(0); //reset Scrolling on Form change
          }
          pickedLocalImages = pickedLocalImages;
          setState(() {});
        } else {
          final List<WorkingDay> workingDays = [];
          for (int i = 0; i < daysInWeek.length; i++) {
            //
            workingDays.add(
              WorkingDay(
                isOpen: isChecked[i] ? 1 : 0,
                endTime:
                    "${selectedEndTime[i].hour.toString().padLeft(2, "0")}:${selectedEndTime[i].minute.toString().padLeft(2, "0")}:00",
                startTime:
                    "${selectedStartTime[i].hour.toString().padLeft(2, "0")}:${selectedStartTime[i].minute.toString().padLeft(2, "0")}:00",
                day: daysInWeek[i],
              ),
            );
          }

          final ProviderDetails editProviderDetails = ProviderDetails(
            user: UserDetails(
              id: providerData?.user?.id,
              username: userNameController.text.trim(),
              email: emailController.text.trim(),
              phone: providerData?.user?.phone,
              countryCode: providerData?.user?.countryCode,
              company: companyNameController.text.trim(),
              image: pickedLocalImages['logoImage'],
            ),
            providerInformation: ProviderInformation(
              type: selectCompanyType?['value'],
              companyName: companyNameController.text.trim(),
              visitingCharges: visitingChargesController.text.trim(),
              advanceBookingDays: advanceBookingDaysController.text.trim(),
              about: aboutCompanyController.text.trim(),
              numberOfMembers: numberOfMemberController.text.trim(),
              banner: pickedLocalImages['bannerImage'],
              nationalId: pickedLocalImages['nationalIdImage'],
              passport: pickedLocalImages['passportIdImage'],
              addressId: pickedLocalImages['addressIdImage'],
              otherImages: pickedOtherImages.value,
              longDescription: longDescription,
              //AAA
              educationQul: educationqualificationController.text.trim(),
              yearsofExp: yearsofExperienceController.text.trim(),
              speclizedIn: specializedController.text.trim(),
            ),
            bankInformation: BankInformation(
              accountName: accountNameController.text.trim(),
              accountNumber: accountNumberController.text.trim(),
              bankCode: bankCodeController.text.trim(),
              bankName: bankNameController.text.trim(),
              taxName: taxNameController.text.trim(),
              taxNumber: taxNumberController.text.trim(),
              upi: upiController.text.trim(),
            ),
            locationInformation: LocationInformation(
              longitude: longitudeController.text.trim(),
              latitude: latitudeController.text.trim(),
              address: addressController.text.trim(),
              city: cityController.text.trim(),
            ),
            workingDays: workingDays,
          );
          //
          if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable() &&
              widget.isEditing) {
            UiUtils.showDemoModeWarning(context: context);
            return;
          }
          context
              .read<EditProviderDetailsCubit>()
              .editProviderDetails(providerDetails: editProviderDetails);
        }
      }
    } else if (currentPage > 1) {
      currentIndex--;
      pickedLocalImages = pickedLocalImages;
      setState(() {});
    }
  }

  Widget screenBuilder(int currentPage) {
    Widget currentForm = form1(); //default form1
    switch (currentPage) {
      case 2:
        currentForm = form2();
        break;
      case 3:
        currentForm = form3();
        break;
      case 4:
        currentForm = form4();
        break;
      case 5:
        currentForm = form5();
        break;
      case 6:
        currentForm = form6();
        break;
      case 7:
        currentForm = form7();
        break;
      case 8:
        currentForm = form8();
        break;
      default:
        currentForm = form1();
        break;
    }
    return currentPage == 3
        ? currentForm
        : SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.all(15),
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: currentForm,
          );
  }

  Widget form1() {
    return Form(
      key: formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            titleText: 'personalDetails'.translate(context: context),
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          UiUtils.setDivider(context: context),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'userNmLbl'.translate(context: context),
            controller: userNameController,
            currNode: userNmFocus,
            nextFocus: emailFocus,
            validator: (String? cityValue) => Validator.nullCheck(cityValue),
          ),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'emailLbl'.translate(context: context),
            controller: emailController,
            currNode: emailFocus,
            nextFocus: mobNoFocus,
            textInputType: TextInputType.emailAddress,
            validator: (String? cityValue) => Validator.nullCheck(cityValue),
          ),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'mobNoLbl'.translate(context: context),
            controller: mobileNumberController,
            currNode: mobNoFocus,
            textInputType: TextInputType.phone,
            isReadOnly: true,
            validator: (String? cityValue) => Validator.nullCheck(cityValue),
          ),
          /*UiUtils.setTitleAndTFF(context, titleText: UiUtils.getTranslatedLabel(context, "passwordLbl"), controller: passwordController, currNode: passwordFocus, nextFocus: confirmPasswordFocus, isPswd: true),
            UiUtils.setTitleAndTFF(context,
                titleText: UiUtils.getTranslatedLabel(context, "confirmPasswordLbl"), controller: confirmPasswordController, currNode: confirmPasswordFocus, nextFocus: companyNmFocus, isPswd: true),*/

          const SizedBox(
            height: 12,
          ),
          CustomText(
            titleText: 'idProofLbl'.translate(context: context),
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          UiUtils.setDivider(context: context),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                idImageWidget(
                  imageController: pickNationalIdImage,
                  titleTxt: 'nationalIdLbl'.translate(context: context),
                  imageHintText: 'chooseFileLbl'.translate(context: context),
                  imageType: 'nationalIdImage',
                  oldImage: context
                          .read<ProviderDetailsCubit>()
                          .providerDetails
                          .providerInformation
                          ?.nationalId ??
                      '',
                ),
                idImageWidget(
                  imageController: pickAddressProofImage,
                  titleTxt: 'addressLabel'.translate(context: context),
                  imageHintText: 'chooseFileLbl'.translate(context: context),
                  imageType: 'addressIdImage',
                  oldImage: context
                          .read<ProviderDetailsCubit>()
                          .providerDetails
                          .providerInformation
                          ?.addressId ??
                      '',
                ),
                idImageWidget(
                  imageController: pickPassportImage,
                  titleTxt: 'passportLbl'.translate(context: context),
                  imageHintText: 'chooseFileLbl'.translate(context: context),
                  imageType: 'passportIdImage',
                  oldImage: context
                          .read<ProviderDetailsCubit>()
                          .providerDetails
                          .providerInformation
                          ?.passport ??
                      '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget form2() {
    return Form(
      key: formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            titleText: 'companyDetails'.translate(context: context),
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          UiUtils.setDivider(context: context),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'compNmLbl'.translate(context: context),
            controller: companyNameController,
            currNode: companyNmFocus,
            nextFocus: visitingChargeFocus,
            validator: (String? cityValue) => Validator.nullCheck(cityValue),
          ),
          // UiUtils.setTitleAndTFF(
          //   context,
          //   titleText: 'visitingCharge'.translate(context: context),
          //   controller: visitingChargesController,
          //   currNode: visitingChargeFocus,
          //   nextFocus: companyNmFocus,
          //   validator: (String? cityValue) => Validator.nullCheck(cityValue),
          //   textInputType: TextInputType.number,
          //   allowOnlySingleDecimalPoint: true,
          //   prefix: Padding(
          //     padding: const EdgeInsetsDirectional.only(start: 15, end: 15),
          //     child: IntrinsicHeight(
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           CustomText(
          //             titleText: Constant.systemCurrency ?? '',
          //             fontSize: 15.0,
          //             fontColor: Theme.of(context).colorScheme.blackColor,
          //           ),
          //           VerticalDivider(
          //             color: Theme.of(context)
          //                 .colorScheme
          //                 .blackColor
          //                 .withAlpha(150),
          //             thickness: 1,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'eqcationQul'.translate(context: context),
            controller: educationqualificationController,
            currNode: educationFocus,
            nextFocus: yearsExpFocus,
            validator: (String? cityValue) => Validator.nullCheck(cityValue),
          ),
          UiUtils.setTitleAndTFF(
            context,
            textInputType: TextInputType.number,
            titleText: 'yearOfEXP'.translate(context: context),
            controller: yearsofExperienceController,
            currNode: yearsExpFocus,
            nextFocus: specilizedInFocus,
            validator: (String? cityValue) => Validator.nullCheck(cityValue),
          ),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'splIn'.translate(context: context),
            controller: specializedController,
            currNode: specilizedInFocus,
            nextFocus: yearsExpFocus,
            validator: (String? cityValue) => Validator.nullCheck(cityValue),
          ),
          // UiUtils.setTitleAndTFF(
          //   context,
          //   titleText: 'advanceBookingDay'.translate(context: context),
          //   controller: advanceBookingDaysController,
          //   currNode: advanceBookingDaysFocus,
          //   nextFocus: numberOfMemberFocus,
          //   validator: (String? cityValue) => Validator.nullCheck(cityValue),
          //   textInputType: TextInputType.number,
          // ),
          // UiUtils.setTitleAndTFF(
          //   context,
          //   titleText: 'aboutCompany'.translate(context: context),
          //   controller: aboutCompanyController,
          //   currNode: aboutCompanyFocus,
          //   minLines: 3,
          //   expands: true,
          //   textInputType: TextInputType.multiline,
          //   validator: (String? cityValue) => Validator.nullCheck(cityValue),
          // ),
          // buildDropDown(
          //   context,
          //   title: 'selectType'.translate(context: context),
          //   initialValue: selectCompanyType?['title'] ??
          //       'selectType'.translate(context: context),
          //   value: companyType[selectCompanyType]?['value'],
          //   onTap: () {
          //     selectCompanyTypes();
          //   },
          // ),
          // const SizedBox(
          //   height: 16,
          // ),
          // UiUtils.setTitleAndTFF(
          //   context,
          //   titleText: 'numberOfMember'.translate(context: context),
          //   controller: numberOfMemberController,
          //   currNode: numberOfMemberFocus,
          //   nextFocus: aboutCompanyFocus,
          //   validator: (String? cityValue) => Validator.nullCheck(cityValue),
          //   isReadOnly: isIndividualType ?? false,
          //   textInputType: TextInputType.number,
          // ),
          // const SizedBox(
          //   height: 7,
          // ),
          // CustomText(
          //   titleText: 'logoLbl'.translate(context: context),
          //   fontColor: Theme.of(context).colorScheme.blackColor,
          // ),
          // const SizedBox(
          //   height: 7,
          // ),
          // imagePicker(
          //   imageController: pickLogoImage,
          //   oldImage: providerData?.user?.image ?? '',
          //   hintLabel:
          //       "${"addLbl".translate(context: context)} ${"logoLbl".translate(context: context)}",
          //   imageType: 'logoImage',
          // ),

          const SizedBox(
            height: 12,
          ),
          CustomText(
            titleText: 'bannerImgLbl'.translate(context: context),
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          const SizedBox(
            height: 7,
          ),
          imagePicker(
            imageController: pickBannerImage,
            oldImage: providerData?.providerInformation?.banner ?? '',
            hintLabel:
                "${"addLbl".translate(context: context)} ${"bannerImgLbl".translate(context: context)}",
            imageType: 'bannerImage',
          ),
          const SizedBox(height: 15),
          CustomText(
            titleText: 'otherImages'.translate(context: context),
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          const SizedBox(height: 5),
          //other image picker builder
          ValueListenableBuilder(
            valueListenable: pickedOtherImages,
            builder: (BuildContext context, Object? value, Widget? child) {
              final bool isThereAnyImage = pickedOtherImages.value.isNotEmpty ||
                  (previouslyAddedOtherImages != null &&
                      previouslyAddedOtherImages!.isNotEmpty);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SizedBox(
                  height: isThereAnyImage ? 150 : 100,
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            try {
                              final FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                type: FileType.image,
                              );
                              if (result != null) {
                                if (previouslyAddedOtherImages != null &&
                                    previouslyAddedOtherImages!.isNotEmpty) {
                                  previouslyAddedOtherImages = null;
                                }
                                for (int i = 0; i < result.files.length; i++) {
                                  if (!pickedOtherImages.value
                                      .contains(result.files[i].path)) {
                                    pickedOtherImages.value
                                        .insert(0, result.files[i].path!);
                                  }
                                }
                                pickedOtherImages.notifyListeners();
                              } else {
                                // User canceled the picker
                              }
                            } catch (_) {}
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: isThereAnyImage ? 5 : 0,
                            ),
                            child: SetDottedBorderWithHint(
                              height: double.maxFinite,
                              width: isThereAnyImage
                                  ? 100
                                  : MediaQuery.sizeOf(context).width - 35,
                              radius: 7,
                              str: (isThereAnyImage
                                      ? previouslyAddedOtherImages != null &&
                                              previouslyAddedOtherImages!
                                                  .isNotEmpty
                                          ? "changeImages"
                                          : "addImages"
                                      : "chooseImages")
                                  .translate(context: context),
                              strPrefix: '',
                              borderColor:
                                  Theme.of(context).colorScheme.blackColor,
                            ),
                          ),
                        ),
                        if (isThereAnyImage &&
                            pickedOtherImages.value.isNotEmpty)
                          for (int i = 0;
                              i < pickedOtherImages.value.length;
                              i++)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: double.maxFinite,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .blackColor
                                      .withOpacity(0.5),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.file(
                                      File(
                                        pickedOtherImages.value[i],
                                      ),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.topEnd,
                                    child: InkWell(
                                      onTap: () {
                                        pickedOtherImages.value.removeAt(i);
                                        pickedOtherImages.notifyListeners();
                                      },
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        color: Colors.white54,
                                        child: const Center(
                                          child: Icon(
                                            Icons.clear_rounded,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                        if (isThereAnyImage &&
                            previouslyAddedOtherImages != null &&
                            previouslyAddedOtherImages!.isNotEmpty)
                          for (int i = 0;
                              i < previouslyAddedOtherImages!.length;
                              i++)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: double.maxFinite,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .blackColor
                                      .withOpacity(0.5),
                                ),
                              ),
                              child: Center(
                                child: CustomCachedNetworkImage(
                                  imageUrl: previouslyAddedOtherImages![i],
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget form3() {
    return SizedBox(
      height: double.maxFinite,
      child: CustomHTMLEditor(
        controller: htmlController,
        initialHTML: longDescription,
        hint: 'describeCompanyInDetail'.translate(context: context),
      ),
    );
  }

  Widget form6() {
    return Form(
      key: formKey6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              titleText: 'locationInformation'.translate(context: context),
              fontColor: Theme.of(context).colorScheme.blackColor,
            ),
            UiUtils.setDivider(context: context),
            InkWell(
              onTap: () async {
                UiUtils.removeFocus();
                //
                String latitude = latitudeController.text.trim();
                String longitude = longitudeController.text.trim();
                if (latitude == '' && longitude == '') {
                  await GetLocation().requestPermission(
                    onGranted: (Position position) {
                      latitude = position.latitude.toString();
                      longitude = position.longitude.toString();
                    },
                    allowed: (Position position) {
                      latitude = position.latitude.toString();
                      longitude = position.longitude.toString();
                    },
                    onRejected: () {},
                  );
                }
                if (mounted) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (BuildContext context) => GoogleMapScreen(
                        latitude: latitude,
                        longitude: longitude,
                      ),
                    ),
                  ).then((value) {
                    latitudeController.text = value['selectedLatitude'];
                    longitudeController.text = value['selectedLongitude'];
                    addressController.text = value['selectedAddress'];
                    cityController.text = value['selectedCity'];
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15, top: 5),
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.lightGreyColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.my_location_sharp,
                      color: Theme.of(context).colorScheme.accentColor,
                    ),
                    Text(
                      'chooseYourLocation'.translate(context: context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.accentColor,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.accentColor,
                    ),
                  ],
                ),
              ),
            ),
            UiUtils.setTitleAndTFF(
              context,
              titleText: 'cityLbl'.translate(context: context),
              controller: cityController,
              currNode: cityFocus,
              nextFocus: latitudeFocus,
              validator: (String? cityValue) => Validator.nullCheck(cityValue),
            ),
            UiUtils.setTitleAndTFF(
              context,
              titleText: 'latitudeLbl'.translate(context: context),
              controller: latitudeController,
              currNode: latitudeFocus,
              nextFocus: longitudeFocus,
              textInputType: TextInputType.number,
              validator: (String? latitude) =>
                  Validator.validateLatitude(latitude),
              allowOnlySingleDecimalPoint: true,
            ),
            UiUtils.setTitleAndTFF(
              context,
              titleText: 'longitudeLbl'.translate(context: context),
              controller: longitudeController,
              currNode: longitudeFocus,
              nextFocus: addressFocus,
              textInputType: TextInputType.number,
              validator: (String? longitude) =>
                  Validator.validateLongitude(longitude),
              allowOnlySingleDecimalPoint: true,
            ),
            UiUtils.setTitleAndTFF(
              context,
              titleText: 'addressLbl'.translate(context: context),
              controller: addressController,
              currNode: addressFocus,
              textInputType: TextInputType.multiline,
              expands: true,
              minLines: 3,
              validator: (String? addressValue) =>
                  Validator.nullCheck(addressValue),
            ),
          ],
        ),
      ),
    );
  }

  Widget form4() {
    return Form(
      key: formKey4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            titleText: 'workingDaysLbl'.translate(context: context),
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          UiUtils.setDivider(context: context),
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: daysOfWeek.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  setRow(titleTxt: daysOfWeek[index], indexVal: index),
                  if (isChecked[index])
                    setTimerPickerRow(index)
                  else
                    const SizedBox.shrink(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // AAA    form7
  late TextEditingController serviceTitleController = TextEditingController(
    text: widget.service?.title,
  );
  late TextEditingController serviceTagController = TextEditingController();
  late TextEditingController serviceDescrController = TextEditingController(
    text: widget.service?.description,
  );
  late TextEditingController searchController = TextEditingController();
  FocusNode serviceTitleFocus = FocusNode();
  FocusNode serviceDescrFocus = FocusNode();
  FocusNode serviceTagFocus = FocusNode();
  List<Map<String, dynamic>> finalTagList = [];
  List<ServiceCategoryModel> _filteredCategories = [];
  String? selectedCategoryTitle;
  late int selectedCategory = 0;
  bool isCancelAllowed = false;
  FocusNode cancelBeforeFocus = FocusNode();
  late TextEditingController cancelBeforeController = TextEditingController(
    text: widget.service?.cancelableTill,
  );

  Widget minutesPrefixWidget() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              titleText: 'minutesLbl'.translate(context: context),
              fontSize: 15.0,
              fontColor: Theme.of(context).colorScheme.blackColor,
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.blackColor.withAlpha(150),
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  List<String> tagsList = [];
  ListTile listWidget({
    required String title,
    VoidCallback? onTap,
    required bool isSelected,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.blackColor,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      onTap: onTap,
      trailing: //remove int.parse while using model
          Container(
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.blackColor : null,
          border:
              Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
          shape: BoxShape.circle,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.secondaryColor,
              )
            : const SizedBox(
                height: 25,
                width: 25,
              ),
      ),
    );
  }

  Widget form7() {
    return Form(
      key: formKey7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'serviceTitleLbl'.translate(context: context),
            controller: serviceTitleController,
            currNode: serviceTitleFocus,
            validator: (String? value) {
              return Validator.nullCheck(value);
            },
            nextFocus: serviceTagFocus,
          ),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'serviceTagLbl'.translate(context: context),
            controller: serviceTagController,
            currNode: serviceTagFocus,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-z0-9]'))
            ],
            forceUnfocus: false,
            bottomPadding: finalTagList.isEmpty ? 15 : 0,
            onSubmit: () {
              if (serviceTagController.text.isNotEmpty) {
                tagsList.add(serviceTagController.text);
              }
              serviceTagController.text = '';
              setState(() {});
            },
            callback: () {},
          ),
          Wrap(
            children: finalTagList.map(
              (Map<String, dynamic> item) {
                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 0),
                  child: Chip(
                    backgroundColor: Theme.of(context).colorScheme.primaryColor,
                    label: Text(item['text']),
                    onDeleted: () {
                      if (tagsList.isEmpty) {
                        tagsList.clear();
                        finalTagList.clear();
                        setState(() {});
                        return;
                      }
                      tagsList.removeAt(item['id']);
                      if (tagsList.isEmpty) {
                        finalTagList.clear();
                      }
                      setState(() {});
                    },
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          if (tagsList.isNotEmpty) const SizedBox(height: 10),
          UiUtils.setTitleAndTFF(
            context,
            titleText: 'serviceDescrLbl'.translate(context: context),
            controller: serviceDescrController,
            expands: true,
            minLines: 5,
            currNode: serviceDescrFocus,
            validator: (String? value) {
              return Validator.nullCheck(value);
            },
            textInputType: TextInputType.multiline,
          ),
          BlocBuilder<FetchServiceCategoryCubit, FetchServiceCategoryState>(
              builder: (BuildContext context, FetchServiceCategoryState state) {
            if (state is FetchServiceCategoryFailure) {
              return Center(
                child: ErrorContainer(
                  showRetryButton: false,
                  onTapRetry: () {},
                  errorMessage: state.errorMessage.translate(context: context),
                ),
              );
            }
            if (state is FetchServiceCategorySuccess) {
              if (state.serviceCategories.isEmpty) {
                return NoDataContainer(
                  titleKey: 'noDataFound'.translate(context: context),
                );
              }
              return

                  // TypeAheadField(
                  //   builder: (context, controller, focusNode) {
                  //     return

                  SizedBox(
                height: 500,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (String? value) {
                        return Validator.nullCheck(value);
                      },
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          _filteredCategories = state.serviceCategories
                              .where((category) => category.name!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(fontSize: 12),
                        fillColor: Colors.transparent,
                        filled: true,
                        hintText: 'search'.translate(context: context),
                        hintStyle: const TextStyle(color: Colors.grey),
                        // suffixIcon: Icon(
                        //   Icons.keyboard_arrow_down_rounded,
                        //   color: Theme.of(context).colorScheme.blackColor,
                        // ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.redColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.accentColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .blackColor
                                .withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.accentColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    _filteredCategories.isNotEmpty
                        ? Expanded(
                            child: SingleChildScrollView(
                              //clipBehavior: Clip.none,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: kElevationToShadow[2]),
                                child: Column(
                                  children: List.generate(
                                    _filteredCategories.length,
                                    (int index) => listWidget(
                                      title: _filteredCategories[index]
                                          .name!
                                          .toUpperCase(),
                                      isSelected: selectedCategory ==
                                          int.parse(
                                            _filteredCategories[index].id ??
                                                '0',
                                          ),
                                      onTap: () {
                                        selectedCategory = int.parse(
                                          _filteredCategories[index].id!,
                                        ); //pass complete Category model instead of id

                                        selectedCategoryTitle =
                                            _filteredCategories[index].name;
                                        searchController.text =
                                            _filteredCategories[index].name!;
                                        setState(() {});

                                        setState(() {
                                          _filteredCategories = state
                                              .serviceCategories
                                              .where((category) => category
                                                  .name!
                                                  .toLowerCase()
                                                  .contains(
                                                      _filteredCategories[index]
                                                          .name!
                                                          .toLowerCase()))
                                              .toList();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.whiteColors,
              ),
            );
          }),
          SizedBox(
            height: 400.rh(context),
          ),
          // setTitleAndSwitch(
          //   titleText: 'payLaterAllowedLbl'.translate(context: context),
          //   isAllowed: isPayLaterAllowed,
          // ),
          // if (context.read<FetchSystemSettingsCubit>().isStoreOptionAvailable())
          //   setTitleAndSwitch(
          //     titleText: 'atStoreAllowed'.translate(context: context),
          //     isAllowed: isStoreAllowed,
          //   ),
          // if (context.read<FetchSystemSettingsCubit>().isDoorstepOptionAvailable())
          //   setTitleAndSwitch(
          //     titleText: 'atDoorstepAllowed'.translate(context: context),
          //     isAllowed: isDoorStepAllowed,
          //   ),
          // SizedBox(
          //   height: 10.rh(context),
          // ),
          // setTitleAndSwitch(
          //   titleText: 'statusLbl'.translate(context: context),
          //   isAllowed: serviceStatus,
          // ),
          // SizedBox(
          //   height: 10.rh(context),
          // ),
          // setTitleAndSwitch(
          //   titleText: 'isCancelableLbl'.translate(context: context),
          //   isAllowed: isCancelAllowed,
          // ),
          if (isCancelAllowed) ...[
            const SizedBox(height: 10),
            UiUtils.setTitleAndTFF(
              context,
              titleText: 'cancelableBeforeLbl'.translate(context: context),
              controller: cancelBeforeController,
              currNode: cancelBeforeFocus,
              textInputType: TextInputType.number,
              inputFormatters: UiUtils.allowOnlyDigits(),
              hintText: '30',
              validator: (String? value) {
                return Validator.nullCheck(value);
              },
              prefix: minutesPrefixWidget(),
            )
          ]
        ],
      ),
    );
  }

  //AAA form8

  FocusNode discountPriceFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  late TextEditingController priceController =
      TextEditingController(text: widget.service?.price);

  String selectedTaxTitle = '';
  Map? selectedPriceType;
  late int selectedTax = 0;

  Future<void> selectTaxOption() async {
    final Map? result = await showDialog<Map>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialogs.showSelectDialoge(
          selectedValue: selectedPriceType?['value'],
          itemList: <Map>[
            {'title': 'taxIncluded'.translate(context: context), 'value': '0'},
            {'title': 'taxExcluded'.translate(context: context), 'value': '1'}
          ],
        );
      },
    );
    selectedPriceType = result;
    setState(() {});
  }

  Widget _selectDropdown({
    required String title,
    VoidCallback? onSelect,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      readOnly: true,
      validator: validator,
      onTap: onSelect,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.blackColor,
      ),
      controller: TextEditingController(
        text: title,
      ),
      decoration: InputDecoration(
        errorStyle: const TextStyle(fontSize: 12),
        fillColor: Colors.transparent,
        filled: true,
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Theme.of(context).colorScheme.blackColor,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.redColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.accentColor),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.blackColor.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.accentColor),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future selectTaxesBottomSheet() {
    return UiUtils.showModelBottomSheets(
      context: context,
      enableDrag: true,
      child: BlocBuilder<FetchTaxesCubit, FetchTaxesState>(
        builder: (BuildContext context, FetchTaxesState state) {
          if (state is FetchTaxesFailure) {
            return Center(
              child: ErrorContainer(
                showRetryButton: false,
                onTapRetry: () {},
                errorMessage: state.errorMessage,
              ),
            );
          }
          if (state is FetchTaxesSuccess) {
            if (state.taxes.isEmpty) {
              return NoDataContainer(
                titleKey: 'noDataFound'.translate(context: context),
              );
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.75,
                minHeight: MediaQuery.sizeOf(context).height * 0.6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      'chooseTaxes'.translate(context: context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          state.taxes.length,
                          (int index) {
                            return listWidget(
                              title:
                                  '${state.taxes[index].title!.toUpperCase()} (${state.taxes[index].percentage}%)',
                              isSelected: selectedTax ==
                                  int.parse(state.taxes[index].id ?? '0'),
                              onTap: () {
                                selectedTax = int.parse(
                                  state.taxes[index].id!,
                                ); //pass complete Category model instead of id
                                selectedTaxTitle =
                                    '${state.taxes[index].title} (${state.taxes[index].percentage}%)';
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.whiteColors,
            ),
          );
        },
      ),
    );
  }

  Widget setPriceAndDicountedPrice() {
    return Row(
      children: [
        Flexible(
          child: UiUtils.setTitleAndTFF(
            context,
            titleText: 'priceLbl'.translate(context: context),
            allowOnlySingleDecimalPoint: true,
            controller: priceController,
            currNode: priceFocus,
            prefix: Padding(
              padding: const EdgeInsetsDirectional.only(start: 15, end: 15),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      titleText: Constant.systemCurrency ?? '',
                      fontSize: 15.0,
                      fontColor: Theme.of(context).colorScheme.blackColor,
                    ),
                    VerticalDivider(
                      color: Theme.of(context)
                          .colorScheme
                          .blackColor
                          .withAlpha(150),
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            ),
            nextFocus: discountPriceFocus,
            validator: (String? value) {
              return Validator.nullCheck(value);
            },
            textInputType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget form8() {
    return Form(
      key: formKey8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CustomText(
          //   titleText: 'serviceImgLbl'.translate(context: context),
          //   fontColor: Theme.of(context).colorScheme.blackColor,
          // ),
          // const SizedBox(height: 10),
          // imagePicker.ListenImageChange(
          //   (BuildContext context, image) {
          //     if (image == null) {
          //       if (pickedServiceImage != '') {
          //         return GestureDetector(
          //           onTap: () {
          //             showCameraAndGalleryOption(
          //               imageController: imagePicker,
          //               title: 'serviceImgLbl'.translate(context: context),
          //             );
          //           },
          //           child: Stack(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.all(3.0),
          //                 child: SizedBox(
          //                   height: 200,
          //                   width: MediaQuery.sizeOf(context).width,
          //                   child: Image.file(
          //                     File(pickedServiceImage),
          //                   ),
          //                 ),
          //               ),
          //               SizedBox(
          //                 height: 210,
          //                 width: (MediaQuery.sizeOf(context).width - 5) + 5,
          //                 child: DashedRect(
          //                   color: Theme.of(context).colorScheme.blackColor,
          //                   strokeWidth: 2.0,
          //                   gap: 4.0,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         );
          //       }
          //       if (widget.service?.imageOfTheService != null) {
          //         return GestureDetector(
          //           onTap: () {
          //             showCameraAndGalleryOption(
          //               imageController: imagePicker,
          //               title: 'serviceImgLbl'.translate(context: context),
          //             );
          //           },
          //           child: Stack(
          //             children: [
          //               SizedBox(
          //                 height: 210,
          //                 width: MediaQuery.sizeOf(context).width,
          //                 child: DashedRect(
          //                   color: Theme.of(context).colorScheme.blackColor,
          //                   strokeWidth: 2.0,
          //                   gap: 4.0,
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.all(3.0),
          //                 child: SizedBox(
          //                   height: 200,
          //                   width: (MediaQuery.sizeOf(context).width) - 5.0,
          //                   child: CustomCachedNetworkImage(
          //                     imageUrl: widget.service?.imageOfTheService ?? '',
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         );
          //       }

          //       return Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 5),
          //         child: InkWell(
          //           onTap: () {
          //             showCameraAndGalleryOption(
          //               imageController: imagePicker,
          //               title: 'serviceImgLbl'.translate(context: context),
          //             );
          //           },
          //           child: SetDottedBorderWithHint(
          //             height: 100,
          //             width: MediaQuery.sizeOf(context).width - 35,
          //             radius: 7,
          //             str: 'chooseImgLbl'.translate(context: context),
          //             strPrefix: '',
          //             borderColor: Theme.of(context).colorScheme.blackColor,
          //           ),
          //         ),
          //       );
          //     }
          //     //
          //     pickedServiceImage = image?.path;
          //     //
          //     return GestureDetector(
          //       onTap: () {
          //         showCameraAndGalleryOption(
          //           imageController: imagePicker,
          //           title: 'serviceImgLbl'.translate(context: context),
          //         );
          //       },
          //       child: Stack(
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.all(3.0),
          //             child: SizedBox(
          //               height: 200,
          //               width: MediaQuery.sizeOf(context).width,
          //               child: Image.file(
          //                 File(image.path),
          //               ),
          //             ),
          //           ),
          //           SizedBox(
          //             height: 210,
          //             width: (MediaQuery.sizeOf(context).width - 5) + 5,
          //             child: DashedRect(
          //               color: Theme.of(context).colorScheme.blackColor,
          //               strokeWidth: 2.0,
          //               gap: 4.0,
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
          // const SizedBox(height: 15),
          // CustomText(
          //   titleText: 'otherImages'.translate(context: context),
          //   fontColor: Theme.of(context).colorScheme.blackColor,
          // ),
          const SizedBox(height: 5),
          //other image picker builder
          // ValueListenableBuilder(
          //   valueListenable: pickedOtherImages,
          //   builder: (BuildContext context, Object? value, Widget? child) {
          //     final bool isThereAnyImage = pickedOtherImages.value.isNotEmpty ||
          //         (widget.service != null &&
          //             widget.service!.otherImages != null &&
          //             widget.service!.otherImages!.isNotEmpty);
          //     return Padding(
          //       padding: const EdgeInsets.symmetric(vertical: 5),
          //       child: SizedBox(
          //         height: isThereAnyImage ? 150 : 100,
          //         width: double.maxFinite,
          //         child: SingleChildScrollView(
          //           scrollDirection: Axis.horizontal,
          //           child: Row(
          //             children: [
          //               InkWell(
          //                 onTap: () async {
          //                   try {
          //                     final FilePickerResult? result =
          //                         await FilePicker.platform.pickFiles(
          //                       allowMultiple: true,
          //                       type: FileType.image,
          //                     );
          //                     if (result != null) {
          //                       if (widget.service != null &&
          //                           widget.service!.otherImages!.isNotEmpty) {
          //                         widget.service!.otherImages = null;
          //                       }
          //                       for (int i = 0; i < result.files.length; i++) {
          //                         if (!pickedOtherImages.value
          //                             .contains(result.files[i].path)) {
          //                           pickedOtherImages.value
          //                               .insert(0, result.files[i].path!);
          //                         }
          //                       }
          //                       pickedOtherImages.notifyListeners();
          //                     } else {
          //                       // User canceled the picker
          //                     }
          //                   } catch (_) {}
          //                 },
          //                 child: Padding(
          //                   padding: EdgeInsets.only(
          //                     right: isThereAnyImage ? 5 : 0,
          //                   ),
          //                   child: SetDottedBorderWithHint(
          //                     height: double.maxFinite,
          //                     width: isThereAnyImage
          //                         ? 100
          //                         : MediaQuery.sizeOf(context).width - 35,
          //                     radius: 7,
          //                     str: (isThereAnyImage
          //                             ? widget.service != null &&
          //                                     widget.service!.otherImages !=
          //                                         null &&
          //                                     widget.service!.otherImages!
          //                                         .isNotEmpty
          //                                 ? "changeImages"
          //                                 : "addImages"
          //                             : "chooseImages")
          //                         .translate(context: context),
          //                     strPrefix: '',
          //                     borderColor:
          //                         Theme.of(context).colorScheme.blackColor,
          //                   ),
          //                 ),
          //               ),
          //               if (isThereAnyImage &&
          //                   pickedOtherImages.value.isNotEmpty)
          //                 for (int i = 0;
          //                     i < pickedOtherImages.value.length;
          //                     i++)
          //                   Container(
          //                     margin: const EdgeInsets.symmetric(horizontal: 5),
          //                     height: double.maxFinite,
          //                     decoration: BoxDecoration(
          //                       border: Border.all(
          //                         color: Theme.of(context)
          //                             .colorScheme
          //                             .blackColor
          //                             .withOpacity(0.5),
          //                       ),
          //                     ),
          //                     child: Stack(
          //                       children: [
          //                         Center(
          //                           child: Image.file(
          //                             File(
          //                               pickedOtherImages.value[i],
          //                             ),
          //                             fit: BoxFit.fitHeight,
          //                           ),
          //                         ),
          //                         Align(
          //                           alignment: AlignmentDirectional.topEnd,
          //                           child: InkWell(
          //                             onTap: () {
          //                               pickedOtherImages.value.removeAt(i);
          //                               pickedOtherImages.notifyListeners();
          //                             },
          //                             child: Container(
          //                               height: 20,
          //                               width: 20,
          //                               color: Colors.white54,
          //                               child: const Center(
          //                                 child: Icon(
          //                                   Icons.clear_rounded,
          //                                   size: 15,
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                         )
          //                       ],
          //                     ),
          //                   ),
          //               if (isThereAnyImage &&
          //                   widget.service != null &&
          //                   widget.service!.otherImages != null &&
          //                   widget.service!.otherImages!.isNotEmpty)
          //                 for (int i = 0;
          //                     i < widget.service!.otherImages!.length;
          //                     i++)
          //                   Container(
          //                     margin: const EdgeInsets.symmetric(horizontal: 5),
          //                     height: double.maxFinite,
          //                     decoration: BoxDecoration(
          //                       border: Border.all(
          //                         color: Theme.of(context)
          //                             .colorScheme
          //                             .blackColor
          //                             .withOpacity(0.5),
          //                       ),
          //                     ),
          //                     child: Center(
          //                       child: CustomCachedNetworkImage(
          //                         imageUrl: widget.service!.otherImages![i],
          //                         fit: BoxFit.fitHeight,
          //                       ),
          //                     ),
          //                   ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          // ),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     CustomText(
          //       titleText: 'files'.translate(context: context),
          //       fontColor: Theme.of(context).colorScheme.blackColor,
          //     ),
          //     CustomText(
          //       titleText: " ${'onlyPdfAndDocAllowed'.translate(context: context)}",
          //       fontColor: Theme.of(context).colorScheme.blackColor,
          //       fontSize: 12,
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 5),
          // //other image picker builder
          // ValueListenableBuilder(
          //   valueListenable: pickedFiles,
          //   builder: (BuildContext context, Object? value, Widget? child) {
          //     final bool isThereAnyFile = pickedFiles.value.isNotEmpty ||
          //         (widget.service != null && widget.service!.files != null && widget.service!.files!.isNotEmpty);
          //     return Padding(
          //       padding: const EdgeInsets.symmetric(vertical: 5),
          //       child: SizedBox(
          //         height: 100,
          //         width: double.maxFinite,
          //         child: SingleChildScrollView(
          //           scrollDirection: Axis.horizontal,
          //           child: Row(
          //             children: [
          //               InkWell(
          //                 onTap: () async {
          //                   try {
          //                     final FilePickerResult? result = await FilePicker.platform.pickFiles(
          //                       allowMultiple: true,
          //                       type: FileType.custom,
          //                       allowedExtensions: ['pdf', 'doc', 'docx', 'docm'],
          //                     );
          //                     if (result != null) {
          //                       if (widget.service != null && widget.service!.files!.isNotEmpty) {
          //                         widget.service!.files = null;
          //                       }
          //                       for (int i = 0; i < result.files.length; i++) {
          //                         if (!pickedFiles.value.contains(result.files[i].path)) {
          //                           pickedFiles.value.insert(0, result.files[i].path!);
          //                         }
          //                       }
          //                       pickedFiles.notifyListeners();
          //                     } else {
          //                       // User canceled the picker
          //                     }
          //                   } catch (_) {}
          //                 },
          //                 child: Padding(
          //                   padding: EdgeInsets.only(
          //                     right: isThereAnyFile ? 5 : 0,
          //                   ),
          //                   child: SetDottedBorderWithHint(
          //                     height: double.maxFinite,
          //                     customIconWidget: Icon(
          //                       Icons.file_open_outlined,
          //                       color: Theme.of(context).colorScheme.lightGreyColor,
          //                       size: 20,
          //                     ),
          //                     width: isThereAnyFile ? 100 : MediaQuery.sizeOf(context).width - 35,
          //                     radius: 7,
          //                     str:
          //                         "${(isThereAnyFile ? widget.service != null && widget.service!.files != null && widget.service!.files!.isNotEmpty ? "changeFiles" : "addFiles" : "pickFiles").translate(context: context)}  ",
          //                     strPrefix: '',
          //                     borderColor: Theme.of(context).colorScheme.blackColor,
          //                   ),
          //                 ),
          //               ),
          //               if (isThereAnyFile && pickedFiles.value.isNotEmpty)
          //                 for (int i = 0; i < pickedFiles.value.length; i++)
          //                   Container(
          //                     margin: const EdgeInsets.symmetric(horizontal: 5),
          //                     height: double.maxFinite,
          //                     decoration: BoxDecoration(
          //                       border: Border.all(
          //                         color: Theme.of(context).colorScheme.blackColor.withOpacity(0.5),
          //                       ),
          //                     ),
          //                     child: Stack(
          //                       children: [
          //                         Center(
          //                           child: _fileContainer(
          //                             filePath: pickedFiles.value[i],
          //                           ),
          //                         ),
          //                         Align(
          //                           alignment: AlignmentDirectional.topEnd,
          //                           child: InkWell(
          //                             onTap: () {
          //                               pickedFiles.value.removeAt(i);
          //                               pickedFiles.notifyListeners();
          //                             },
          //                             child: Container(
          //                               height: 20,
          //                               width: 20,
          //                               color: Colors.white54,
          //                               child: const Center(
          //                                 child: Icon(
          //                                   Icons.clear_rounded,
          //                                   size: 15,
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                         )
          //                       ],
          //                     ),
          //                   ),
          //               if (isThereAnyFile && widget.service != null && widget.service!.files != null && widget.service!.files!.isNotEmpty)
          //                 for (int i = 0; i < widget.service!.files!.length; i++)
          //                   Container(
          //                     margin: const EdgeInsets.symmetric(horizontal: 5),
          //                     height: double.maxFinite,
          //                     decoration: BoxDecoration(
          //                       border: Border.all(
          //                         color: Theme.of(context).colorScheme.blackColor.withOpacity(0.5),
          //                       ),
          //                     ),
          //                     child: Center(
          //                       child: _fileContainer(
          //                         filePath: widget.service!.files![i],
          //                         isNetwork: true,
          //                       ),
          //                     ),
          //                   ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          // ),
          const SizedBox(height: 15),
          buildDropDown(
            context,
            title: 'priceType'.translate(context: context),
            initialValue: widget.service?.taxType?.firstUpperCase() ??
                'select'.translate(context: context),
            onTap: () {
              selectTaxOption();
            },
            value: selectedPriceType?['title'],
          ),
          const SizedBox(height: 15),
          _selectDropdown(
            title: selectedTaxTitle == ''
                ? 'selectTax'.translate(context: context)
                : selectedTaxTitle,
            onSelect: () {
              selectTaxesBottomSheet();
            },
            validator: (String? value) {
              if (selectedTaxTitle == '') {
                return 'pleaseSelectTax'.translate(context: context);
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          setPriceAndDicountedPrice(),
          // UiUtils.setTitleAndTFF(
          //   context,
          //   titleText: 'membersForTaskLbl'.translate(context: context),
          //   controller: memReqTaskController,
          //   currNode: memReqTaskFocus,
          //   inputFormatters: UiUtils.allowOnlyDigits(),
          //   nextFocus: durationTaskFocus,
          //   validator: (String? value) {
          //     return Validator.nullCheck(value);
          //   },
          //   textInputType: TextInputType.number,
          // ),
          // UiUtils.setTitleAndTFF(
          //   context,
          //   titleText: 'durationForTaskLbl'.translate(context: context),
          //   controller: durationTaskController,
          //   currNode: durationTaskFocus,
          //   nextFocus: qtyAllowedTaskFocus,
          //   inputFormatters: UiUtils.allowOnlyDigits(),
          //   hintText: '120',
          //   validator: (String? value) {
          //     return Validator.nullCheck(value);
          //   },
          //   prefix: minutesPrefixWidget(),
          //   textInputType: TextInputType.number,
          // ),
          // UiUtils.setTitleAndTFF(
          //   context,
          //   titleText: 'maxQtyAllowedLbl'.translate(context: context),
          //   controller: qtyAllowedTaskController,
          //   inputFormatters: UiUtils.allowOnlyDigits(),
          //   currNode: qtyAllowedTaskFocus,
          //   validator: (String? value) {
          //     return Validator.nullCheck(value);
          //   },
          //   textInputType: TextInputType.number,
          // ),
        ],
      ),
    );
  }

  bool showUpiFields = false;
  bool showBankDetailsFields = false;
  bool upiButtonSelected = false;
  bool bankDetailsButtonSelected = false;

  Widget form5() {
    return Form(
      key: formKey5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            titleText: "Choose Payment Method",
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
          UiUtils.setDivider(context: context),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    upiButtonSelected = true;
                    bankDetailsButtonSelected = false;
                    showUpiFields = true;
                    showBankDetailsFields = false;
                    bankNameController.clear();
                    bankCodeController.clear();
                    accountNameController.clear();
                    accountNumberController.clear();
                    taxNameController.clear();
                    taxNumberController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: upiButtonSelected ? Colors.lightBlue : Colors.white,
                  onPrimary: Colors.black,
                  side: BorderSide(color: Colors.black),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'upi'.translate(context: context),
                  style: TextStyle(
                      color: upiButtonSelected ? Colors.white : Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text("OR"),
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    upiButtonSelected = false;
                    bankDetailsButtonSelected = true;
                    showUpiFields = false;
                    showBankDetailsFields = true;
                    upiController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: bankDetailsButtonSelected
                      ? Colors.lightBlue
                      : Colors.white,
                  onPrimary: Colors.black,
                  side: BorderSide(color: Colors.black),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'bankDetailsLbl'.translate(context: context),
                  style: TextStyle(
                      color: bankDetailsButtonSelected
                          ? Colors.white
                          : Colors.black),
                ),
              ),
            ),
          ),
          if (showUpiFields) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CustomText(
                    titleText: "UPI",
                    fontColor: Theme.of(context).colorScheme.blackColor,
                  ),
                ),
                UiUtils.setDivider(context: context),
                const SizedBox(height: 5),
                UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'upi'.translate(context: context),
                  controller: upiController,
                  currNode: upiFocus,
                  validator: (String? cityValue) =>
                      Validator.nullCheck(cityValue),
                ),
              ],
            ),
          ],
          if (showBankDetailsFields) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                    titleText: "Bank Details",
                    fontColor: Theme.of(context).colorScheme.blackColor,
                  ),
                ),
                UiUtils.setDivider(context: context),
                const SizedBox(height: 10),
                UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'bankNmLbl'.translate(context: context),
                  controller: bankNameController,
                  currNode: bankNameFocus,
                  nextFocus: bankCodeFocus,
                  validator: (String? cityValue) =>
                      Validator.nullCheck(cityValue),
                ),
                UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'bankCodeLbl'.translate(context: context),
                  controller: bankCodeController,
                  currNode: bankCodeFocus,
                  nextFocus: accountNameFocus,
                  validator: (String? cityValue) =>
                      Validator.nullCheck(cityValue),
                ),
                UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'accountName'.translate(context: context),
                  controller: accountNameController,
                  currNode: accountNameFocus,
                  nextFocus: accountNumberFocus,
                  validator: (String? mobileNumber) =>
                      Validator.nullCheck(mobileNumber),
                ),
                UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'accNumLbl'.translate(context: context),
                  controller: accountNumberController,
                  currNode: accountNumberFocus,
                  nextFocus: taxNameFocus,
                  textInputType: TextInputType.phone,
                  validator: (String? cityValue) =>
                      Validator.nullCheck(cityValue),
                ),
                UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'taxName'.translate(context: context),
                  controller: taxNameController,
                  currNode: taxNameFocus,
                  nextFocus: taxNumberFocus,
                  validator: (String? mobileNumber) =>
                      Validator.nullCheck(mobileNumber),
                ),
                UiUtils.setTitleAndTFF(
                  context,
                  titleText: 'taxNumber'.translate(context: context),
                  controller: taxNumberController,
                  currNode: taxNumberFocus,
                  nextFocus: upiFocus,
                  validator: (String? cityValue) =>
                      Validator.nullCheck(cityValue),
                  textInputType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget setRow({required String titleTxt, required int indexVal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              titleText: titleTxt,
              fontColor: Theme.of(context).colorScheme.blackColor,
            ),
          ),
          // CustomText(titleText: "openLbl".translate(context: context)),
          const Spacer(),
          SizedBox(
            height: 24,
            width: 24,
            child: CheckBox(
              isChecked: isChecked,
              indexVal: indexVal,
              onChanged: (bool? checked) {
                setState(
                  () {
                    pickedLocalImages = pickedLocalImages;
                    isChecked[indexVal] = checked!;
                    // show/hide timePicker
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget setTimerPickerRow(int indexVal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomRoundedButton(
          backgroundColor: Colors.transparent,
          widthPercentage: 0.3,
          // format time as AM/PM
          buttonTitle: DateFormat.jm().format(
            DateTime.parse(
              "2020-07-20T${selectedStartTime[indexVal].hour.toString().padLeft(2, "0")}:${selectedStartTime[indexVal].minute.toString().padLeft(2, "0")}:00",
            ),
          ),
          showBorder: true,
          borderColor: Theme.of(context).colorScheme.lightGreyColor,
          height: 43,
          textSize: 16,
          titleColor: Theme.of(context).colorScheme.blackColor,
          onTap: () {
            _selectTime(
              selectedTime: selectedStartTime[indexVal],
              indexVal: indexVal,
              isTimePickerForStarTime: true,
            );
          },
        ),
        CustomText(
          titleText: 'toLbl'.translate(context: context),
          fontColor: Theme.of(context).colorScheme.lightGreyColor,
          fontWeight: FontWeight.w400,
        ),
        CustomRoundedButton(
          backgroundColor: Colors.transparent,
          widthPercentage: 0.3,
          buttonTitle:
              "${DateFormat.jm().format(DateTime.parse("2020-07-20T${selectedEndTime[indexVal].hour.toString().padLeft(2, "0")}:${selectedEndTime[indexVal].minute.toString().padLeft(2, "0")}:00"))} ",
          showBorder: true,
          borderColor: Theme.of(context).colorScheme.lightGreyColor,
          height: 43,
          textSize: 16,
          titleColor: Theme.of(context).colorScheme.blackColor,
          onTap: () {
            _selectTime(
              selectedTime: selectedEndTime[indexVal],
              indexVal: indexVal,
              isTimePickerForStarTime: false,
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectTime({
    required TimeOfDay selectedTime,
    required int indexVal,
    required bool isTimePickerForStarTime,
  }) async {
    try {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime, //TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            //To use 12 hours
            child: child!,
          );
        },
      );
      //

      if (isTimePickerForStarTime) {
        //
        final bool isStartTimeBeforeOfEndTime = timeOfDay!.hour <=
                (selectedEndTime[indexVal].hour == 00
                    ? 24
                    : selectedEndTime[indexVal].hour) &&
            timeOfDay.minute <= selectedEndTime[indexVal].minute;
        //
        if (isStartTimeBeforeOfEndTime) {
          selectedStartTime[indexVal] = timeOfDay;
        } else if (mounted) {
          UiUtils.showMessage(
            context,
            'companyStartTimeCanNotBeAfterOfEndTime'
                .translate(context: context),
            MessageType.warning,
          );
        }
      } else {
        //
        final bool isEndTimeAfterOfStartTime = timeOfDay!.hour >=
                (selectedStartTime[indexVal].hour == 00
                    ? 24
                    : selectedStartTime[indexVal].hour) &&
            timeOfDay.minute >= selectedStartTime[indexVal].minute;
        //
        if (isEndTimeAfterOfStartTime) {
          selectedEndTime[indexVal] = timeOfDay;
        } else {
          if (mounted) {
            UiUtils.showMessage(
              context,
              'companyEndTimeCanNotBeBeforeOfStartTime'
                  .translate(context: context),
              MessageType.warning,
            );
          }
        }
      }
    } catch (_) {}

    setState(() {
      pickedLocalImages = pickedLocalImages;
    });
  }

  Widget idImageWidget({
    required String titleTxt,
    required String imageHintText,
    required PickImage imageController,
    required String imageType,
    required String oldImage,
  }) {
    return Column(
      children: [
        CustomText(
          titleText: titleTxt,
        ),
        const SizedBox(height: 5),
        imagePicker(
          imageType: imageType,
          imageController: imageController,
          oldImage: oldImage,
          hintLabel: imageHintText,
          width: 100,
        ),
      ],
    );
  }

  Widget imagePicker({
    required PickImage imageController,
    required String oldImage,
    required String hintLabel,
    required String imageType,
    double? width,
  }) {
    return imageController.ListenImageChange(
      (BuildContext context, image) {
        if (image == null) {
          if (pickedLocalImages[imageType] != '') {
            return GestureDetector(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                );
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: SizedBox(
                      height: 200,
                      width: width ?? MediaQuery.sizeOf(context).width,
                      child: Image.file(
                        File(pickedLocalImages[imageType]!),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 210,
                    width: (width ?? MediaQuery.sizeOf(context).width - 5) + 5,
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
          if (oldImage.isNotEmpty) {
            return GestureDetector(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                );
              },
              child: Stack(
                children: [
                  SizedBox(
                    height: 210,
                    width: width ?? MediaQuery.sizeOf(context).width,
                    child: DashedRect(
                      color: Theme.of(context).colorScheme.blackColor,
                      strokeWidth: 2.0,
                      gap: 4.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: SizedBox(
                      height: 200,
                      width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
                      child: CustomCachedNetworkImage(imageUrl: oldImage),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: InkWell(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                );
              },
              child: SetDottedBorderWithHint(
                height: 100,
                width: width ?? MediaQuery.sizeOf(context).width - 35,
                radius: 7,
                str: hintLabel,
                strPrefix: '',
                borderColor: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          );
        }
        //
        pickedLocalImages[imageType] = image?.path;
        //
        return GestureDetector(
          onTap: () {
            showCameraAndGalleryOption(
              imageController: imageController,
              title: hintLabel,
            );
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: SizedBox(
                  height: 200,
                  width: width ?? MediaQuery.sizeOf(context).width,
                  child: Image.file(
                    File(image.path),
                  ),
                ),
              ),
              SizedBox(
                height: 210,
                width: (width ?? MediaQuery.sizeOf(context).width - 5) + 5,
                child: DashedRect(
                  color: Theme.of(context).colorScheme.blackColor,
                  strokeWidth: 2.0,
                  gap: 4.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDropDown(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    required String initialValue,
    String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          fontColor: Theme.of(context).colorScheme.blackColor,
          titleText: title,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomFormDropdown(
          onTap: () {
            onTap.call();
          },
          initialTitle: initialValue,
          selectedValue: value,
          validator: (String? p0) {
            return Validator.nullCheck(p0);
          },
        ),
      ],
    );
  }

  Future showCameraAndGalleryOption({
    required PickImage imageController,
    required String title,
  }) {
    return UiUtils.showModelBottomSheets(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      context: context,
      child: ShowImagePickerOptionBottomSheet(
        title: title,
        onCameraButtonClick: () {
          imageController.pick(source: ImageSource.camera);
        },
        onGalleryButtonClick: () {
          imageController.pick(source: ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> selectCompanyTypes() async {
    final Map? result = await showDialog<Map>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialogs.showSelectDialoge(
          selectedValue: selectCompanyType?['value'],
          itemList: <Map>[
            {'title': 'Individual'.translate(context: context), 'value': '0'},
            {'title': 'Organisation'.translate(context: context), 'value': '1'}
          ],
        );
      },
    );
    selectCompanyType = result;

    if (result?['title'] == 'Individual') {
      numberOfMemberController.text = '1';
      isIndividualType = true;
    } else {
      isIndividualType = false;
    }
    setState(() {
      pickedLocalImages = pickedLocalImages;
    });
  }
}
