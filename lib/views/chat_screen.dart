import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:one_chat_rebuild/call_method/call_ultilities.dart';
import 'package:one_chat_rebuild/enum/view_state.dart';
import 'package:one_chat_rebuild/provider/image_upload_provider.dart';
import 'package:one_chat_rebuild/resources/firebase_reponsi.dart';
import 'package:one_chat_rebuild/services/database_messages.dart';
import 'package:one_chat_rebuild/services/database_users.dart';
import 'package:one_chat_rebuild/utils/permissons.dart';
import 'package:one_chat_rebuild/views/Image_details.dart';
import 'package:one_chat_rebuild/views/call/pickup/pickup_layout.dart';
import 'package:one_chat_rebuild/widgets/cache_image.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  //
  final String chatRoomId;
  final String userName;
  final String userAvatar;
  final String userUid;
  ChatScreen(
      {Key key,
      @required this.chatRoomId,
      @required this.userName,
      @required this.userAvatar,
      @required this.userUid})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //

  ImageUploadProvider _imageUploadProvider;

  String myEmail = FirebaseAuth.instance.currentUser.email;
  String myUid = FirebaseAuth.instance.currentUser.uid;
  String myName = FirebaseAuth.instance.currentUser.displayName;

  DatabaseMessages databaseMessages = new DatabaseMessages();
  UserMethod userMethod = new UserMethod();
  TextEditingController messageTextInputController =
      new TextEditingController();
  FirebaseRepository _repository = FirebaseRepository();
  Stream chatMessageStrem;
  bool photo;
  ScrollController _listScrollController = ScrollController();
  bool showEmofiPicker = false;
  FocusNode texFieldFocus = FocusNode();
  bool isMessage;

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  FirebaseMessaging messaging;
  String _fcmToken;
  String userToken;
  bool existUserToken;
  bool userUnred;

  int perPage = 10;

  Widget chatMessagesList() {
    return StreamBuilder(
      stream: chatMessageStrem,
      builder: (context, snapshot) {
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _listScrollController.animateTo(
        //     _listScrollController.position.minScrollExtent,
        //     duration: Duration(milliseconds: 250),
        //     curve: Curves.easeInOut,
        //   );
        // });
        userMethod.readMessages(widget.chatRoomId, myEmail);
        userMethod
            .getUserUnReadChatScreen(widget.chatRoomId, myEmail)
            .then((val) {
          val.docs.length > 0 ? userUnred = true : userUnred = false;
        });

        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                controller: _listScrollController,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(top: 15),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  snapshot.data.docs[index].get("type") == "photo"
                      ? photo = true
                      : photo = false;
                  return _buildMessages(
                      snapshot.data.docs[index].get("message"),
                      snapshot.data.docs[index].get("time"),
                      snapshot.data.docs[index].get("sendBy") == myEmail,
                      photo == true
                          ? snapshot.data.docs[index].get("photoLink")
                          : "",
                      photo == true
                          ? snapshot.data.docs[index].get("photoName")
                          : "");
                },
              )
            : Container();
      },
    );
  }

  sendMessage() async {
    final QuerySnapshot<Map<String, dynamic>> increDocs =
        await FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(widget.chatRoomId)
            .collection("chats")
            .orderBy("stt", descending: false)
            .get();

    if (messageTextInputController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageTextInputController.text,
        "sendBy": myEmail,
        "isRead": false,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": "message",
        "stt":
            increDocs.docs.length > 0 ? increDocs.docs.last.get("stt") + 1 : 1,
      };
      databaseMessages.addMessages(widget.chatRoomId, messageMap);

      messageTextInputController.clear();
    }
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(widget.chatRoomId)
        .update({
      "time": DateTime.now().millisecondsSinceEpoch,
    });
  }

  pickImage({@required ImageSource source}) async {
    var list = new List<int>.generate(1000, (int index) => index);
    list.shuffle();
    String bcrypt = new DBCrypt()
        .hashpw(list.toString(), new DBCrypt().gensalt())
        .toString()
        .replaceAll("/", "-");

    final String name =
        "${FirebaseAuth.instance.currentUser.email + "-" + bcrypt}";
    File selectedImage;

    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      _repository.uploadImage(
          image: selectedImage,
          sendBy: myEmail,
          chatRoomID: widget.chatRoomId,
          name: name,
          imageUploadProvider: _imageUploadProvider);
    }
  }

  checkUserRead() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userUid.trim())
        .get();
    setState(() {
      if (doc.get("fcmToken").toString().isNotEmpty) {
        existUserToken = true;
        userToken = doc.get("fcmToken").toString();
      } else {
        existUserToken = false;
      }
    });
  }

  myToken() async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection("users").doc(myUid).get();

    setState(() {
      if (doc.get("fcmToken").toString().isNotEmpty) {
        _fcmToken = doc.get("fcmToken").toString();
      }
    });
  }

  getMoreMessages() async {
    int increLimit = perPage;
    setState(() {
      perPage = increLimit + 10;
    });
    databaseMessages.getMessages(widget.chatRoomId, perPage).then((val) {
      setState(() {
        chatMessageStrem = val;
      });
    });
  }

  @override
  void initState() {
    databaseMessages.getMessages(widget.chatRoomId, perPage).then((value) {
      setState(() {
        chatMessageStrem = value;
      });
    });
    _initialization.whenComplete(() {
      messaging = FirebaseMessaging.instance;
    });
    checkUserRead();
    myToken();
    _listScrollController.addListener(() {
      double maxScroll = _listScrollController.position.maxScrollExtent;
      double currentScroll = _listScrollController.position.pixels;

      if (maxScroll == currentScroll) {
        setState(() {
          getMoreMessages();
        });
      }
    });
    super.initState();
  }

  _buildMessages(
    String message,
    int time,
    bool sendByMe,
    String photoUrl,
    String photoName,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: sendByMe ? 0 : 8,
        right: sendByMe ? 8 : 0,
      ),
      margin: sendByMe
          ? EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: 100,
            )
          : EdgeInsets.only(
              top: 8,
              bottom: 8,
              right: 100,
            ),
      width: MediaQuery.of(context).size.width,
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: sendByMe ? Colors.pink.shade50 : Colors.pink.shade200,
          borderRadius: sendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (DateTime.now().day -
                              DateTime.fromMillisecondsSinceEpoch(time).day >=
                          1
                      ? DateFormat('dd/MM/yyyy - h:m')
                          .format(DateTime.fromMillisecondsSinceEpoch(time))
                      : DateFormat.jm()
                          .format(DateTime.fromMillisecondsSinceEpoch(time)))
                  .toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            photo == true
                ? GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetail(
                          url: photoUrl,
                          name: widget.userName,
                          chatRoomId: widget.chatRoomId,
                          photoName: photoName,
                        ),
                      ),
                    ),
                    child: CacheImage(
                      url: photoUrl,
                    ),
                  )
                : Text(
                    message,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              pickImage(source: ImageSource.camera);
            },
            color: Theme.of(context).primaryColor,
            iconSize: 25,
          ),
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () {
              pickImage(source: ImageSource.gallery);
            },
            color: Theme.of(context).primaryColor,
            iconSize: 25,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: messageTextInputController,
                  textCapitalization: TextCapitalization.sentences,
                  focusNode: texFieldFocus,
                  onTap: () => hideEmojiContainer(),
                  decoration: InputDecoration(
                    hintText: "Send a message ...",
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.face),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    if (!showEmofiPicker) {
                      hideKeyBoard();
                      showEmojiContainer();
                    } else {
                      showKeyBoard();
                      hideEmojiContainer();
                    }
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              print(existUserToken);
              print(userUnred);
              sendMessage();
              setState(() {
                isMessage = true;
              });
              existUserToken == true && userUnred == true
                  ? await _sendAndRetrieveMessage()
                  : print("error");
            },
            color: Theme.of(context).primaryColor,
            iconSize: 25,
          ),
        ],
      ),
    );
  }

  showKeyBoard() => texFieldFocus.requestFocus();

  hideKeyBoard() => texFieldFocus.unfocus();

  emojiContainer() {
    return EmojiPicker(
      onEmojiSelected: (emoji, category) {
        messageTextInputController.text =
            messageTextInputController.text + emoji.emoji;
      },
      bgColor: Colors.white,
      indicatorColor: Colors.blue,
      rows: 4,
      columns: 7,
    );
  }

  hideEmojiContainer() {
    setState(() {
      showEmofiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmofiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.userAvatar),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.video_call),
                    onPressed: () async {
                      setState(() {
                        isMessage = false;
                      });
                      await _sendAndRetrieveMessage();

                      await Permissions.cameraAndMicrophonePermissionsGranted()
                          ? CallUtils.dial(
                              uid: FirebaseAuth.instance.currentUser.uid,
                              name:
                                  FirebaseAuth.instance.currentUser.displayName,
                              photo: FirebaseAuth.instance.currentUser.photoURL,
                              userUid: widget.userUid,
                              userName: widget.userName,
                              userPhoto: widget.userAvatar,
                              context: context,
                            )
                          : {};
                    },
                  ),
                ],
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: chatMessagesList(),
                    )),
              ),
              _imageUploadProvider.getViewState == ViewState.LOADING
                  ? Container(
                      height: 50,
                      color: Colors.white,
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ],
                      ))
                  : Container(),
              _buildMessageComposer(),
              showEmofiPicker == true
                  ? Container(
                      child: emojiContainer(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendAndRetrieveMessage() async {
    const yourServerKey =
        "AAAAxyk1MTs:APA91bHYFFePTjU3IgIGdWx0iVW9NjfF7o_JAHU9OlwAhJWj9YNb5Llz4EWP7efu-qHlSOE409AQ2nFDf5rbLfRoUYqDSf2g7ej1IV5c_qUvqYh_5GITZzNVJmuwllkm5qgQz_G6Qf41";
    await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$yourServerKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': isMessage == true
                ? 'You have a message from $myName'
                : 'You have a video call from $myName',
            'title': 'One Chat',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          // FCM Token lists.
          'registration_ids': [
            _fcmToken,
            userToken,
          ],
        },
      ),
    );
  }
}
