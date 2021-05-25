import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one_chat_rebuild/services/database_messages.dart';
import 'package:one_chat_rebuild/services/database_users.dart';
import 'package:one_chat_rebuild/views/chat_screen.dart';

class ListChatUser extends StatefulWidget {
  final BuildContext context;
  ListChatUser({Key key, this.context}) : super(key: key);

  @override
  _ListChatUserState createState() => _ListChatUserState();
}

class _ListChatUserState extends State<ListChatUser> {
  //
  DatabaseMessages databaseMessages = new DatabaseMessages();

  String myEmail = FirebaseAuth.instance.currentUser.email;
  String myUid = FirebaseAuth.instance.currentUser.uid;
  Stream chatRoomStream;
  @override
  void initState() {
    databaseMessages.getChatRoom(myEmail).then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
          child: StreamBuilder(
            stream: chatRoomStream,
            builder: (contex, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return RecentChats(
                          userUid: snapshot.data.docs[index]
                              .get("chatroomID")
                              .toString()
                              .replaceAll("_", "")
                              .replaceAll(myUid, ""),
                          chatRoom: snapshot.data.docs[index].get("chatroomID"),
                        );
                      },
                    )
                  : Container();
            },
          ),
        ),
      ),
    );
  }
}

class RecentChats extends StatefulWidget {
  RecentChats({Key key, this.userUid, this.chatRoom}) : super(key: key);
  final String userUid;
  final String chatRoom;
  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  String avatar;
  String name;
  String email;
  bool unread;
  Stream stream;
  QuerySnapshot docSnapshot;
  Stream messages;
  // DocumentSnapshot list;
  final String myEmail = FirebaseAuth.instance.currentUser.email;
  UserMethod userMethod = new UserMethod();
  @override
  void initState() {
    getUserById();
    unreadMethod();
    streamMessagesSend();
    super.initState();
  }

  unreadMethod() async {
    final String idChatRoom = widget.chatRoom;
    final Stream<QuerySnapshot<Map<String, dynamic>>> doc =
        await userMethod.getUserUnRead(idChatRoom, myEmail);
    setState(() {
      stream = doc;
    });
  }

  streamMessagesSend() async {
    final Stream<QuerySnapshot<Map<String, dynamic>>> message =
        await userMethod.getStreamMessages(widget.chatRoom);
    setState(() {
      messages = message;
    });
  }

  getUserById() async {
    final String id = widget.userUid.toString().trim();
    final DocumentSnapshot doc = await userMethod.getUserById(id);

    setState(() {
      name = doc.get("displayName");
      avatar = doc.get("photoUrl");
      email = doc.get("email");
      // list = doc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        userMethod.readMessages(widget.chatRoom, myEmail);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: widget.chatRoom,
              userName: name,
              userAvatar: avatar,
              userUid: widget.userUid,
            ),
          ),
        );
      },
      onLongPress: () {},
      child: Container(
        child: StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            snapshot.hasData
                ? snapshot.data.docs.length > 0
                    ? unread = false
                    : unread = true
                : null;
            return Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder(
                stream: messages,
                builder: (context, snap) {
                  return snap.hasData
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage: NetworkImage(
                                      avatar != null ? avatar : ""),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name != null ? name : "",
                                      style: TextStyle(
                                        color: unread == false
                                            ? Colors.black
                                            : Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(
                                        snap.data.docs.length > 0
                                            ? snap.data.docs.last
                                                        .get("sendBy") ==
                                                    myEmail
                                                ? "You: " +
                                                    snap.data.docs.last
                                                        .get("message")
                                                : snap.data.docs.last
                                                    .get("message")
                                            : email != null
                                                ? email
                                                : "",
                                        style: TextStyle(
                                          color: unread == false
                                              ? Colors.black
                                              : Colors.blueGrey,
                                          fontSize: 15,
                                          fontWeight: unread == false
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  snapshot.hasData
                                      ? snapshot.data.docs.length > 0
                                          ? (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(snapshot.data.docs.last.get("time"))).inDays.toInt() != 0
                                                  ? DateFormat('dd/MM/yyyy')
                                                      .format(DateTime.fromMillisecondsSinceEpoch(
                                                          snapshot.data.docs.last
                                                              .get("time")))
                                                      .toString()
                                                  : DateFormat.jm()
                                                      .format(
                                                          DateTime.fromMillisecondsSinceEpoch(
                                                              snapshot.data.docs
                                                                  .last
                                                                  .get("time")))
                                                      .toString())
                                              .toString()
                                          : snap.data.docs.length > 0
                                              ? (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(snap.data.docs.last.get("time"))).inDays.toInt() != 0
                                                      ? DateFormat('dd/MM/yyyy')
                                                          .format(DateTime.fromMillisecondsSinceEpoch(snap.data.docs.last.get("time")))
                                                          .toString()
                                                      : DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(snap.data.docs.last.get("time"))).toString())
                                                  .toString()
                                              : ""
                                      : "",
                                  style: TextStyle(
                                      color: unread == false
                                          ? Colors.black
                                          : Colors.blueGrey,
                                      fontSize: 15,
                                      fontWeight: unread == false
                                          ? FontWeight.bold
                                          : null),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                unread == false
                                    ? Container(
                                        width: 40,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        alignment: Alignment.center,
                                        child: Text(
                                          snapshot.data.docs.length.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ],
                        )
                      : Container();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
