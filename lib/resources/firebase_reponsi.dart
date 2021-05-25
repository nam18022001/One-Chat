import 'dart:io';

import 'package:flutter/material.dart';
import 'package:one_chat_rebuild/provider/image_upload_provider.dart';
import 'package:one_chat_rebuild/resources/uploadingImg_method.dart';

class FirebaseRepository {
  ImageMethod _firebaseMethods = ImageMethod();

  // void uploadImageMsgToDb(String url, String receiverId, String senderId) =>
  //     _firebaseMethods.setImageMsg(url, receiverId, senderId);

  void uploadImage(
          {@required File image,
          @required String sendBy,
          @required String chatRoomID,
          @required String name,
          @required ImageUploadProvider imageUploadProvider}) =>
      _firebaseMethods.uploadImage(
        image,
        sendBy,
        chatRoomID,
        name,
        imageUploadProvider,
      );
}
