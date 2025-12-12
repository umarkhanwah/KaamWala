import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPushNotification({
  required String token,
  required String title,
  required String body,
  required Map<String, dynamic> data,
}) async {
  const String serverKey =
      "AAAAf7...... YOUR SERVER KEY HERE ....1234"; // From Firebase Console

  final url = Uri.parse("https://fcm.googleapis.com/fcm/send");

  final message = {
    "to": token,
    "notification": {
      "title": title,
      "body": body,
    },
    "data": data, // For screen redirection
  };

  await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "key=$serverKey",
    },
    body: jsonEncode(message),
  );
}
