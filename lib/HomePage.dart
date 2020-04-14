
import 'dart:io';

import 'package:birthdayapp/Authentication/LoginPage.dart';
import 'package:birthdayapp/Authentication/auth.dart';
import 'package:birthdayapp/Authentication/auth_provider.dart';
import 'package:birthdayapp/bottom_sheet.dart';
import 'package:birthdayapp/eventPage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_admob/firebase_admob.dart';

const String testDevice='';
List list=new List();


class Home extends StatefulWidget{
  final VoidCallback onSignedOut;

  const Home({Key key, this.onSignedOut}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeState();
  }

}
class HomeState extends State<Home>
{
  List db=new List();
  QuerySnapshot snapshot;
  DateFormat _day=new DateFormat.d();
  DateFormat _month=new DateFormat.M();
  bool state=false;

  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices:<String>[],
    keywords: <String>['birthday','anniversary','home','furniture'],
    birthday: DateTime.now(),
    childDirected: true,
  );

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  BannerAd createBannerAd(){
    return BannerAd(
      adUnitId: 'ca-app-pub-5615961032623800/3841520709',
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event){
        print("Banner event : $event");
      }
    );
  }

  InterstitialAd createInterstitialAd(){
    return InterstitialAd(
        adUnitId: 'ca-app-pub-5615961032623800/5892968974',
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event){
          print("Interstitital event : $event");
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    list.clear();

    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-5615961032623800~6659255738');
    _bannerAd=createBannerAd()..load()..show();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Special Days"),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          InkWell(
            onTap: (){
               showSearch(context: context,delegate: SearchService());
            },
              child: Padding(
                padding: EdgeInsets.only(right: 15),
                child:Icon(Icons.search),
              )
          ),
          InkWell(
            onTap: () => _signOut(context),
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.power_settings_new),
            )
          )
        ],

      ),
      drawer: Drawer(),
      body:WillPopScope(
        onWillPop: onWillPop,
        child: state==false?
                 Center(
                  child:CircularProgressIndicator(),
                )
              :
        (snapshot.documents.length==0)?
        Container(
//                height: MediaQuery.of(context).size.height/4,
//                width: MediaQuery.of(context).size.width,
          child:Image.asset('images/download.jpg',width: MediaQuery.of(context).size.width,

          ),
        ):
           Stack(
             children: <Widget>[

               Container(
//                height: MediaQuery.of(context).size.height/4,
//                width: MediaQuery.of(context).size.width,
                 child:Image.asset('images/download.jpg',width: MediaQuery.of(context).size.width,

                 ),
               ),

               Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: <Widget>[
                   SizedBox(height: MediaQuery.of(context).size.height/4,),
                   Expanded(
                     child: ListView.separated( shrinkWrap: true,
                         itemCount: snapshot.documents.length,
                         separatorBuilder: (context,index)=>SizedBox(height: 10,),
                         itemBuilder: (BuildContext ctx, int index){
                           return Container(
                             padding: EdgeInsets.only(left: 10,right: 10),
                             child: Card(
                               margin:EdgeInsets.all(2),
                               color: Colors.lightBlue[50],
                               borderOnForeground: true,
                               elevation: 7.0,
                               child:InkWell(
                                 onTap:(){
                                   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: eventPage(db[index].data)));
                                 },
                                 child: Container(
                                   padding: EdgeInsets.all(10),
                                   child: Row(
                                     children: <Widget>[
                                       Hero(
                                         tag:snapshot.documents[index].data['Uid'],
                                         child: ClipOval(


                                           child: Image.asset('images/avatar.jpg',height: 45,width: 45,),
                                         ),
                                       ),
                                       SizedBox(width: 30,),
                                       Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: <Widget>[
                                           Text(snapshot.documents[index].data['Name'],style: TextStyle(fontFamily: "R",fontSize: 16,color: Colors.blue,fontWeight: FontWeight.bold),),
                                           SizedBox(height: 4,),
                                           Text(snapshot.documents[index].data['Event']+" on "+snapshot.documents[index].data['Date'],style: TextStyle(fontFamily: "R",fontSize: 14,color: Colors.black.withOpacity(0.6)),)
                                         ],
                                       )
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           );
                         }
                     ),
                   ),

                 ],
               ),

             ],
           )

            
             
      ),
     floatingActionButton:

     Padding(
       padding: EdgeInsets.only(bottom: 50),
       child: SpeedDial(
         animatedIcon: AnimatedIcons.add_event,
         child: Icon(Icons.star),
         overlayColor: Colors.lightBlueAccent,
         overlayOpacity: 0.2,
         curve: Curves.easeIn,
         closeManually: false,
         children: [
           SpeedDialChild(
             child: Icon(Icons.cake),
             label: "Add new Birthday",
             backgroundColor: Colors.blue,
             onTap: (){
               createInterstitialAd()..load()..show();
               bottom(context,"Birthday");
             },
           ),
           SpeedDialChild(
             child: Icon(Icons.wc),
             label: "Add new Anniversary",
             backgroundColor: Colors.blue,
             onTap: (){
               bottom(context,"Anniversary");
             },
           )
         ],
       ),
     ),
    );
  }

  void bottom(BuildContext context,String event) {
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
          return sheet(event);
  });
}

  Future<bool> onWillPop() async {

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to exit an App'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                exit(0);
              },
            )
          ],
        );
      },
    ) ?? false;
  }

  Future getdata() async{
    int month=int.parse(DateFormat("M").format(DateTime.now()));
    int date=int.parse(DateFormat("d").format(DateTime.now()));
    int minmonth,mindate;
    print(month);
    print(date);
    print(DateFormat("D").format(DateTime.now()));
   int min,index;
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
     await Firestore.instance.collection('users').document(user.uid).collection('events').orderBy('Timestamp',descending:false).getDocuments().then((value){
       setState(() {
         snapshot=value;
        
         state=true;

       });
     });
     for(int i=0;i<snapshot.documents.length-1;i++)
       {
         setState(() {
           minmonth=snapshot.documents[i].data['Month'];
           mindate=snapshot.documents[i].data['Day'];
         });

         for(int j=i;j<snapshot.documents.length-1;j++)
           {
             if(minmonth>=snapshot.documents[j+1].data['Month']-month && snapshot.documents[j+1].data['Month']-month>0)
               {
                 if(mindate>=snapshot.documents[j+1].data['Day']-date && snapshot.documents[j+1].data['Day']-date>0){
                   setState(() {
                    // db.add(snapshot.documents[j+1].data);
                     var temp= snapshot.documents[j];
                     snapshot.documents[i]=snapshot.documents[j+1];
                     snapshot.documents[j+1]=temp;
                   });

                 }
               }
             else{
               setState(() {
                 //db.add(snapshot.documents[i].data);
                 snapshot.documents[i]=snapshot.documents[i];
               });

             }
           }
       }
    for(int i=0;i<snapshot.documents.length;i++){
      setState(() {
        list.add(snapshot.documents[i].data['Name']);

      });

      print(list);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();
      await GoogleSignIn().disconnect();
      await GoogleSignIn().signOut();
      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
      widget.onSignedOut();

    } catch (e) {
      print(e);
    }
  }
}


