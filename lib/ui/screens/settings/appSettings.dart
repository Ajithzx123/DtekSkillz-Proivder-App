import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../app/generalImports.dart';

class AppSetting extends StatelessWidget {
  const AppSetting({super.key, required this.title});
  final String title;

  static Route<AppSetting> route(RouteSettings routeSettings) {
    final Map<String, dynamic> parameter =
        routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => AppSetting(title: parameter['title']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text(
          title.translate(context: context),
          style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        leading: UiUtils.setBackArrow(
          context,
        ),
      ),
      body: BlocBuilder<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        builder: (BuildContext context, FetchSystemSettingsState state) {
          if (state is FetchSystemSettingsInProgress) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.whiteColors,
              ),
            );
          }

          if (state is FetchSystemSettingsFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context
                      .read<FetchSystemSettingsCubit>()
                      .getSettings(isAnonymous: false);
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          if (state is FetchSystemSettingsSuccess) {
            final bool isPrivacyPolicy = title == 'privacyPolicy';
            final bool isAboutUs = title == 'aboutUs';
            final bool isContactUs = title == 'contactUs';
            final bool isTermAndCondition = title == 'termsCondition';

            final bool termAndConditionHasData =
                isTermAndCondition && state.termsAndConditions.isNotEmpty;
            final bool privacyPolicyHasData =
                isPrivacyPolicy && state.privacyPolicy.isNotEmpty;
            final bool contactUsHasData =
                isContactUs && state.contactUs.isNotEmpty;
            final bool aboutUsHasData = isAboutUs && state.aboutUs.isNotEmpty;

            if (termAndConditionHasData ||
                privacyPolicyHasData ||
                contactUsHasData ||
                aboutUsHasData) {
              return SingleChildScrollView(
                clipBehavior: Clip.none,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: HtmlWidget(
                    isTermAndCondition
                        ? state.termsAndConditions
                        : isPrivacyPolicy
                            ? state.privacyPolicy
                            : isAboutUs
                                ? state.aboutUs
                                : state.contactUs,
                  ),
                ),
              );
            }
            return NoDataContainer(
                titleKey: 'noDataFound'.translate(context: context),);
          }

          return Container();
        },
      ),
    );
  }
}
