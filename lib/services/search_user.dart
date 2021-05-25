import 'package:cloud_firestore/cloud_firestore.dart';

class SearchUser {
  getUserByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
  }
}
