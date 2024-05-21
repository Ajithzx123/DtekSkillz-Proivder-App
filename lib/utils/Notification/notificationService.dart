// ignore_for_file: file_names, always_declare_return_types

import 'package:edemand_partner/app/generalImports.dart';

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  static LocalAwesomeNotification localNotification = LocalAwesomeNotification();

  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;

  static Future<void> requestPermission() async {
    await messagingInstance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static void init(context) {
    requestPermission();
    registerListeners(context);
  }

  static Future<void> foregroundNotificationHandler() async {
    foregroundStream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //
      print("message data is ${message.data}");
      //in ios awesome notification will automatically generate a notification
      if (message.data['type'] == "order" && Platform.isAndroid) {
        localNotification.createSoundNotification(
          title: message.notification?.title ?? "",
          body: message.notification?.body ?? "",
          notificationData: message,
          isLocked: false,
        );
      } else {
        if (message.data["image"] == null && Platform.isAndroid) {
          localNotification.createNotification(
            isLocked: false,
            notificationData: message,
            playCustomSound: false,
          );
        } else if (Platform.isAndroid) {
          localNotification.createImageNotification(
            isLocked: false,
            notificationData: message,
            playCustomSound: false,
          );
        }
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    print("message data is ${message.data}");

    if (message.data['type'] == "order" && Platform.isAndroid) {
      localNotification.createSoundNotification(
        title: message.notification?.title ?? "",
        body: message.notification?.body ?? "",
        notificationData: message,
        isLocked: false,
      );
    } else {
      if (message.data["image"] == null  && Platform.isAndroid) {
        localNotification.createNotification(
          isLocked: false,
          notificationData: message,
          playCustomSound: false,
        );
      } else if( Platform.isAndroid){
        localNotification.createImageNotification(
          isLocked: false,
          notificationData: message,
          playCustomSound: false,
        );
      }
    }
  }

  static terminatedStateNotificationHandler() {
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message == null) {
          return;
        }
        if (message.data["image"] == null) {
          localNotification.createNotification(
            isLocked: false,
            notificationData: message,
            playCustomSound: false,
          );
        } else {
          localNotification.createImageNotification(
            isLocked: false,
            notificationData: message,
            playCustomSound: false,
          );
        }
        /*localNotification.createNotification(
            isLocked: false, notificationData: message, playCustomSound: false);*/
      },
    );
  }

  static onTapNotificationHandler(context) {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        if (message.data["type"] == "order") {
          //navigate to booking tab
          mainActivityNavigationBarGlobalKey
              .currentState?.selectedIndexOfBottomNavigationBar.value = 1;
        } else if (message.data["type"] == "withdraw_request") {
          Navigator.pushNamed(context, Routes.withdrawalRequests);
        } else if (message.data["type"] == "settlement") {
          //
        } else if (message.data["type"] == "provider_request_status") {
          if (message.data['status'] == "approve") {
          } else {}
        } else if (message.data["type"] == "url") {
        final  String url = message.data["url"].toString();
          try {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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

  static registerListeners(context) async {
    FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    await foregroundNotificationHandler();
    await terminatedStateNotificationHandler();
    await onTapNotificationHandler(context);
  }

  static disposeListeners() {
    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
