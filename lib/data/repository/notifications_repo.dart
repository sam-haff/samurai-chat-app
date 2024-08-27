
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as nots;

class NotificationsRepo {
  Future<String?> setupPushNotifications() async {
    const nots.AndroidNotificationChannel channel = nots.AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications', 
      description: 'This channel is used for important notifications.', // description
      importance: nots.Importance.max,
    );

    final nots.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = nots.FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<nots.AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);    

    final fbm = FirebaseMessaging.instance;
    await fbm.requestPermission(provisional: true);

    return fbm.getToken();
  }
}