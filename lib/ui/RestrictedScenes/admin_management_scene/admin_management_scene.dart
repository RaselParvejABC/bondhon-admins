import 'package:cloud_firestore/cloud_firestore.dart';

import 'admins_list_widget.dart';
import 'package:flutter/material.dart';

import 'add_new_admin_widget.dart';

class AdminManagementScene extends StatefulWidget {
  final DocumentSnapshot admin;
  const AdminManagementScene(this.admin, {Key? key}) : super(key: key);

  static get label => "এডমিন ম্যানেজমেন্ট";
  static get requiredAdminPrivilege => 'admin-management';
  static get routeName => 'AdminManagementScene';

  @override
  State<AdminManagementScene> createState() => _AdminManagementSceneState();
}

class _AdminManagementSceneState extends State<AdminManagementScene> {

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (newIndex) {
            setState(() {
              index = newIndex;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'এডমিন সম্পাদনা',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.plus_one),
              label: 'নতুন এডমিন যোগ',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IndexedStack(
            index: index,
            children: [
              AdminsListWidget(widget.admin),
              AddNewAdminWidget(widget.admin),
            ],
          ),
        ),
      ),
    );
  }
}
