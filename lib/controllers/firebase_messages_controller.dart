import 'package:firebase_messaging/firebase_messaging.dart';

class FmECGFirebaseMessage {
  // final conversationsCollection = FirebaseFirestore.instance.collection("conversations");
  // final messagesCollection = FirebaseFirestore.instance.collection("messages");

  Future<String> getDeviceToken() async {
    final String? firebaseToken = await FirebaseMessaging.instance.getToken();
    return firebaseToken ?? "";
  }

  Future<void> saveTokenToFirestore(int userId, String firebaseToken) async {
    // await database.collection("user_tokens").add(
    //   {
    //     "user_id": userId,
    //     "firebase_token": firebaseToken
    //   }
    // );
  }
}