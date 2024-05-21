import 'package:edemand_partner/data/repository/notifications_repository.dart';
import '../../app/generalImports.dart';


abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsInProgress extends NotificationsState {}

class NotificationFetchSuccess extends NotificationsState {

  NotificationFetchSuccess({required this.notifications});
  final List<NotificationDataModel> notifications;
}

class NotificationFetchFailure extends NotificationsState {}

class NotificationsCubit extends Cubit<NotificationsState> {

  NotificationsCubit() : super(NotificationsInitial());
  final NotificationsRepository notificationsRepository = NotificationsRepository();

  //
  Future<void> fetchNotifications() async {
    try {
      emit(NotificationsInProgress());
      final List<NotificationDataModel> notificationsData =
          await notificationsRepository.getNotifications(isAuthTokenRequired: true);
      emit(NotificationFetchSuccess(notifications: notificationsData));
    } catch (error) {
      emit(NotificationFetchFailure());
    }
  }

  void removeNotificationFromList(dynamic id) {
    if (state is NotificationFetchSuccess) {
      final List notificationList = (state as NotificationFetchSuccess).notifications;
      notificationList.removeWhere((element) => element.id == id);
      final List<NotificationDataModel> list = List.from(notificationList);
      emit(NotificationFetchSuccess(notifications: list));
    }
  }
}
