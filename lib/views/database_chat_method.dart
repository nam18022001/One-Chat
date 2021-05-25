import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  createChatRoom(String chatromID, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatromID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }
}
