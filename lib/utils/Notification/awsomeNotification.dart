// ignore_for_file: file_names, prefer_final_locals, always_declare_return_types

import 'dart:math';

import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class LocalAwesomeNotification {
  /*
   ios payload should be like this
   "notification": {
      "title": "Check this Mobile (title)",
      "body": "Rich Notification testing (body)",
      "mutable_content": true,
      "sound" :"default"
      },
    "data" : {
        "type" : "new_order"
    }
   */
  /* android payload should be like this
      "data" : {
            "title": "Check this Mobile (title)",
            "body": "Rich Notification testing (body)",
            "type" : "new_order"
            }
  */
  final String soundNotificationChannel = "soundNotification";
  final String normalNotificationChannel = "normalNotification";

  AwesomeNotifications notification = AwesomeNotifications();

  void init(BuildContext context) {
    requestPermission();

    notification.initialize(
      null,
      [
        NotificationChannel(
          channelKey: soundNotificationChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel',
          importance: NotificationImportance.High,
          playSound: true,
          soundSource: Platform.isIOS
              ? "order_sound.aiff"
              : "resource://raw/order_sound",
          ledColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
        NotificationChannel(
          channelKey: normalNotificationChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel',
          importance: NotificationImportance.High,
          playSound: true,
          ledColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
      ],
      channelGroups: [],
    );
    listenTap(context);
  }

  listenTap(BuildContext context) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction event) async {
        final data = event.payload;
        if (data?["type"] == "order") {
          //navigate to booking tab
          mainActivityNavigationBarGlobalKey
              .currentState?.selectedIndexOfBottomNavigationBar.value = 1;
        } else if (data?["type"] == "withdraw_request") {
          Navigator.pushNamed(context, Routes.withdrawalRequests);
        } else if (data?["type"] == "settlement") {
          //
        } else if (data?["type"] == "provider_request_status") {
          if (data?['status'] == "approve") {
          } else {}
        } else if (data?["type"] == "url") {
          final String url = data!["url"].toString();
          try {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch $url';
            }
          } catch (e) {
            throw 'Something went wrong';
          }
        }
      },
    );
  }

  createNotification({
    required RemoteMessage notificationData,
    required bool isLocked,
    required bool playCustomSound,
  }) async {
    try {
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          title: notificationData.data["title"],
          locked: isLocked,
          payload: Map.from(notificationData.data),
          //  autoDismissible`: true,
          body: notificationData.data["body"],
          color: const Color.fromARGB(255, 79, 54, 244),
          wakeUpScreen: true,
          channelKey: playCustomSound
              ? soundNotificationChannel
              : normalNotificationChannel,
          notificationLayout: NotificationLayout.BigText,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  createImageNotification({
    required RemoteMessage notificationData,
    required bool isLocked,
    required bool playCustomSound,
  }) async {
    try {
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          title: notificationData.data["title"],
          locked: isLocked,
          payload: Map.from(notificationData.data),
          autoDismissible: true,
          body: notificationData.data["body"],
          color: const Color.fromARGB(255, 79, 54, 244),
          wakeUpScreen: true,
          largeIcon: notificationData.data["image"],
          bigPicture: notificationData.data["image"],
          notificationLayout: NotificationLayout.BigPicture,
          channelKey: playCustomSound
              ? soundNotificationChannel
              : normalNotificationChannel,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  createSoundNotification({
    required String title,
    required String body,
    required RemoteMessage notificationData,
    required bool isLocked,
  }) async {
    try {
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          title: notificationData.data["title"],
          locked: isLocked,
          payload: Map.from(notificationData.data),
          //     autoDismissible: true,
          body: notificationData.data["body"],
          color: const Color.fromARGB(255, 79, 54, 244),
          wakeUpScreen: true,
          largeIcon: notificationData.data["image"],
          bigPicture: notificationData.data['data']?["image"],
          notificationLayout: NotificationLayout.BigPicture,
          channelKey: soundNotificationChannel,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  requestPermission() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      await notification.requestPermissionToSendNotifications(
        channelKey: soundNotificationChannel,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light
        ],
      );

      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {}
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }
  }
}
