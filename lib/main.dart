
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'fancy_well_bite_login.dart'; // ✅ Use snake_case file name

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyB1jhi7_6f5hLMa1ZB5jLNmU-06KP3WCeU",
          authDomain: "wellbite-85e6c.firebaseapp.com",
          projectId: "wellbite-85e6c",
          storageBucket: "wellbite-85e6c.firebasestorage.app",
          messagingSenderId: "599699978091",
          appId: "1:599699978091:web:c254f0f060ad3cc4e7be2e",
          measurementId: "G-JPSC5JDJ9H"
      )
    );
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WellBite',
        home: FancyWellBiteLogin(),
  ));
}

