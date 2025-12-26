// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:kam_wala_app/firebase_options.dart';
// import 'package:kam_wala_app/screens/splashscreen.dart';
// import 'package:kam_wala_app/image crud hamdeling/workernotification.dart';

// final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();


// // -------------------------------------------------------
// // 🔹 BACKGROUND HANDLER
// // -------------------------------------------------------
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   debugPrint("📩 Background message: ${message.data}");
// }


// // -------------------------------------------------------
// // 🔹 OPEN PAGE
// // -------------------------------------------------------
// void _openWorkerNotificationPage({required String requestId}) {
//   final ctx = navKey.currentContext;
//   if (ctx == null) return;

//   Navigator.push(
//     ctx,
//     MaterialPageRoute(
//       builder: (_) => WorkerNotificationPage(requestId: requestId),
//     ),
//   );
// }


// // -------------------------------------------------------
// // 🔹 HANDLE FCM CLICK
// // -------------------------------------------------------
// void handleNotificationClick(RemoteMessage message) {
//   final data = message.data;

//   if (data['screen'] == 'worker_notification' &&
//       data['requestId'] != null) {
//     _openWorkerNotificationPage(
//       requestId: data['requestId'],
//     );
//   } else {
//     debugPrint("⚠ Invalid notification payload");
//   }
// }


// // -------------------------------------------------------
// // 🔹 MAIN
// // -------------------------------------------------------
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   if (!kIsWeb) {
//     FirebaseMessaging.onBackgroundMessage(
//       _firebaseMessagingBackgroundHandler,
//     );
//   }

//   // 🔔 Notification Channel
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     description: 'Used for job requests',
//     importance: Importance.max,
//   );

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   // 🔔 Local notification init (🔥 tap handler added)
//   const AndroidInitializationSettings androidInit =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   await flutterLocalNotificationsPlugin.initialize(
//     const InitializationSettings(android: androidInit),
//     onDidReceiveNotificationResponse: (details) {
//       if (details.payload != null) {
//         _openWorkerNotificationPage(requestId: details.payload!);
//       }
//     },
//   );

//   // 🔹 Permission + Token
//   if (kIsWeb) {
//   await FirebaseMessaging.instance.requestPermission();
//   String? token = await FirebaseMessaging.instance
//       .getToken(vapidKey: "BCUDNCX8SwCML4_V09q6m8cxnylE_q7Tzfu8MPhm_V0lvFAB5jSJJPKfbaBcHNE2qnVPRxDcJKFqJY0_hNlPmEU");
//   debugPrint("🔥 Web FCM Token: $token");
// }

//   // -------------------------------------------------------
//   // 🔹 FOREGROUND
//   // -------------------------------------------------------
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     final notification = message.notification;
//     if (notification != null && message.data['requestId'] != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             channelDescription: channel.description,
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//         ),
//         payload: message.data['requestId'], // 🔥 VERY IMPORTANT
//       );
//     }
//   });

//   // -------------------------------------------------------
//   // 🔹 BACKGROUND → OPEN
//   // -------------------------------------------------------
//   FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationClick);

//   // -------------------------------------------------------
//   // 🔹 TERMINATED → OPEN
//   // -------------------------------------------------------
//   final initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();

//   if (initialMessage != null) {
//     Future.delayed(const Duration(milliseconds: 500), () {
//       handleNotificationClick(initialMessage);
//     });
//   }

//   runApp(const MyApp());
// }


// // -------------------------------------------------------
// // 🔹 APP ROOT
// // -------------------------------------------------------
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navKey,
//       debugShowCheckedModeBanner: false,
//       title: "Kaam Wala App",
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const SplashScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:kam_wala_app/firebase_options.dart';
import 'package:kam_wala_app/screens/splashscreen.dart';
import 'package:kam_wala_app/image crud hamdeling/workernotification.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


// -------------------------------------------------------
// 🔹 BACKGROUND HANDLER
// -------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("📩 Background message: ${message.data}");
}


// -------------------------------------------------------
// 🔹 OPEN PAGE
// -------------------------------------------------------
void _openWorkerNotificationPage({required String requestId}) {
  final ctx = navKey.currentContext;
  if (ctx == null) return;

  Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (_) => WorkerNotificationPage(requestId: requestId),
    ),
  );
}


// -------------------------------------------------------
// 🔹 HANDLE FCM CLICK
// -------------------------------------------------------
void handleNotificationClick(RemoteMessage message) {
  final data = message.data;

  if (data['screen'] == 'worker_notification' &&
      data['requestId'] != null) {
    _openWorkerNotificationPage(requestId: data['requestId']);
  }
}


// -------------------------------------------------------
// 🔹 MAIN
// -------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );
  }

  // -------------------------------------------------------
  // 🔔 ANDROID NOTIFICATION CHANNEL
  // -------------------------------------------------------
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for job requests',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // -------------------------------------------------------
  // 🔔 LOCAL NOTIFICATION INIT
  // -------------------------------------------------------
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidInit),
    onDidReceiveNotificationResponse: (details) {
      if (details.payload != null) {
        _openWorkerNotificationPage(requestId: details.payload!);
      }
    },
  );

  // -------------------------------------------------------
  // 🔐 PERMISSIONS (🔥 THIS FIXES YOUR ISSUE)
  // -------------------------------------------------------
  if (!kIsWeb) {
    // Notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Location permission
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    debugPrint("🔥 Android FCM Token: ${await messaging.getToken()}");
  }

  // -------------------------------------------------------
  // 🌐 WEB ONLY (VAPID KEY)
  // -------------------------------------------------------
  if (kIsWeb) {
    await FirebaseMessaging.instance.requestPermission();
    String? token = await FirebaseMessaging.instance.getToken(
      vapidKey: "BCUDNCX8SwCML4_V09q6m8cxnylE_q7Tzfu8MPhm_V0lvFAB5jSJJPKfbaBcHNE2qnVPRxDcJKFqJY0_hNlPmEU",
    );
    debugPrint("🔥 Web FCM Token: $token");
  }

  // -------------------------------------------------------
  // 🔹 FOREGROUND NOTIFICATION
  // -------------------------------------------------------
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null && message.data['requestId'] != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: message.data['requestId'],
      );
    }
  });

  // -------------------------------------------------------
  // 🔹 BACKGROUND → OPEN
  // -------------------------------------------------------
  FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationClick);

  // -------------------------------------------------------
  // 🔹 TERMINATED → OPEN
  // -------------------------------------------------------
  final initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    Future.delayed(const Duration(milliseconds: 500), () {
      handleNotificationClick(initialMessage);
    });
  }

  runApp(const MyApp());
}


// -------------------------------------------------------
// 🔹 APP ROOT
// -------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      title: "Kaam Wala App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
