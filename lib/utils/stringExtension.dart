import 'package:edemand_partner/app/generalImports.dart';
import 'package:intl/intl.dart';


extension StringExtension on String {
  //
  String convertToAgo({required BuildContext context}) {
    final Duration diff = DateTime.now().difference(DateTime.parse(this));

    if (diff.inDays >= 365) {
      return "${(diff.inDays / 365).toStringAsFixed(0)} ${"yearAgo".translate(context: context)}";
    } else if (diff.inDays >= 31) {
      return "${(diff.inDays / 31).toStringAsFixed(0)} ${"monthsAgo".translate(context: context)}";
    } else if (diff.inDays >= 1) {
      return "${diff.inDays} ${"daysAgo".translate(context: context)}";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} ${"hoursAgo".translate(context: context)}";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} ${"minutesAgo".translate(context: context)}";
    } else if (diff.inSeconds >= 1) {
      return "${diff.inSeconds} ${"secondsAgo".translate(context: context)}";
    }
    return 'justNow'.translate(context: context);
  }

  //
  String translate({required BuildContext context}) {
    return (AppLocalization.of(context)!.getTranslatedValues(this) ?? this).trim();
  }

  //
  String getFirebaseError({required BuildContext context}) {
    if (this == 'invalid-verification-code') {
      return 'invalid_verification_code'.translate(context: context);
    } else if (this == 'invalid-phone-number') {
      return 'invalid_phone_number'.translate(context: context);
    } else if (this == 'too-many-requests') {
      return 'too_many_requests'.translate(context: context);
    } else if (this == 'network-request-failed') {
      return 'network_request_failed'.translate(context: context);
    } else {
      return 'somethingWentWrong'.translate(context: context);
    }
  }

  //
  /// Replace extra coma from String
  ///
  String removeExtraComma() {
    const String middleDuplicateComaRegex = ',(.?),';
    const String leadingAndTrailingComa = r'(^,)|(,$)';
    final RegExp removeComaFromString = RegExp(
      middleDuplicateComaRegex,
      caseSensitive: false,
      multiLine: true,
    );

    final RegExp leadingAndTrailing = RegExp(
      leadingAndTrailingComa,
      multiLine: true,
      caseSensitive: false,
    );

    final String filteredText =
        trim().replaceAll(removeComaFromString, ',').replaceAll(leadingAndTrailing, '');

    return filteredText;
  }
  
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String trimLatLong() {
    return length < 10 ? this : substring(0, indexOf('.') + 7);
  }

  String formatDate() {
    return DateFormat("${dateAndTimeSetting["dateFormat"]}")
        .format(DateTime.parse("$this 00:00:00.000Z"));
  }

  String formatTime() {
    if (dateAndTimeSetting["use24HourFormat"]) return this;
    return DateFormat("hh:mm a").format(DateFormat('HH:mm').parse(this)).toString();
  }

  String formatDateAndTime() {
    //  input will be in dd-mm-yyyy hh:mm:ss format
    if (dateAndTimeSetting["use24HourFormat"]) {
      //format the date only return the time as it is
      final String date = split(" ").first;
      return "${date.formatDate()} ${split(" ")[1]}";
    }
    return DateFormat('${dateAndTimeSetting["dateFormat"]} hh:mm a').format(DateTime.parse(this));
  }
}
