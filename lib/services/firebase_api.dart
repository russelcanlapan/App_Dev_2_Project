import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseAPI {

  static Future<void> initializeNotifications() async {
    // request permission from user
    await FirebaseMessaging.instance.requestPermission();

    // fetch the token
    final token = await FirebaseMessaging.instance.getToken();

    // print the token (temp)
    print('your token: $token');
  }

}