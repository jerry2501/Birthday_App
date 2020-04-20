import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  int i=0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializing();

  }
  void initializing() async{
    androidInitializationSettings=AndroidInitializationSettings('app_icon');
    iosInitializationSettings=IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings=InitializationSettings(androidInitializationSettings,iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
  }
  void _showNotification() async{
    await notificaion();
  }
  void _showSchduledNotification() async{
    await scheduledNotification();
  }

  Future<void> notificaion() async{
    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
        'Channel _ID',
        'Channel title',
        'Channel body',
        priority: Priority.High,
        importance: Importance.Max,
        ticker: 'Test'
    );
    IOSNotificationDetails iosNotificationDetails=IOSNotificationDetails();
    NotificationDetails notificationDetails=NotificationDetails(androidNotificationDetails,iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, "Special Days", "Birthday here", notificationDetails);
  }

  Future<void> scheduledNotification() async{
    var timeDelayed=DateTime.now().add(Duration(seconds: 5));
    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
        '$i Channel _ID',
        '$i Channel title',
        '$i Channel body',
        priority: Priority.High,
        importance: Importance.Max,
        ticker: 'Test'
    );
    IOSNotificationDetails iosNotificationDetails=IOSNotificationDetails();
    NotificationDetails notificationDetails=NotificationDetails(androidNotificationDetails,iosNotificationDetails);
    await flutterLocalNotificationsPlugin.schedule(i, "Special Days", "Birthday here",timeDelayed, notificationDetails);
  }

  Future onSelectNotification(String payload){
    if(payload!=null){
      print(payload);
    }
    //navigate page code here

  }

  Future onDidReceiveLocalNotification(int id,String title,String body,String payload) async{
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(child: Text("okay"),onPressed: (){
          print("");
        },)
      ],
    );
  }

  Future cancelNotification() async{
    await flutterLocalNotificationsPlugin.cancel(i-1);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: FlatButton(
              child: Text("Notification"),
              onPressed:(){
                _showSchduledNotification();
                setState(() {
                  i++;
                });
              } ,
            ),
          ),
          Center(
            child: FlatButton(
              child: Text(" Cancel Notification"),
              onPressed:(){
                cancelNotification();

              } ,
            ),
          ),
        ],
      )
    );
  }

}