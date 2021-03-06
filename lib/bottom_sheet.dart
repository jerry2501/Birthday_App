import 'package:birthdayapp/Authentication/database.dart';
import 'package:birthdayapp/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';

class sheet extends StatefulWidget
{
  String event;
  Map userdocument;
  sheet(this.event,this.userdocument);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return sheetState();
  }

}
class sheetState extends State<sheet>
{

  String name,date,id;
  DateFormat _dateFormat=new DateFormat.yMMMMd();
   DateFormat _day=new DateFormat.d();
  DateFormat _month=new DateFormat.M();
  int month,day,smsid;
  bool state;

  DateTime _date;
  final GlobalKey<FormState> formkey=GlobalKey<FormState>();
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

  void _showSchduledNotification(DateTime date,int id) async{
    await scheduledNotification(date,id);
  }


  Future<void> scheduledNotification(DateTime date,int id) async{
    var timeDelayed=date.add(Duration(hours: widget.userdocument['Notification_hour'],minutes: widget.userdocument['Notification_minute']));
    print(timeDelayed);
    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
        '$id Channel _ID',
        '$id Channel title',
        '$id Channel body',
        priority: Priority.High,
        importance: Importance.Max,
        ticker: 'Test'
    );

    IOSNotificationDetails iosNotificationDetails=IOSNotificationDetails();
    NotificationDetails notificationDetails=NotificationDetails(androidNotificationDetails,iosNotificationDetails);
    await flutterLocalNotificationsPlugin.schedule(id, "Special Days", name+"'s "+widget.event+" today",timeDelayed, notificationDetails);
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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Container(
     padding: EdgeInsets.all(30.0),
     child: state==false?
         Center(child: CircularProgressIndicator(),):Wrap(
       crossAxisAlignment: WrapCrossAlignment.center,

       children: <Widget>[
         SizedBox(height: 10.0,),
         Text("Add New "+widget.event,style: TextStyle(fontSize: 24,fontFamily: "R",color: Colors.blue),),
         Padding(
           padding: EdgeInsets.only(
               bottom: MediaQuery.of(context).viewInsets.bottom),
           child: Form(
             key:formkey,
             child: Column(
               children: <Widget>[

                 TextFormField(
                   autofocus: true,
                   decoration: const InputDecoration(
                     icon: Icon(Icons.person),
                     hintText: 'Enter the name of person',
                     labelText: 'Name',

                   ),
                   onChanged: (value){
                     setState(() {
                       name=value.toUpperCase();
                     });
                   },
                   validator: (value){
                     if(value.isEmpty)
                     {
                       return "Please Enter Name";
                     }
                   },
                 ),

                 SizedBox(height: 15,),
                 Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
                   children: <Widget>[
                     Icon(
                       Icons.calendar_view_day,

                     ),
                     SizedBox(width: 15,),
                     Text(_date==null?'Nothing is selected':_dateFormat.format(_date).toString()),
                     IconButton(icon:Icon(Icons.calendar_today) , onPressed:() {
                       Future<DateTime> selectedDate=showDatePicker(context: context, initialDate: DateTime.now(),
                           firstDate: DateTime(1900), lastDate: DateTime(4000),
                           builder: (BuildContext context,Widget child){
                             return Theme(
                               data: ThemeData.dark(),
                               child: child,
                             );
                           }
                       ).then((eventdate){
                         setState(() {
                           _date=eventdate;
                           date=_dateFormat.format(_date).toString();
                         });
                       });
                     })
                   ],
                 ),
                 SizedBox(height: 15,),
                 RaisedButton(child: Text("Create",style:TextStyle(color: Colors.white),),
                   elevation: 10,
                   hoverColor: Colors.lightBlueAccent,
                   color: Colors.blue,
                   onPressed: (){
                     setdata();
                   },
                 )
               ],
             ),
           ),
         )
       ],
     ),
   );
  }

  Future setdata() async{
    final formState=formkey.currentState;
    String e=widget.event;
    int token;
    if(_date!=null) {
      setState(() {
        day= int.parse(DateFormat("d").format(_date));
        month=int.parse(DateFormat("M").format(_date));

        id="$month $day$name$e";
      });
      if(day.toString().length==1){setState(() {
        token=int.parse(month.toString()+(day*10).toString());
      });}
      else{
        setState(() {
          token=int.parse(month.toString()+(day).toString());

        });
      }
      if (formState.validate()) {
        setState(() {
          state=false;
          smsid=int.parse(token.toString()+DateTime.now().hour.toString()+DateTime.now().minute.toString()+(DateTime.now().second).toString());
        });
        formState.save();
        FocusScope.of(context).requestFocus(FocusNode());
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        print(_month.format(_date).toString());
        await DatbaseSevice(uid: user.uid).createEvent(
            widget.event, name, date,id,token,smsid);
        Navigator.pop(context);
        DateTime ndate;
        int sid=smsid;
        for(int i=0;i<=10;i++){

          setState(() {
            ndate = DateTime.parse("${DateTime.now().year+i}-0$month-$day 00:00:00.000");
          });

          _showSchduledNotification(ndate,sid);
          setState(() {
            sid++;
          });
        }
        setState(() {
          state=true;
        });
        Navigator.push(context,
            PageTransition(type: PageTransitionType.fade, child: Home()));
        Toast.show("Event created!!", context, duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER);
      }
      else{
        Toast.show("Date Can't be null!!", context, duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER);
      }
    }
  }
}
