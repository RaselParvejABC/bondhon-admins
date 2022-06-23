import 'ui/RestrictedScenes/admin_management_scene/admin_management_scene.dart';
import 'ui/RestrictedScenes/change_your_password_scene/change_your_password_scene.dart';
import 'ui/RestrictedScenes/members_scene/members_scene.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ui/log_in_scene.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'বন্ধন',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SolaimanLipi',
      ),
      home: const LogInScene(),
      onGenerateRoute: (settings) {
        DocumentSnapshot admin = settings.arguments as DocumentSnapshot;
        if(settings.name == MembersScene.routeName) {
          return MaterialPageRoute(
              builder: (context) => MembersScene(admin)
          );
        }
        if(settings.name == ChangeYourPasswordScene.routeName) {
          return MaterialPageRoute(
              builder: (context) => ChangeYourPasswordScene(admin)
          );
        }
        if(settings.name == AdminManagementScene.routeName) {
          return MaterialPageRoute(
              builder: (context) => AdminManagementScene(admin)
          );
        }

        return null;
      },
    );
  }
}
