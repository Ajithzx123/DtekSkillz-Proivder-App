import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.message,
    required this.title,
    required this.imageName,
  });
  final String title;
  final String message;
  final String imageName;

  static Route route(RouteSettings routeSettings) {
    final Map<String, dynamic> arguments =
        routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) {
        return SuccessScreen(
          title: arguments['title'],
          message: arguments['message'],
          imageName: arguments['imageName'] ?? '',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4,),
              child: UiUtils.setSVGImage(
                imageName,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title.translate(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.blackColor,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 30.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              message.translate(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.blackColor,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25,
            ),
            CustomRoundedButton(
              widthPercentage: 1,
              backgroundColor: Theme.of(context).colorScheme.accentColor,
              buttonTitle: 'goToLogIn'.translate(context: context),
              showBorder: false,
              onTap: () async {
                //
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.loginScreenRoute,
                  (Route<dynamic> route) => false,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
