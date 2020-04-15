import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class MessageHandler extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return MessageHandlerState();
  }

}
class MessageHandlerState extends State<MessageHandler>
{
  final FirebaseMessaging _messaging=FirebaseMessaging();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _messaging.getToken().then((value){
      print(value);
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

  }

}