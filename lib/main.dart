import 'package:atlas/widgets/auth_gate.dart';

import 'screens/home_screen.dart';
import 'package:atlas/screens/permissions/photos_permission_screen.dart';
import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
 WidgetsFlutterBinding.ensureInitialized();


 await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );


 runApp(const AtlasApp());
}


class AtlasApp extends StatelessWidget {
 const AtlasApp({super.key});


 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     debugShowCheckedModeBanner: false,
     title: 'Atlas',
     theme: AppTheme.light,
     home: const AuthGate(),
   );
 }
}
