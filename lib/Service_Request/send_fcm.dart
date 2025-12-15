import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

/// ⚠️ TESTING ONLY – DO NOT USE IN PRODUCTION
Future<void> sendNotificationToWorker({
  required String token,
  required String title,
  required String body,
  required String requestId,
}) async {
  try {
    // 1️⃣ Load service account JSON
    final jsonString =
        await rootBundle.loadString('assets/service-account.json');
    final serviceAccount = jsonDecode(jsonString);

    // 2️⃣ Auth credentials
    final credentials =
        ServiceAccountCredentials.fromJson(serviceAccount);

    const scopes = [
      'https://www.googleapis.com/auth/firebase.messaging'
    ];

    final client =
        await clientViaServiceAccount(credentials, scopes);

    // 3️⃣ FCM v1 endpoint
    final projectId = serviceAccount['project_id'];
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    // 4️⃣ Payload
    final payload = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "requestId": requestId,
          "screen": "worker_request",
        },
        "android": {
          "priority": "HIGH",
        }
      }
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      debugPrint("✅ FCM sent to worker");
    } else {
      debugPrint(
        "❌ FCM failed ${response.statusCode}: ${response.body}",
      );
    }

    client.close();
  } catch (e) {
    debugPrint("❌ FCM exception: $e");
  }
}
