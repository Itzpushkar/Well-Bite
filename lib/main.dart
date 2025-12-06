
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'fancy_well_bite_login.dart'; // ✅ Use snake_case file name

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "",
          authDomain: "",
          projectId: "",
          storageBucket: "",
          messagingSenderId: "",
          appId: "",
          measurementId: ""
      )
    );
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WellBite',
        home: FancyWellBiteLogin(),
  ));
}

