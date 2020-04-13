import 'package:birthdayapp/Authentication/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../HomePage.dart';
import 'LoginPage.dart';
import 'auth.dart';


class rootpage extends StatefulWidget {
  @override
  rootpagestate createState() => rootpagestate();

}

enum AuthStatus{
  notDetermined,
  notSignedIn,
  signedIn,
}
 class rootpagestate extends State<rootpage>
 {
   AuthStatus authStatus=AuthStatus.notDetermined;
   @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final BaseAuth auth = AuthProvider.of(context).auth;
    auth.currentUser().then((String userId) {
      setState(() {
        authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

   void _signedIn() {
     setState(() {
       authStatus = AuthStatus.signedIn;
     });
   }

   void _signedOut() {
     setState(() {
       authStatus = AuthStatus.notSignedIn;
     });
   }

   @override
   Widget build(BuildContext context) {
     switch (authStatus) {
       case AuthStatus.notDetermined:
         return _buildWaitingScreen();
       case AuthStatus.notSignedIn:
         return LoginPage(
           onSignedIn: _signedIn,
         );
       case AuthStatus.signedIn:
         return Home(
           onSignedOut: _signedOut,
         );
     }
     return null;
   }

   Widget _buildWaitingScreen() {
     return Scaffold(
       body: Container(
         alignment: Alignment.center,
         child: CircularProgressIndicator(),
       ),
     );
   }
 }