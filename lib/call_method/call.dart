class Call {
  String callerId;
  String callerName;
  String callerAvatar;
  String receiverId;
  String receiverName;
  String receiverAvatar;
  String channelId;
  bool hasDialled;
  Call({
    this.callerId,
    this.callerName,
    this.callerAvatar,
    this.receiverId,
    this.receiverName,
    this.receiverAvatar,
    this.channelId,
    this.hasDialled,
  });
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    // callMap["idDoc"] = "null";
    callMap["caller_id"] = call.callerId;
    callMap["caller_name"] = call.callerName;
    callMap["caller_avatar"] = call.callerAvatar;
    callMap["receiver_id"] = call.receiverId;
    callMap["receiver_name"] = call.receiverName;
    callMap["receiver_avatar"] = call.receiverAvatar;
    callMap["channel_id"] = call.channelId;
    callMap["has_dialled"] = call.hasDialled;
    return callMap;
  }

  Call.fromMap(Map<String, dynamic> callMap) {
    this.callerId = callMap["caller_id"];
    this.callerName = callMap["caller_name"];
    this.callerAvatar = callMap["caller_avatar"];
    this.receiverId = callMap["receiver_id"];
    this.receiverName = callMap["receiver_name"];
    this.receiverAvatar = callMap["receiver_avatar"];
    this.channelId = callMap["channel_id"];
    this.hasDialled = callMap["has_dialled"];
  }
}
