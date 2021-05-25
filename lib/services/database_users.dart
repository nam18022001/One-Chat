import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserMethod {
  User currentUser = FirebaseAuth.instance.currentUser;
  final user = FirebaseFirestore.instance.collection("users");

  addUser() async {
    Map<String, String> userInfoMap = {
      "uid": currentUser.uid,
      "displayName": currentUser.displayName,
      "email": currentUser.email,
      "photoUrl": currentUser.photoURL,
      "fcmToken": ""
    };
    user
        .doc(currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) => {
              if (!documentSnapshot.exists)
                {user.doc(currentUser.uid).set(userInfoMap)}
            });
  }

  updateFcmToken(String uid, String token) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"fcmToken": token});
  }

  deleteFcmToken(String uid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"fcmToken": ""});
  }

  getUserById(String uid) async {
    return await FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  getUserUnRead(String idChatRoom, String myEmail) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(idChatRoom)
        .collection("chats")
        .where("sendBy", isNotEqualTo: myEmail)
        .where("isRead", isEqualTo: false)
        .snapshots();
  }

  getUserUnReadChatScreen(String idChatRoom, String myEmail) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(idChatRoom)
        .collection("chats")
        .where("sendBy", isEqualTo: myEmail)
        .where("isRead", isEqualTo: false)
        .get();
  }

  readMessages(String chatRoomId, myEmail) async {
    final String chatRommId = chatRoomId;
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRommId)
        .collection("chats")
        .where("sendBy", isNotEqualTo: myEmail)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.update({
          "isRead": true,
        });
      });
    });
  }

  getStreamMessages(String chatRoomID) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("chats")
        .orderBy("stt", descending: false)
        .snapshots();
  }
}
