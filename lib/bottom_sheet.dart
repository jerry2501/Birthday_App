import 'package:birthdayapp/Authentication/database.dart';
import 'package:birthdayapp/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';

class sheet extends StatefulWidget
{
  String event;
  sheet(this.event);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return sheetState();
  }

}
class sheetState extends State<sheet>
{

  String name,date;
  DateFormat _dateFormat=new DateFormat.yMMMMd();
  DateTime _date;
  final GlobalKey<FormState> formkey=GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Container(
     padding: EdgeInsets.all(30.0),
     child: Wrap(
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
    if(formState.validate()) {
      formState.save();
      FocusScope.of(context).requestFocus(FocusNode());
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      await DatbaseSevice(uid: user.uid).createEvent(
          widget.event, name, date);
      Navigator.pop(context);
      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: Home()));
      Toast.show("Event created!!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER);
    }
  }
}
