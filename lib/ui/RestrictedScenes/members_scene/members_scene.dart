import 'add_new_member_widget.dart';
import 'all_members_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersScene extends StatefulWidget {
  final DocumentSnapshot admin;
  const MembersScene(this.admin, {Key? key}) : super(key: key);

  static get label => "রক্তদাতাদের তথ্য";
  static get requiredAdminPrivilege => 'member-read';
  static get routeName => 'MembersScene';

  @override
  State<MembersScene> createState() => _MembersSceneState();
}

class _MembersSceneState extends State<MembersScene> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(MembersScene.label),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: IndexedStack(
            index: _index,
            children: [
              AllMembersWidget(widget.admin),
              AddNewMemberWidget(widget.admin),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (newIndex) {
            setState(() {
              _index = newIndex;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_rounded),
              label: 'সব রক্তদাতা',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'নতুন রক্তদাতা',
            ),
          ],
        ),
      ),
    );
  }
}
