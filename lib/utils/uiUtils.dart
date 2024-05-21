import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import '../app/generalImports.dart';

class UiUtils {
  //
  // Toast message display duration
  static const int messageDisplayDuration = 3000;

  //space from bottom for buttons
  static const double bottomButtonSpacing = 56;

  //required days to create PromoCode
  static const int noOfDaysAllowToCreatePromoCode = 365;

  //bottom sheet radius
  static double bottomSheetTopRadius = 20.0;

  ///IconButton
  static IconButton setBackArrow(
    BuildContext context, {
    bool? canGoBack,
    VoidCallback? onTap,
  }) {
    return IconButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      icon: UiUtils.setSVGImage(
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
        boxFit: BoxFit.scaleDown,
        imgColor: Theme.of(context).colorScheme.blackColor,
      ),
      onPressed: onTap ??
          () {
            if (canGoBack ?? true) {
              Navigator.of(context).pop();
            }
          },
    );
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    final List<String> result = languageCode.split('-');
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  //price format
  static String getPriceFormat(BuildContext context, double price) {
    return NumberFormat.currency(
      locale: Platform.localeName,
      name: Constant.systemCurrencyCountryCode,
      symbol: Constant.systemCurrency,
      decimalDigits: int.parse(Constant.decimalPointsForPrice ?? '0'),
    ).format(price);
  }

  ///Images
  static SvgPicture setSVGImage(
    String imageName, {
    double? height,
    double? width,
    Color? imgColor,
    BoxFit boxFit = BoxFit.contain,
  }) {
    final String path = "${Constant.svgPath}$imageName.svg";

    return SvgPicture.asset(
      path,
      height: height,
      width: width,
      colorFilter:
          imgColor != null ? ColorFilter.mode(imgColor, BlendMode.srcIn) : null,
      fit: boxFit,
    );
  }

  static CachedNetworkImage setNetworkImage(
    String imgUrl, {
    double? hh,
    double? ww,
    BoxFit? fit,
  }) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      matchTextDirection: true,
      fit: fit ?? BoxFit.cover,
      height: hh,
      width: ww,
      placeholder: (BuildContext context, String url) {
        return Image.asset('assets/images/png/placeholder.png');
      },
      errorWidget: (BuildContext context, String url, error) {
        return Image.asset(
          '${Constant.pngPath}noImageFound.png',
          fit: BoxFit.contain,
        );
      },
    );
  }

  static Color setStatusColor({
    required String statusVal,
    required BuildContext context,
  }) {
    Color stColor = AppColors.greenColor;

    switch (statusVal) {
      case 'rescheduled': //Rescheduled
        stColor = Theme.of(context).colorScheme.accentColor;
        break;

      case 'cancelled': //Cancelled
        stColor = AppColors.redColor;
        break;

      case 'confirmed': //Cancelled
        stColor = AppColors.starRatingColor;
        break;

      case 'awaiting':
        stColor = const Color.fromARGB(255, 54, 209, 244);
        break;

      default: //Confirmed
        stColor = AppColors.greenColor;
        break;
    }
    return stColor;
  }

  ///Text & TextFormField
  static Widget setTitleAndTFF(
    BuildContext context, {
    String? titleText,
    required TextEditingController controller,
    FocusNode? currNode,
    FocusNode? nextFocus,
    TextInputType textInputType = TextInputType.text,
    bool isPswd = false,
    double? heightVal,
    Widget? prefix,
    Widget? suffix,
    String? hintText,
    bool? isReadOnly,
    VoidCallback? callback,
    Color? titleColor,
    bool? forceUnfocus,
    bool? expands,
    int? minLines,
    Function()? onSubmit,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    double? bottomPadding,
    Color? backgroundColor,
    bool? allowOnlySingleDecimalPoint,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: bottomPadding ?? 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            backgroundColor: backgroundColor,
            controller: controller,
            hintTextColor: Theme.of(context).colorScheme.lightGreyColor,
            currNode: currNode,
            nextFocus: nextFocus,
            expand: expands,
            minLines: minLines,
            textInputType: textInputType,
            isPswd: isPswd,
            prefix: prefix,
            suffix: suffix,
            hintText: hintText,
            labelText: titleText,
            isReadOnly: isReadOnly,
            callback: callback,
            forceUnfocus: forceUnfocus,
            inputFormatters: allowOnlySingleDecimalPoint ?? false
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                : inputFormatters,
            onSubmit: onSubmit,
            validator: validator,
          ),
        ],
      ),
    );
  }

  ///Divider / Container
  static Padding setDivider({
    required BuildContext context,
    Color? containerColor,
    double? height,
    double? padding,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: height ?? 1.5,
        color: Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.1),
      ),
    );
  }