class SearchService extends SearchDelegate{
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return[
      IconButton(icon: Icon(Icons.clear),onPressed:(){
        query="";
      } ,)
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(icon: AnimatedIcon(
      icon:AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    ), onPressed: (){
      close(context, null);
    });
  }

  @override
  Widget buildResults(BuildContext context) {

    // TODO: implement buildResults

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    final nullList =["No suggestion available"];
     final suggestionList= query.isEmpty? nullList :
     list.where((element) => element.startsWith(query.toUpperCase())).toList();
     print(suggestionList);
     return ListView.separated(

          separatorBuilder: (context,index){
            return Divider(
              thickness: 1,
              color: Colors.grey,
            );
          },
         itemBuilder: (context,index){
          return ListTile(
             onTap: (){
              getDetails(suggestionList[index].toString(),context);
             },

             leading: Icon(Icons.account_circle,size: 40,color: Colors.blue,),

             title:RichText(
               text:TextSpan(
                 text:suggestionList[index].substring(0,query.length),
                 style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),
                 children: [
                   TextSpan(
                     text: suggestionList[index].substring(query.length),
                     style: TextStyle(color: Colors.grey),
                   )
                 ]
               ) ,),
           );

         },
         itemCount: suggestionList.length,
     );
  }
Future getDetails(String name,BuildContext context) async{
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
   QuerySnapshot snapshot= await Firestore.instance.collection('users').document(user.uid).collection('events').where('Name',isEqualTo: name).getDocuments();
    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: eventPage(snapshot.documents[0].data)));


}
}