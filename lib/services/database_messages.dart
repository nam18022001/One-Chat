import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMessages {
  addMessages(String chatRoomID, messageMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("chats")
        .doc()
        .set(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getMessages(String chatRoomID, int limit) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("chats")
        .orderBy("stt", descending: true)
        .limit(limit)
        .snapshots();
  }

  getChatRoom(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("usersEmail", arrayContains: userEmail)
        .orderBy("time", descending: true)
        .snapshots();
  }
}
