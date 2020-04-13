
import 'package:birthdayapp/Authentication/auth_provider.dart';
import 'package:birthdayapp/Authentication/root.dart';
import 'package:flutter/material.dart';

import 'Authentication/auth.dart';


void main() {
  runApp( AuthProvider(auth:Auth(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Seva Admin',
          home: rootpage()
      )));
}

