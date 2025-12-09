// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:kam_wala_app/Admin/Adminpanel.dart';
// import 'package:kam_wala_app/Auth/login_screen.dart';
// import 'package:kam_wala_app/beauty%20salon/imagedatafatechsalon.dart';
// import 'package:kam_wala_app/dashboard/AddPost.dart';
// import 'package:kam_wala_app/dashboard/admin_drawer.dart';
// import 'package:kam_wala_app/dashboard/admin_home.dart';
// import 'package:kam_wala_app/dashboard/fatchdata.dart';
// import 'package:kam_wala_app/dashboard/imagecrud.dart';
// import 'package:kam_wala_app/feedback/adminrecored.dart';
// import 'package:kam_wala_app/feedback/userfeedbackscreen.dart';

// import 'package:kam_wala_app/image%20crud%20hamdeling/imagedatafatech.dart';
// import 'package:kam_wala_app/image%20crud%20hamdeling/map_screen.dart';

// import 'package:kam_wala_app/image%20crud%20hamdeling/product_list_screen.dart';
// import 'package:kam_wala_app/screens/Worker%20Request%20Page.dart';
// import 'package:kam_wala_app/screens/splashscreen.dart';
// import 'package:kam_wala_app/user/3services_select_screen.dart';
// import 'package:kam_wala_app/user/bussinesadminrecoredscreen.dart';
// import 'package:kam_wala_app/user/user_panel.dart';
// import 'package:kam_wala_app/worker/WorkerPanel.dart';
// import 'firebase_options.dart';

// // messaging
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // easyloading
// import 'package:flutter_easyloading/flutter_easyloading.dart';

// // 🔔 Background message handler (TOP-LEVEL function required)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   // Optionally do background processing/logging here
// }

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _initLocalNotifications() async {
//   const AndroidInitializationSettings initSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   const InitializationSettings initSettings = InitializationSettings(
//     android: initSettingsAndroid,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initSettings);

//   // Create a default channel on Android
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'default_channel',
//     'General Notifications',
//     description: 'Default notification channel',
//     importance: Importance.high,
//   );
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin
//       >()
//       ?.createNotificationChannel(channel);
// }

// Future<void> _setupPushHandlers() async {
//   // iOS permission (Android auto-granted but we keep consistent)
//   await FirebaseMessaging.instance.requestPermission();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Foreground notifications: show via local notifications
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     final notification = message.notification;
//     if (notification != null) {
//       await flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'default_channel',
//             'General Notifications',
//             importance: Importance.high,
//             priority: Priority.high,
//             playSound: true,
//           ),
//         ),
//       );
//     }
//   });

//   // When app opened from notification
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     // You can navigate based on message.data if needed
//   });
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await _initLocalNotifications();
//   await _setupPushHandlers();

//   configLoading(); // ✅ ab runApp se pehle lagana hai
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Kam Wala App',
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(),

//       /// ✅ EasyLoading init yahan attach karna zaroori hai
//       builder: EasyLoading.init(),
//     );
//   }
// }

// /// ✅ Global EasyLoading config (Blue + White, non-blocking UI)
// void configLoading() {
//   EasyLoading.instance
//     ..loadingStyle = EasyLoadingStyle.light
//     ..maskType =
//         EasyLoadingMaskType
//             .none // ✅ page freeze nahi hoga
//     ..indicatorType = EasyLoadingIndicatorType.fadingCircle
//     ..indicatorSize = 45.0
//     ..radius = 12.0
//     ..progressColor = Colors.blue
//     ..backgroundColor = Colors.white
//     ..indicatorColor = Colors.blue
//     ..textColor = Colors.blue
//     ..userInteractions =
//         true; // ✅ ab user tap/scroll kar sakta hai loader ke time
// }



import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kam_wala_app/screens/splashscreen.dart';

// ✅ Background messages ko handle karne wala function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  print("📩 Background message: ${message.notification?.title} - ${message.notification?.body}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase ek dafa initialize
  await Firebase.initializeApp();

  // ✅ Background message handler register
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Foreground notifications ke liye settings
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // iOS/Android dono ke liye permission mangna
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Token print karwana (debug ke liye)
  String? token = await messaging.getToken();
  print("🔥 FCM Token: $token");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kaam Wala App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
