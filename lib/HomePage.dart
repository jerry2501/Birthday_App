
import 'dart:async';
import 'dart:io';

import 'package:birthdayapp/Authentication/LoginPage.dart';
import 'package:birthdayapp/Authentication/auth.dart';
import 'package:birthdayapp/Authentication/auth_provider.dart';
import 'package:birthdayapp/bottom_sheet.dart';
import 'package:birthdayapp/eventPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_id/device_id.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<DocumentSnapshot> db=new List<DocumentSnapshot>();
  QuerySnapshot snapshot,snapshotminus;
  DocumentSnapshot userdocument;
  DateFormat _day=new DateFormat.d();
  DateFormat _month=new DateFormat.M();
  bool state=false;
  TimeOfDay _time=TimeOfDay.now();
  TimeOfDay picked;
  String deviceId;
  bool isPremium=false;

  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;

  final List<String> _productLists = [
    'android.test.purchased',
    // 'android.test.canceled',
    // remove test ids and add real purchase ID here
  ];


  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

  String platformVersion;


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

  Future selectTime(BuildContext context) async{
    picked=await showTimePicker(
        context: context,
        initialTime: _time,

    );
    if(picked!=null){
      setState(() {
        _time=picked;
      });
    }

    await Firestore.instance.collection('users').document(userdocument.data['Uid']).updateData({'Notification_hour':_time.hour,'Notification_minute':_time.minute});
    Navigator.push(context,
        PageTransition(type: PageTransitionType.fade, child: Home()));
  }
  // Initialize store and get check previous purchases
  Future _initStore() async {
    print("Initing Store Connection");

    if (!isPremium) {
      try {
        platformVersion = await FlutterInappPurchase.instance.platformVersion;
      } on PlatformException {
        platformVersion = 'Failed to get platform version.';
      }
      // Prepare Connection
      var result = await FlutterInappPurchase.instance.initConnection;
      print('result: $result');
      if (!mounted) return;

      // Refresh and consume all items (for android)
      try {
        String msg = await FlutterInappPurchase.instance.consumeAllItems;
        print('consumeAllItems: $msg');
      } catch (err) {
        print('consumeAllItems error: $err');
      }

      _conectionSubscription =
          FlutterInappPurchase.connectionUpdated.listen((connected) {
            print('connected: $connected');
          });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      _purchaseUpdatedSubscription =
          FlutterInappPurchase.purchaseUpdated.listen((productItem) {

            // Check if the required Premium Feature "id" is purchased by the user
            if (productItem.productId == "android.test.purchased") {
              prefs.setBool('is_premium', true);

              // Set the app to premium
              setState(() {
                isPremium = true;
              });

              // Disable Ads Here
              // Ads.hideBannerAd();

              print("Upgraded to premium!");
            }

            print('purchase-updated: $productItem');
          });

      _purchaseErrorSubscription =
          FlutterInappPurchase.purchaseError.listen((purchaseError) {
            print('purchase-error: $purchaseError');
          });
    }
  }

  // Check if currently in premium
  Future _returnIsPremium() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isPremium = (prefs.getBool('is_premium') ?? false);
    });

    print("Prefs: $isPremium");
  }

  Future requestPurchase(IAPItem item) async {
    FlutterInappPurchase.instance.requestPurchase(item.productId);
  }

  Future getProduct() async {
    List<IAPItem> items =
    await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      print('Got Product: ${item.productId}');
      this._items.add(item);
    }

    this._items = items;
    this._purchases = [];
  }

  Future getPurchaseHistory() async {
    print("Getting purchase history");
    List<PurchasedItem> items =
    await FlutterInappPurchase.instance.getPurchaseHistory();
    for (var item in items) {
      print('Purchased: ${item.productId}');
      this._purchases.add(item);
    }

    this._items = [];
    this._purchases = items;
  }

  Future _getPurchases() async {
    List<PurchasedItem> items =
    await FlutterInappPurchase.instance.getAvailablePurchases();
    for (var item in items) {
      print('${item.toString()}');
      this._purchases.add(item);
    }

    setState(() {
      this._items = [];
      this._purchases = items;
    });
  }

  // NOTE: Code works in testing environment for now
  // Modifications to be done when real Play Store items are added
  Future makePurchase() async {
    print("Making Purchase");
    await getProduct();
    try {
      await requestPurchase(_items[0]);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Purchased Failed"),
              content: Text(e.toString()),
            );
          });
    }
    // await FlutterInappPurchase.instance.endConnection;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    list.clear();
    _returnIsPremium();
    _initStore();
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
      drawer: state==false?Container(height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,
      child: Center(child: Text("Please Wait"),),
      ):
      Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
               accountName: Text(userdocument.data['name']),
              accountEmail: Text(userdocument.data['Email']),
              currentAccountPicture: CircleAvatar(
               backgroundColor: Colors.white,
                  child: Text(userdocument.data['name'].substring(0,1),style: TextStyle(fontSize: 40,color: Colors.blue),),
              ),
              ),
            ListTile(
              leading: Icon(Icons.home,color: Colors.blue,),
              title: Text("Home"),
            ),
            ExpansionTile(
              leading: Icon(Icons.notifications,color: Colors.blue,),
              title: Text("Notification"),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.timer,color: Colors.blue,),
                  title: Text("Notification Time"),
                  subtitle: Text(userdocument.data['Notification_hour'].toString()+":"+userdocument.data['Notification_minute'].toString()),
                  onTap: (){
                    selectTime(context);
                  },
                )
              ],
            ),
            Divider(thickness: 1,),
            (!isPremium)?
                  ListTile(
                    leading: Icon(Icons.remove_circle,color: Colors.blue,),
                    title: Text("Remove Ads"),
                    subtitle: Text("Get a Premium Access!!"),
                    trailing: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue,)
                      ),
                      child: Text("Premium"),
                    ),
                    onTap: (){
                      makePurchase();
                    },
                  ):
                ListTile(
                  leading: Icon(Icons.announcement,color: Colors.blue,),
                  title: Text("Ads Removed"),
                  subtitle: Text("You are Premiun user"),
                ),
            ListTile(
              leading: Icon(Icons.share,color: Colors.blue,),
              title: Text("Share "),
            ),
            Divider(thickness: 1,),



          ],
        ),
      ),
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
                 children: <Widget>[
                   SizedBox(height: MediaQuery.of(context).size.height/4,),
                   Expanded(child:

                         ListView.separated( shrinkWrap: true,
                             itemCount: db.length,
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
                                             tag:db[index].data['Uid'],
                                             child: ClipOval(


                                               child: Image.asset('images/avatar.jpg',height: 45,width: 45,),
                                             ),
                                           ),
                                           SizedBox(width: 30,),
                                           Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: <Widget>[
                                               Text(db[index].data['Name'],style: TextStyle(fontFamily: "R",fontSize: 16,color: Colors.blue,fontWeight: FontWeight.bold),),
                                               SizedBox(height: 4,),
                                               Text(db[index].data['Event']+" on "+db[index].data['Date'],style: TextStyle(fontFamily: "R",fontSize: 14,color: Colors.black.withOpacity(0.6)),)
                                             ],
                                           )
                                         ],
                                       ),
                                     ),
                                   ),
                                 ),
                               );
                             }
                         ),)
                       ],
                  )







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
              // bottom(context,"Anniversary");
              bottom(context, "Anniversary");
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
          return sheet(event,userdocument.data);
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
    int today;
    if(date.toString().length==1){
      setState(() {
        today=int.parse(month.toString()+(date*10).toString());
      });
    }
    else
      {
        setState(() {
          today=int.parse(month.toString()+(date).toString());
        });
      }
    print(month);
    print(date);
    print(DateFormat("D").format(DateTime.now()));
    print(month.toString()+" "+date.toString());
   int min,index;
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
     await Firestore.instance.collection('users').document(user.uid).collection('events').where('EventToken',isGreaterThanOrEqualTo:today).orderBy('EventToken').getDocuments().then((value){
       setState(() {
         snapshot=value;
         db.addAll(snapshot.documents);
       });
     });
    await Firestore.instance.collection('users').document(user.uid).collection('events').where('EventToken',isLessThan:today).orderBy('EventToken').getDocuments().then((value){
      setState(() {
        snapshotminus=value;
        db.addAll(snapshotminus.documents);

      });
    });
    await Firestore.instance.collection('users').document(user.uid).get().then((value){
      setState(() {
        userdocument=value;
        state=true;
      });
    });
    deviceId=await DeviceId.getID;
//    if(deviceId!=userdocument.data['deviceId']){
//      //add notification schedule code here
//
//    }

    for(int i=0;i<snapshot.documents.length;i++){
      setState(() {
        list.add(snapshot.documents[i].data['Name']);

      });
      print(list);
    }
    for(int i=0;i<snapshotminus.documents.length;i++){
      setState(() {
        list.add(snapshotminus.documents[i].data['Name']);

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

