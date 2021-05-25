import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_chat_rebuild/call_method/call.dart';
import 'package:one_chat_rebuild/call_method/call_method.dart';
import 'package:one_chat_rebuild/views/call/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();
  static dial(
      {String uid,
      name,
      photo,
      String userUid,
      userName,
      userPhoto,
      BuildContext context}) async {
    Call call = Call(
      callerId: uid,
      callerName: name,
      callerAvatar: photo,
      receiverId: userUid,
      receiverName: userName,
      receiverAvatar: userPhoto,
      channelId: Random().nextInt(1000).toString(),
    );
    bool callMade = await callMethods.makeCall(call: call);
    call.hasDialled = true;
    if (callMade) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CallScreen(call: call)));
    }
  }
}
