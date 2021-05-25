import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:one_chat_rebuild/services/auth.dart';
import 'package:one_chat_rebuild/services/database_users.dart';
import 'package:one_chat_rebuild/services/search_user.dart';
import 'package:one_chat_rebuild/views/call/pickup/pickup_layout.dart';
import 'package:one_chat_rebuild/views/chat_screen.dart';
import 'package:one_chat_rebuild/views/database_chat_method.dart';
import 'package:one_chat_rebuild/views/home_screen.dart';

class AddScreen extends StatefulWidget {
  AddScreen({Key key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  //
  String myEmail = FirebaseAuth.instance.currentUser.email;
  String myUid = FirebaseAuth.instance.currentUser.uid;
  Database database = new Database();
  UserMethod userMethod = new UserMethod();
  TextEditingController searchText = new TextEditingController();
  SearchUser searchUser = new SearchUser();

  bool exist;
  String roomID;
  QuerySnapshot searchSnapshot;
  initateSearch() {
    searchUser.getUserByEmail(searchText.text).then((value) {
      setState(() {
        value.docs.length > 0
            ? searchSnapshot = value
            : Fluttertoast.showToast(
                msg: "This user is not exist",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0,
              );
      });
    });
  }

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTitle(
                searchSnapshot.docs[index].get("displayName"),
                searchSnapshot.docs[index].get("email"),
                searchSnapshot.docs[index].get("photoUrl"),
                searchSnapshot.docs[index].get("uid"),
              );
            })
        : Container();
  }

  createChatRoomAndStartConversation(
      String userEmail, String userUID, String userName, String userAvatar) {
    if (userEmail != myEmail) {
      String chatroomID = getChatRoomId(userUID, myUid);
      List<String> usersUid = [userUID, myUid];
      List<String> usersEmail = [userEmail, myEmail];
      Map<String, dynamic> chatRoomMap = {
        "usersUid": usersUid,
        "usersEmail": usersEmail,
        "chatroomID": chatroomID,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      database.createChatRoom(chatroomID, chatRoomMap);
      userMethod.readMessages(chatroomID, myEmail);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(
                    chatRoomId: chatroomID,
                    userName: userName,
                    userAvatar: userAvatar,
                    userUid: userUID,
                  )));
    } else {
      Fluttertoast.showToast(
        msg: "This is yourself, you can't do that",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  getChatRoom() async {
    List<String> email = [myEmail, searchText.text];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("usersEmail", isEqualTo: email)
        .get();

    setState(() {
      querySnapshot.docs.length > 0 ? exist = true : exist = false;
      exist == true
          ? roomID = querySnapshot.docs.first.id.toString()
          : print("he");
    });
    userMethod.readMessages(roomID, myEmail);
  }

  @override
  void initState() {
    getChatRoom();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (contect) => HomeScreen(auth: Auth()))),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Text(
            "Search your friend",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: "Times",
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                color: Colors.black87,
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchText,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Input email of your friend',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // initateSearch();
                        searchText.text.isNotEmpty
                            // ignore: unnecessary_statements
                            ? initateSearch() + getChatRoom()
                            : Fluttertoast.showToast(
                                msg: "Please input something",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                      },
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0x36FFFFFF),
                            Color(0x3FFFFFFF),
                          ]),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              searchList()
            ],
          ),
        ),
      ),
    );
  }

  Widget SearchTitle(
      String displayName, String email, String photoUrl, String uid) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            child: CircleAvatar(
              backgroundImage: NetworkImage(photoUrl),
              radius: 30,
            ),
            height: 45,
            width: 45,
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                email,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              exist == false
                  ? createChatRoomAndStartConversation(
                      email, uid, displayName, photoUrl)
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatRoomId: roomID,
                          userName: displayName,
                          userAvatar: photoUrl,
                          userUid: uid,
                        ),
                      ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                "Message",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
