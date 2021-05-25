import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:one_chat_rebuild/provider/image_upload_provider.dart';
import 'package:one_chat_rebuild/services/database_messages.dart';

class ImageMethod {
  Reference _storageReference;
  Future<String> uploadImageToStorage(
      File imageFile, String chatRoomId, String randName) async {
    try {
      _storageReference =
          FirebaseStorage.instance.ref(chatRoomId).child(randName);
      UploadTask storageUploadTask = _storageReference.putFile(imageFile);

      final snapshot = await storageUploadTask.whenComplete(() {});
      final urlLink = await snapshot.ref.getDownloadURL();

      return urlLink;
    } catch (e) {
      return null;
    }
  }

  void setImageMsg(
      String chatRoomId, String url, String sendBy, String namePhoto) async {
    DatabaseMessages databaseMessages = new DatabaseMessages();
    final QuerySnapshot<Map<String, dynamic>> increDocs =
        await FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(chatRoomId)
            .collection("chats")
            .orderBy("stt", descending: false)
            .get();

    Map<String, dynamic> messageMap = {
      "message": "Image",
      "sendBy": sendBy,
      "isRead": false,
      "time": DateTime.now().millisecondsSinceEpoch,
      "stt": increDocs.docs.length > 0 ? increDocs.docs.last.get("stt") + 1 : 1,
      "type": "photo",
      "photoLink": url,
      "photoName": namePhoto,
    };
    String idDoc = increDocs.docs.length > 0
        ? (increDocs.docs.last.get("stt") + 1).toString()
        : 1.toString();
    databaseMessages.addMessages(chatRoomId, messageMap);
  }

  void uploadImage(File image, String sendBy, String chatRoomID, String name,
      ImageUploadProvider imageUploadProvider) async {
    imageUploadProvider.setToLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image, chatRoomID, name);
    // Hide loading
    imageUploadProvider.setToIdle();

    setImageMsg(chatRoomID, url, sendBy, name);
  }
}
