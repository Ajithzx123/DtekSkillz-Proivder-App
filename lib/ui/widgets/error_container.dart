import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class ErrorContainer extends StatelessWidget {

  const ErrorContainer(
      {super.key,
      required this.errorMessage,
      this.errorMessageColor,
      this.errorMessageFontSize,
      this.onTapRetry,
      this.showErrorImage,
      this.retryButtonBackgroundColor,
      this.retryButtonTextColor,
      this.showRetryButton,});
  final String errorMessage;
  final bool? showRetryButton;
  final bool? showErrorImage;
  final Color? errorMessageColor;
  final double? errorMessageFontSize;
  final Function? onTapRetry;
  final Color? retryButtonBackgroundColor;
  final Color? retryButtonTextColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * (0.025),
        ),
        if (errorMessage == 'noInternetFound'.translate(context: context)) SizedBox(
                height: MediaQuery.sizeOf(context).height * (0.35),
                child: UiUtils.setSVGImage('noInternet'),
              ) else SizedBox(
                height: MediaQuery.sizeOf(context).height * (0.35),
                child: UiUtils.setSVGImage('somethingWentWrong'),
              ),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * (0.025),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            errorMessage.translate(context: context),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: errorMessageColor ?? Theme.of(context).colorScheme.blackColor,
                fontSize: errorMessageFontSize ?? 16,),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        if (showRetryButton ?? true) CustomRoundedButton(
                height: 40,
                widthPercentage: 0.3,
                backgroundColor:
                    retryButtonBackgroundColor ?? Theme.of(context).colorScheme.primary,
                onTap: () {
                  onTapRetry?.call();
                },
                titleColor: retryButtonTextColor ?? Theme.of(context).scaffoldBackgroundColor,
                buttonTitle: 'Retry',
                showBorder: false,) else const SizedBox()
      ],
    );
  }
}