//bottomsheet
  static Future modalBottomSheet({
    required BuildContext context,
    required DraggableScrollableSheet child,
    Color? bgColor,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: bgColor ?? Theme.of(context).colorScheme.secondaryColor,
      //grayLightColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(5.0),
        child: child,
      ),
    );
  }

  static Future<dynamic> showModelBottomSheets({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    bool? enableDrag,
    bool? isScrollControlled,
  }) async {
    final result = await showModalBottomSheet(
      enableDrag: enableDrag ?? false,
      isScrollControlled: isScrollControlled ?? true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bottomSheetTopRadius),
          topRight: Radius.circular(bottomSheetTopRadius),
        ),
      ),
      context: context,
      builder: (_) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: child,
        );
      },
    );

    return result;
  }

  ///show alert
  static Future showAlert({
    required String titleTxt,
    required BuildContext context,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: CustomText(
            titleText: titleTxt,
            fontSize: 14,
            maxLines: 2,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
        );
      },
    );
  }

  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Only numbers can be entered
  static List<TextInputFormatter> allowOnlyDigits() {
    return <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ];
  }

  static SystemUiOverlayStyle getSystemUiOverlayStyle({
    required BuildContext context,
  }) {
    return SystemUiOverlayStyle(
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarColor: Theme.of(context).colorScheme.primaryColor,
      systemNavigationBarIconBrightness:
          context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
              ? Brightness.light
              : Brightness.dark,
      //
      statusBarColor: Theme.of(context).colorScheme.secondaryColor,
      //statusBarBrightness: context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark ? Brightness.light : Brightness.dark,
      statusBarIconBrightness:
          context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
              ? Brightness.light
              : Brightness.dark,
    );
  }

  static dynamic showDemoModeWarning({required BuildContext context}) {
    return showMessage(
      context,
      'demoModeWarning'.translate(context: context),
      MessageType.warning,
    );
  }

  static Future<void> showMessage(
    BuildContext context,
    String text,
    MessageType type, {
    Alignment? alignment,
    Duration? duration,
    VoidCallback? onMessageClosed,
  }) async {
    // ignore: prefer_final_locals
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          top: alignment != null
              ? (alignment == Alignment.topCenter ? 50 : null)
              : null,
          left: 5,
          right: 5,
          bottom: alignment != null
              ? (alignment == Alignment.bottomCenter ? 5 : null)
              : 5,
          child: MessageContainer(context: context, text: text, type: type),
        );
      },
    );
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      overlayState.insert(overlayEntry);
    });
    await Future.delayed(duration ?? const Duration(seconds: 3));

    overlayEntry.remove();
    onMessageClosed?.call();
  }

  static String extractFileName(String string) {
    try {
      return string.split('/').last;
    } catch (_) {
      return "";
    }
  }
}

///Format string
extension FormatAmount on String {
  String formatPercentage() {
    return '${toString()} %';
  }

  String formatId() {
    return ' # ${toString()} '; // \u{20B9}"; //currencySymbol
  }

  String firstUpperCase() {
    String upperCase = '';
    String suffix = '';
    if (isNotEmpty) {
      upperCase = this[0].toUpperCase();
      suffix = substring(1, length);
    }
    return upperCase + suffix;
  }
}

//scroll controller extension

extension ScrollEndListen on ScrollController {
  ///It will check if scroll is at the bottom or not
  bool isEndReached() {
    return offset >= position.maxScrollExtent;
  }
}
