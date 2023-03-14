import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';

class Notify {
  static Future<bool> instantNotify(String username) async {
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
    return awesomeNotifications.createNotification(
        content: NotificationContent(
            id: Random().nextInt(100),
            title: "Hey $username",
            body: "Congratulations, your charge is completed!",
            channelKey: "instant_notifications"));
  }
}
