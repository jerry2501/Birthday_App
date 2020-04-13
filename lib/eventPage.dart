import 'package:birthdayapp/HomePage.dart';
import 'package:birthdayapp/editSheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';


import 'package:toast/toast.dart';

class eventPage extends StatefulWidget{
  Map<String,dynamic> map;
  eventPage(this.map);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return eventPageState();
  }

}
class eventPageState extends State<eventPage>
{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

          body:Stack(
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(image: new AssetImage("images/download.jpg",),fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  ),
                ),
              ),
              Center(
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag:widget.map['Uid'],
                      child: ClipOval(
                        child: Image.asset('images/avatar.jpg',height: 100,width: 100,),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.map['Name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,fontFamily: "R",color: Colors.lightBlue),),),
                    SizedBox(height: 5,),
                    Divider(
                      thickness: 2,
                    ),
                    SizedBox(height: 15,),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.event_note,
                            color: Colors.blue,
                            size: 25,
                          ),
                          SizedBox(width: 10,),

                          Text("Event : ",style: TextStyle(fontFamily: "R",fontSize: 16,color: Colors.blue,fontWeight: FontWeight.bold),),
                          Text(widget.map['Event'],style: TextStyle(fontFamily: "R",fontSize: 16),)
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.event_note,
                            color: Colors.blue,
                            size: 25,
                          ),
                          SizedBox(width: 10,),

                          Text("Date : ",style: TextStyle(fontFamily: "R",fontSize: 16,color: Colors.blue,fontWeight: FontWeight.bold),),
                          Text(widget.map['Date'],style: TextStyle(fontFamily: "R",fontSize: 16),)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.add_event,
        child: Icon(Icons.star),
        overlayColor: Colors.lightBlueAccent,
        overlayOpacity: 0.2,
        curve: Curves.easeIn,
        closeManually: false,
        children: [
          SpeedDialChild(
            child: Icon(Icons.edit),
            label: "Edit Event",
            backgroundColor: Colors.blue,
            onTap: (){
              bottom(context);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            label: "Delete event",
            backgroundColor: Colors.blue,
            onTap: (){
              deleteEvent();
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.send),
            label: "Send message",
            backgroundColor: Colors.blue,
            onTap: (){
                  sendMessage();
            },
          )
        ],
      ),
    );
  }

  bottom(BuildContext context)
  {
    showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        useRootNavigator: true,
        context: context,
        /*bottom sheet is like a drawer that pops off where you can put any
      controls you want, it is used typically for user notifications*/
        //builder lets your code generate the code
        builder: (context) {
          return editSheet(widget.map);
        });

  }

  Future deleteEvent() async{
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection('users').document(user.uid).collection('events').document(widget.map['Uid']).delete();
    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: Home()));
    Toast.show("Event deleted!!\nPlease Refresh home Page", context, duration: Toast.LENGTH_LONG, gravity:Toast.BOTTOM);
  }

  Future sendMessage() async{
    FlutterOpenWhatsapp.sendSingleMessage("","Happy Birthday!!");
    }


}




