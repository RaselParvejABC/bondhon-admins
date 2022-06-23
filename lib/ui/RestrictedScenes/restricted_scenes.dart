import 'admin_management_scene/admin_management_scene.dart';
import 'change_your_password_scene/change_your_password_scene.dart';

import 'members_scene/members_scene.dart';

import '../dialogs/wait_dialog.dart';
import '../log_in_scene.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utilities/JSON/my_json_utilities.dart';

class RestrictedScenes extends StatelessWidget {
  final DocumentSnapshot admin;
  const RestrictedScenes(this.admin, {Key? key}) : super(key: key);

  static final List<Map<String, String>> scenes = [
    {
      'label': MembersScene.label,
      'requiredAdminPrivilege': MembersScene.requiredAdminPrivilege,
      'routeName': MembersScene.routeName,
    },
    {
      'label': ChangeYourPasswordScene.label,
      'requiredAdminPrivilege': ChangeYourPasswordScene.requiredAdminPrivilege,
      'routeName': ChangeYourPasswordScene.routeName,
    },
    {
      'label': AdminManagementScene.label,
      'requiredAdminPrivilege': AdminManagementScene.requiredAdminPrivilege,
      'routeName': AdminManagementScene.routeName,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<String> adminPrivileges =
        getListFromJSONArray(admin.get('privileges'));

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GFCard(
                padding: const EdgeInsets.all(0.0),
                title: GFListTile(
                  title: Text(
                    'Logged In as',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  subTitle: Text(
                    admin.get('name').toString() +
                        '(${admin.get('username').toString()})',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 16.0,
                    ),
                  ),
                  description: Row(
                    children: [
                      const Spacer(),
                      GFButton(
                        text: 'Log Out',
                        color: Colors.red,
                        onPressed: () async {
                          showWaitDialog(context);

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String authenticationToken =
                              prefs.get('authenticationToken').toString();

                          List<String> authenticationTokens = [];
                          try {
                            authenticationTokens = getListFromJSONArray(
                                admin.get('authenticationTokens'));
                          } catch (error) {
                            1;
                          }

                          authenticationTokens.remove(authenticationToken);
                          await admin.reference.update({
                            'authenticationTokens': authenticationTokens,
                          });

                          prefs.clear();

                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LogInScene(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 32.0,
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: scenes
                      .where((scene) => adminPrivileges
                          .contains(scene['requiredAdminPrivilege']))
                      .map((scene) {
                    return ElevatedButton(
                      child: Text(
                        scene['label']!,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(scene['routeName']!, arguments: admin);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget getGridCard(Map<String, String> scene, BuildContext context) {
  //   String label = scene['label']!;
  //   return GFButton(
  //     color: GFColors.FOCUS,
  //     type: GFButtonType.solid,
  //     child: Text(
  //       label,
  //       textAlign: TextAlign.center,
  //       style: const TextStyle(
  //         fontFamily: 'SolaimanLipi',
  //         fontSize: 18.0,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     onPressed: () {
  //       Navigator.of(context).pushNamed(scene['routeName']!, admin);
  //     },
  //   );
  // }

}
