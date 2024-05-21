import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:open_filex/open_filex.dart';
import '../../../app/generalImports.dart';
import '../../widgets/bottomSheets/showImagePickerOptionBottomSheet.dart';

class CreateService extends StatefulWidget {
  const CreateService({
    super.key,
    this.service,
  });

  final ServiceModel? service;

  @override
  CreateServiceState createState() => CreateServiceState();

  static Route<CreateService> route(RouteSettings routeSettings) {
    final Map? arguments = routeSettings.arguments as Map?;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => CreateServiceCubit(),
        child: CreateService(service: arguments?['service']),
      ),
    );
  }
}

class CreateServiceState extends State<CreateService> with ChangeNotifier {
  int currIndex = 1;
  int totalForms = 2;

  //form 1
  bool isOnSiteAllowed = false;
  bool isPayLaterAllowed = false;
  bool isCancelAllowed = false;
  bool isDoorStepAllowed = false;
  bool isStoreAllowed = false;
  bool serviceStatus = true;

  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();

  late TextEditingController serviceTitleController = TextEditingController(
    text: widget.service?.title,
  );
  late TextEditingController serviceTagController = TextEditingController();
  late TextEditingController searchController = TextEditingController();
  late TextEditingController serviceDescrController = TextEditingController(
    text: widget.service?.description,
  );

  List<ServiceCategoryModel> _filteredCategories = [];

  // TextEditingController chooseCatController = TextEditingController();
  // TextEditingController chooseSubcatController = TextEditingController();
  late TextEditingController cancelBeforeController = TextEditingController(
    text: widget.service?.cancelableTill,
  );
  FocusNode serviceTitleFocus = FocusNode();
  FocusNode serviceTagFocus = FocusNode();
  FocusNode serviceDescrFocus = FocusNode();
  FocusNode cancelBeforeFocus = FocusNode();

  late int selectedCategory = 0; // Category = name of model instead of int
  String? selectedCategoryTitle;
  late int selectedTax = 0; // Tax = name of model instead of int
  String selectedTaxTitle = '';
  late int selectedSubCategory = 0; //Subcategory = name of model instead of int
  Map? selectedPriceType;

  //form 2
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  late TextEditingController priceController =
      TextEditingController(text: widget.service?.price);
  late TextEditingController discountPriceController =
      TextEditingController(text: widget.service?.discountedPrice);
  late TextEditingController memReqTaskController =
      TextEditingController(text: widget.service?.numberOfMembersRequired);
  late TextEditingController durationTaskController =
      TextEditingController(text: widget.service?.duration);
  late TextEditingController qtyAllowedTaskController =
      TextEditingController(text: widget.service?.maxQuantityAllowed);

  FocusNode priceFocus = FocusNode();
  FocusNode discountPriceFocus = FocusNode();
  FocusNode memReqTaskFocus = FocusNode();
  FocusNode durationTaskFocus = FocusNode();
  FocusNode qtyAllowedTaskFocus = FocusNode();

  List<String> tagsList = [];
  List<Map<String, dynamic>> finalTagList = [];
  PickImage imagePicker = PickImage();

  Map priceTypeFilter = {'0': 'included', '1': 'excluded'};
  String pickedServiceImage = '';
  ValueNotifier<List<String>> pickedOtherImages = ValueNotifier([]);
  ValueNotifier<List<String>> pickedFiles = ValueNotifier([]);
  bool fileTapLoading = false;

  final GlobalKey<FormState> formKey3 = GlobalKey<FormState>();
  ValueNotifier<List<TextEditingController>> faqQuestionTextEditors =
      ValueNotifier([]);
  ValueNotifier<List<TextEditingController>> faqAnswersTextEditors =
      ValueNotifier([]);

  final HtmlEditorController controller = HtmlEditorController();
  String? longDescription;

