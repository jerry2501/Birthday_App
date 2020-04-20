import 'package:birthdayapp/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';

class editSheet extends StatefulWidget{
    Map<String,dynamic> map;
  editSheet(this.map);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return editSheetState();
  }

}
class editSheetState extends State<editSheet> {
  String name, date;
  int month, day;
  DateFormat _dateFormat = new DateFormat.yMMMMd();
  DateTime _date;
  DateFormat _day = new DateFormat.d();
  DateFormat _month = new DateFormat.M();
  TextEditingController controller;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,

        children: <Widget>[
          SizedBox(height: 10.0,),
          Text("Edit", style: TextStyle(
              fontSize: 24, fontFamily: "R", color: Colors.blue),),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom),
            child: Form(
              key: formkey,
              child: Column(
                children: <Widget>[

                  TextFormField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Enter the name',
                      labelText: 'Name',

                    ),
                    initialValue: widget.map['Name'],
                    onChanged: (value) {
                      setState(() {
                        name = value.toUpperCase();
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty) {
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
                      Container(
                        width: 120,
                        child: Text(

                          widget.map['Date'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.calendar_today), onPressed: () {
                        Future<DateTime> selectedDate = showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(4000),
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: child,
                              );
                            }
                        ).then((eventdate) {
                          setState(() {
                            _date = eventdate;
                            date = _dateFormat.format(_date).toString();
                            widget.map['Date'] = date;
                          });
                        });
                      })
                    ],
                  ),
                  SizedBox(height: 15,),
                  RaisedButton(child: Text(
                    "Edit", style: TextStyle(color: Colors.white),),
                    elevation: 10,
                    hoverColor: Colors.lightBlueAccent,
                    color: Colors.blue,
                    onPressed: () {
                      editdata();
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

  Future editdata() async {
    final formState = formkey.currentState;
    String id,
        e = widget.map['Event'];
    int token;
    if (_date != null) {
      setState(() {
        day = int.parse(DateFormat("d").format(_date));
        month = int.parse(DateFormat("M").format(_date));

        id = "$month $day$name$e";
      });
      if (day
          .toString()
          .length == 1) {
        setState(() {
          token = int.parse(month.toString() + (day * 10).toString());
        });
      }
      else {
        setState(() {
          token = int.parse(month.toString() + (day).toString());
        });
      }
      if (formState.validate()) {
        formState.save();
        if (name == null) {
          name = widget.map['Name'];
        }
        FocusScope.of(context).requestFocus(FocusNode());
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        await Firestore.instance.collection('users').document(user.uid)
            .collection('events').document(widget.map['Uid'])
            .updateData({
          'Name': name,
          'Date': widget.map['Date'],
          'EventToken': token,
        });

        Navigator.pop(context);
        Navigator.push(context,
            PageTransition(type: PageTransitionType.fade, child: Home()));
        Toast.show(
            "Event Edited Successfully!!", context, duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER);
      }
    }
  }
}