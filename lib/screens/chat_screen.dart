import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

final _firestore = FirebaseFirestore.instance;
final _firebasemessaging = FirebaseMessaging.instance;
User? loggedinUser;
DateTime currentPhoneDate = DateTime.now();
Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);
DateTime myDateTime = myTimeStamp.toDate();

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? _message;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    print(loggedinUser);
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser!;
      _auth.currentUser?.reload();
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void registerNotification() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('message data $_message');
    });
  }

  void SendNotification() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: messageStream(),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 30.0,
                    child: FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueGrey[400],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) {
                        messageTextController.clear();
                        currentPhoneDate = DateTime.now();
                        myTimeStamp = Timestamp.fromDate(currentPhoneDate);
                        myDateTime = myTimeStamp.toDate();
                        if (_message != '') {
                          _firestore.collection('messages').add({
                            'text': _message,
                            'sender': loggedinUser?.email,
                            'createdAt': myDateTime,
                          });
                          _message = '';
                        }
                      },
                      textInputAction: TextInputAction.done,
                      controller: messageTextController,
                      onChanged: (value) {
                        _message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  SizedBox(
                    width: 50.0,
                    child: PopupMenuButton(
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: 'Photo',
                            child: Icon(
                              Icons.photo,
                              color: Colors.blueGrey[400],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Person',
                            child: Icon(
                              Icons.person,
                              color: Colors.blueGrey[400],
                            ),
                          )
                        ];
                      },
                    ),
                  ),
                  SizedBox(
                    width: 30.0,
                    child: FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.blueGrey[400],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30.0,
                    child: FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: Icon(
                        Icons.mic,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class messageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection('messages').orderBy('createdAt').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }

          List<messageBubble> messageBubbles = [];
          for (var message in snapshot.data!.docs.reversed) {
            final sender = message['sender'];
            final text = message['text'];
            final currentUser = loggedinUser?.email;
            final messagebubble = messageBubble(
              sender: sender,
              text: text,
              isMe: currentUser == sender,
              time: message['createdAt'].toDate(),
            );
            messageBubbles.add(messagebubble);
          }
          return ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: messageBubbles,
          );
        });

    // if (snapshot.hasData) {
    //   return ListView(
    //     padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
    //     children: (snapshot.data?.docs
    //             .map((e) => messageBubble(
    //                   sender: ,
    //                   isMe: currentUser == e['sender'],
    //                 ))
    //             .toList())!
    //         .toList(),
    //   );
  }
}

class messageBubble extends StatelessWidget {
  messageBubble(
      {required this.sender,
      this.isMe,
      required this.text,
      required this.time});
  final sender;
  final text;
  bool? isMe;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          !isMe! ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          '$sender',
          style: TextStyle(color: Colors.black54, fontSize: 12.0),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Material(
            borderRadius: !isMe!
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0)),
            elevation: 5.0,
            color: !isMe! ? Colors.white : Colors.lightBlueAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: !isMe!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$text',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: !isMe! ? Colors.black : Colors.white),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          '${time.hour}:${time.minute}',
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${time.hour}:${time.minute}',
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          '$text',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: !isMe! ? Colors.black : Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