  @override
  void dispose() {
    pickedOtherImages.dispose();
    pickedFiles.dispose();
    faqAnswersTextEditors.dispose();
    faqQuestionTextEditors.dispose();
    serviceTitleController.dispose();
    serviceTagController.dispose();
    serviceDescrController.dispose();
    cancelBeforeController.dispose();
    serviceTitleFocus.dispose();
    serviceTagFocus.dispose();
    serviceDescrFocus.dispose();
    cancelBeforeFocus.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    memReqTaskController.dispose();
    durationTaskController.dispose();
    qtyAllowedTaskController.dispose();
    priceFocus.dispose();
    discountPriceFocus.dispose();
    memReqTaskFocus.dispose();
    durationTaskFocus.dispose();
    qtyAllowedTaskFocus.dispose();
    searchController.dispose();

    super.dispose();
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

  @override
  void initState() {
    super.initState();

    selectedCategory = int.parse(widget.service?.categoryId ?? '0');
    selectedCategoryTitle = widget.service?.categoryName;

    selectedTax = int.parse(widget.service?.taxId ?? '0');
    selectedTaxTitle = widget.service?.taxId == null
        ? ''
        : '${widget.service?.taxTitle} (${widget.service?.taxPercentage}%)';

    if (widget.service?.isCancelable != null) {
      isCancelAllowed = widget.service?.isCancelable == '0' ? false : true;
    }
    if (widget.service?.isPayLaterAllowed != null) {
      isPayLaterAllowed =
          widget.service?.isPayLaterAllowed == '0' ? false : true;
    }

    if (widget.service?.isDoorStepAllowed != null) {
      isDoorStepAllowed =
          widget.service?.isDoorStepAllowed == '0' ? false : true;
    }
    if (widget.service?.isStoreAllowed != null) {
      isStoreAllowed = widget.service?.isStoreAllowed == '0' ? false : true;
    }
    if (widget.service?.status != null || widget.service?.status != "") {
      serviceStatus = widget.service?.status == "Disable" ? false : true;
    }

    if (widget.service?.tags?.isEmpty ?? false) {
      tagsList = [];
    } else {
      tagsList = widget.service?.tags?.split(',') ?? [];
    }

    if (widget.service != null) {
      //initial values of faqs
      if (widget.service!.faqs != null) {
        for (int i = 0; i < widget.service!.faqs!.length; i++) {
          faqQuestionTextEditors.value.add(
            TextEditingController(
              text: widget.service!.faqs![i].question,
            ),
          );
          faqAnswersTextEditors.value.add(
            TextEditingController(
              text: widget.service!.faqs![i].answer,
            ),
          );
        }
      }
      if (widget.service!.longDescription != null) {
        longDescription = widget.service!.longDescription;
      }
    }

    if (faqQuestionTextEditors.value.isEmpty ||
        faqAnswersTextEditors.value.isEmpty) {
      faqQuestionTextEditors.value.add(TextEditingController());
      faqAnswersTextEditors.value.add(TextEditingController());
    }
  }

  @override
  void didChangeDependencies() {
    if (widget.service?.taxType == 'included') {
      selectedPriceType = {
        'title': 'taxIncluded'.translate(context: context),
        'value': '0'
      };
    } else {
      selectedPriceType = {
        'title': 'taxExcluded'.translate(context: context),
        'value': '1'
      };
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (tagsList.isNotEmpty) {
      finalTagList = List.generate(
        tagsList.length,
        (int index) {
          return {
            'id': index,
            'text': tagsList[index],
          };
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (currIndex != 1) {
          setState(() {
            currIndex--;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          title: CustomText(
            titleText: widget.service?.id != null
                ? 'editServiceLabel'.translate(context: context)
                : 'createServiceTxtLbl'.translate(context: context),
            fontColor: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.bold,
          ),
          leading: UiUtils.setBackArrow(
            context,
            onTap: () {
              if (currIndex != 1) {
                setState(() {
                  currIndex--;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: <Widget>[
            PageNumberIndicator(currentIndex: currIndex, total: totalForms)
          ],
        ),
        bottomNavigationBar: bottomNavigation(),
        body: screenBuilder(currIndex),
      ),
    );
  }

  Widget screenBuilder(int currentPage) {
    Widget currentForm = form1(); //default form1
    switch (currIndex) {
      // case 4:
      //   currentForm = form4();
      //   break;
      // case 3:
      //   currentForm = form3();
      //   break;
      case 2:
        currentForm = form2();
        break;
      default:
        currentForm = form1();
        break;
    }
    return currIndex == 4
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

  Widget _fileContainer({required String filePath, bool isNetwork = false}) {
    return InkWell(
      onTap: () async {
        if (!fileTapLoading) {
          fileTapLoading = true;
          if (isNetwork) {
            launchUrl(
              Uri.parse(filePath),
              mode: LaunchMode.externalApplication,
            );
          } else {
            OpenFilex.open(filePath);
          }
          fileTapLoading = false;
        }
      },
      child: SizedBox(
        width: 150,
        height: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.file_present_outlined,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              UiUtils.extractFileName(filePath),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget form2() {
    return Form(
      key: formKey2,
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

  Widget _singleQuestionItem({required index}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: UiUtils.setTitleAndTFF(
                  context,
                  bottomPadding: 0,
                  titleText:
                      "${'question'.translate(context: context)} ${index + 1}",
                  controller: faqQuestionTextEditors.value[index],
                  validator: (String? value) {
                    return Validator.nullCheck(value);
                  },
                ),
              ),
              index == 0
                  ? IconButton(
                      onPressed: () {
                        if (faqQuestionTextEditors.value.last.text
                                .trim()
                                .isEmpty ||
                            faqAnswersTextEditors.value.last.text
                                .trim()
                                .isEmpty) {
                          UiUtils.showMessage(
                            context,
                            "fillLastFAQToAddMore".translate(context: context),
                            MessageType.warning,
                          );
                        } else {
                          faqQuestionTextEditors.value
                              .add(TextEditingController());
                          faqAnswersTextEditors.value
                              .add(TextEditingController());
                          faqQuestionTextEditors.notifyListeners();
                        }
                      },
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        faqQuestionTextEditors.value.removeAt(index);
                        faqAnswersTextEditors.value.removeAt(index);
                        faqQuestionTextEditors.notifyListeners();
                      },
                      icon: const Icon(
                        Icons.close_outlined,
                        color: AppColors.redColor,
                      ),
                    ),
            ],
          ),
        ),
        UiUtils.setTitleAndTFF(
          context,
          titleText: "${'answer'.translate(context: context)} ${index + 1}",
          bottomPadding: 10,
          controller: faqAnswersTextEditors.value[index],
          textInputType: TextInputType.multiline,
          validator: (String? value) {
            return Validator.nullCheck(value);
          },
        ),
        if (index != faqQuestionTextEditors.value.length - 1)
          UiUtils.setDivider(context: context),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  // Widget form3() {
  //   return Form(
  //     key: formKey3,
  //     child: ValueListenableBuilder(
  //       valueListenable: faqQuestionTextEditors,
  //       builder: (context, value, child) {
  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             CustomText(
  //               titleText: 'faqs'.translate(context: context),
  //               fontColor: Theme.of(context).colorScheme.blackColor,
  //             ),
  //             const SizedBox(
  //               height: 15,
  //             ),
  //             ...List.generate(
  //               faqQuestionTextEditors.value.length,
  //               (index) {
  //                 return _singleQuestionItem(index: index);
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget form4() {
  //   return BlocConsumer<CreateServiceCubit, CreateServiceCubitState>(
  //     listener: (BuildContext context, CreateServiceCubitState state) {
  //       if (state is CreateServiceFailure) {
  //         UiUtils.showMessage(context, state.errorMessage.translate(context: context), MessageType.error);
  //       }

  //       if (state is CreateServiceSuccess) {
  //         UiUtils.showMessage(
  //           context,
  //           widget.service?.id != null
  //               ? 'serviceEditedSuccessfully'.translate(context: context)
  //               : 'succesCreatedService'.translate(context: context),
  //           MessageType.success,
  //           onMessageClosed: () {
  //             Navigator.pop(context);
  //             context.read<FetchServicesCubit>().fetchServices();
  //           },
  //         );
  //       }
  //     },
  //     builder: (BuildContext context, CreateServiceCubitState state) {
  //       return SizedBox(
  //         height: double.maxFinite,
  //         child: CustomHTMLEditor(
  //           controller: controller,
  //           initialHTML: longDescription,
  //           hint: 'describeServiceInDetail'.translate(context: context),
  //         ),
  //       );
  //     },
  //   );
  // }

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

//category list modal bottom Sheet
  Future selectCategoryBottomSheet() {
    return UiUtils.showModelBottomSheets(
      context: context,
      enableDrag: true,
      child: BlocBuilder<FetchServiceCategoryCubit, FetchServiceCategoryState>(
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
                      'chooseCategory'.translate(context: context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      //clipBehavior: Clip.none,
                      child: Column(
                        children: List.generate(
                          state.serviceCategories.length,
                          (int index) => listWidget(
                            title: state.serviceCategories[index].name!
                                .toUpperCase(),
                            isSelected: selectedCategory ==
                                int.parse(
                                  state.serviceCategories[index].id ?? '0',
                                ),
                            onTap: () {
                              selectedCategory = int.parse(
                                state.serviceCategories[index].id!,
                              ); //pass complete Category model instead of id

                              selectedCategoryTitle =
                                  state.serviceCategories[index].name;
                              setState(() {});

                              Navigator.of(context).pop();
                            },
                          ),
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

//taxes modal bottom Sheet
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

  Widget setTitleForDropDown({
    required VoidCallback onTap,
    required String titleTxt,
    required String hintText,
    required Color bgClr,
    required Color txtClr,
    required Color arrowColor,
  }) {
    return InkWell(
      //open bottomsheet
      onTap: onTap,
      child: dropDownTextLblWithFrwdArrow(
        titleTxt: titleTxt,
        hintText: hintText,
        txtClr: txtClr,
        arrowColor: arrowColor,
        bgClr: bgClr,
      ),
    );
  }

  Widget dropDownTextLblWithFrwdArrow({
    required String titleTxt,
    required String hintText,
    required Color bgClr,
    required Color txtClr,
    required Color arrowColor,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            fontColor: Theme.of(context).colorScheme.blackColor,
            titleText: titleTxt,
            fontWeight: FontWeight.w400,
            fontSize: 18.0,
          ),
          const SizedBox(height: 8),
          CustomContainer(
            height: MediaQuery.sizeOf(context).height * 0.07,
            cornerRadius: 10,
            bgColor: Theme.of(context).colorScheme.secondaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Text(
                    hintText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.blackColor,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: arrowColor,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setTitleAndSwitch({
    required String titleText,
    required bool isAllowed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomText(
            titleText: titleText,
            fontWeight: FontWeight.w400,
            fontColor: Theme.of(context).colorScheme.blackColor,
          ),
        ),
        CupertinoSwitch(
          value: isAllowed,
          onChanged: (bool val) {
            // isAllowed = !isAllowed; //val;
            if (titleText == 'payLaterAllowedLbl'.translate(context: context)) {
              isPayLaterAllowed = val;
            } else if (titleText ==
                'isCancelableLbl'.translate(context: context)) {
              isCancelAllowed = val;
            } else if (titleText ==
                'atStoreAllowed'.translate(context: context)) {
              isStoreAllowed = val;
            } else if (titleText ==
                'atDoorstepAllowed'.translate(context: context)) {
              isDoorStepAllowed = val;
            } else if (titleText == 'statusLbl'.translate(context: context)) {
              serviceStatus = val;
            }

            setState(() {});
          },
        )
      ],
    );
  }

  Padding bottomNavigation() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currIndex > 1) ...[
              Expanded(child: nextPrevBtnWidget(false)),
              const SizedBox(width: 10)
            ],
            Expanded(child: nextButton()),
          ],
        ),
      ),
    );
  }

  CustomRoundedButton nextButton() {
    Widget? child;
    if (context.watch<CreateServiceCubit>().state is CreateServiceInProgress) {
      child = CircularProgressIndicator(
        color: AppColors.whiteColors,
      );
    }

    return CustomRoundedButton(
      textSize: 15,
      widthPercentage: 1,
      backgroundColor: Theme.of(context).colorScheme.accentColor,
      buttonTitle: currIndex < totalForms
          ? 'nxtBtnLbl'.translate(context: context)
          : widget.service?.id != null
              ? 'editServiceBtnLbl'.translate(context: context)
              : 'addServiceBtnLbl'.translate(context: context),
      showBorder: false,
      onTap: () {
        UiUtils.removeFocus();
        onNextPrevBtnClick(true);
      },
      child: child,
    );
  }

  CustomRoundedButton nextPrevBtnWidget(bool isNext) {
    return CustomRoundedButton(
      showBorder: true,
      borderColor: isNext
          ? Colors.transparent
          : Theme.of(context).colorScheme.blackColor,
      radius: 8,
      textSize: 15,
      buttonTitle: isNext && currIndex >= totalForms
          ? 'addServiceBtnLbl'.translate(context: context)
          : isNext
              ? 'nxtBtnLbl'.translate(context: context)
              : 'prevBtnLbl'.translate(context: context),
      titleColor: isNext
          ? Theme.of(context).colorScheme.secondaryColor
          : Theme.of(context).colorScheme.blackColor,
      backgroundColor: isNext
          ? Theme.of(context).colorScheme.blackColor
          : Theme.of(context).colorScheme.primaryColor,
      widthPercentage: isNext ? 1 : 0.5,
      onTap: () {
        onNextPrevBtnClick(isNext);
      },
    );
  }

  Future<void> onNextPrevBtnClick(bool isNext) async {
    UiUtils.removeFocus();

    // if (currIndex == 2) {
    //   final tempText = await controller.getText();
    //   if (tempText.trim().isNotEmpty) {
    //     longDescription = tempText;
    //   }
    //   controller.clearFocus();
    // }
    if (isNext) {
      FormState? form = formKey1.currentState; //default value
      switch (currIndex) {
        // case 3:
        //   form = formKey3.currentState;
        //   break;
        case 2:
          form = formKey2.currentState;
          break;
        default:
          form = formKey1.currentState;
          break;
      }
      if (form == null && currIndex != 2) return;

      if (form != null) {
        form.save();
      }

      //not validating the faqs and long description pages
      if (currIndex > 2 || form!.validate()) {
        if (currIndex < totalForms) {
          if (currIndex == 1) {
            if (finalTagList.isEmpty) {
              UiUtils.showMessage(
                context,
                'pleaseAddTags'.translate(context: context),
                MessageType.error,
              );
              return;
            }
          }
          if (currIndex == 2) {
            if (!(imagePicker.pickedFile != null ||
                widget.service?.imageOfTheService != null ||
                pickedServiceImage != '')) {
              FocusScope.of(context).unfocus();
              UiUtils.showMessage(
                context,
                "selectServiceImageToContinue".translate(context: context),
                MessageType.warning,
              );
              return;
            }
          }
          currIndex++;
          scrollController.jumpTo(0);
          setState(() {});
        } else {
          String tagString = '';
          if (finalTagList.isNotEmpty) {
            for (final Map<String, dynamic> element in finalTagList) {
              tagString += "${element['text']},";
            }
            //remove last ,
            tagString = tagString.substring(0, tagString.length - 1);
          } else {
            UiUtils.showMessage(context, 'pleaseAddTags', MessageType.error);
            return;
          }

          List<ServiceFaQs> faqsAdded = [];

          for (int i = 0; i < faqQuestionTextEditors.value.length; i++) {
            try {
              if (faqQuestionTextEditors.value[i].text.trim().isNotEmpty &&
                  faqAnswersTextEditors.value[i].text.trim().isNotEmpty) {
                faqsAdded.add(
                  ServiceFaQs(
                    question: faqQuestionTextEditors.value[i].text,
                    answer: faqAnswersTextEditors.value[i].text,
                  ),
                );
              }
            } catch (_) {}
          }

          ///if serviceId is available then it will update existing service otherwise it will add
          final CreateServiceModel createServiceModel = CreateServiceModel(
            serviceId: widget.service?.id,
            title: serviceTitleController.text,
            description: serviceDescrController.text,
            price: priceController.text,
            members: memReqTaskController.text,
            maxQty: qtyAllowedTaskController.text,
            duration: null,
            cancelableTill: cancelBeforeController.text.trim().toString(),
            iscancelable: isCancelAllowed == false ? 0 : 1,
            is_pay_later_allowed: isPayLaterAllowed == false ? 0 : 1,
            isStoreAllowed: isStoreAllowed == false ? 0 : 1,
            status: serviceStatus == false ? "0" : "1",
            isDoorStepAllowed: isDoorStepAllowed == false ? 0 : 1,
            discounted_price: null,
            // image: pickedServiceImage,
            categories: selectedCategory.toString(),
            tax_type: priceTypeFilter[selectedPriceType?['value']],
            tags: tagString,
            taxId: selectedTax.toString(),
            other_images: pickedOtherImages.value,
            files: pickedFiles.value,
            faqs: faqsAdded,
            long_description: longDescription,
          );

          // if (imagePicker.pickedFile != null ||
          //     widget.service?.imageOfTheService != null ||
          //     pickedServiceImage != '') {
          //
          if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable()) {
            UiUtils.showDemoModeWarning(context: context);
            return;
          }
          //
          context
              .read<CreateServiceCubit>()
              .createService(createServiceModel, context);
          // } else {
          //   FocusScope.of(context).unfocus();
          //   showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return AlertDialog(
          //         title: Text('imageRequired'.translate(context: context)),
          //         content:
          //             Text('pleaseSelectImage'.translate(context: context)),
          //         actions: [
          //           TextButton(
          //             onPressed: () {
          //               Navigator.pop(context);
          //             },
          //             child: Text('ok'.translate(context: context)),
          //           )
          //         ],
          //       );
          //     },
          //   );
          // }
        }
      }
    } else if (currIndex > 1) {
      currIndex--;
      setState(() {});
    }
  }
}
