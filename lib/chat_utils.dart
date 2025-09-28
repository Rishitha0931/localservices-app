import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendMessage(String chatId, String senderId, String message) async {
  await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add({
    'senderId': senderId,
    'text': message,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

String getChatId(String vendorId, String customerId) {
  return vendorId.compareTo(customerId) < 0
      ? '${vendorId}_$customerId'
      : '${customerId}_$vendorId';
}
