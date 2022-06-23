import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../log_in_scene.dart';
import 'authentication.dart';
import 'authorizations.dart';
import '../../dialogs/inform_dialog.dart';
import '../../dialogs/wait_dialog.dart';
import '../../../utilities/Cryptography/my_cryptography_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AddNewAdminWidget extends StatelessWidget {
  final DocumentSnapshot admin;
  const AddNewAdminWidget(this.admin, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    final _nameController = TextEditingController();
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();

    List<String> selectedAuthorizations = [];

    return GFCard(
      title: const GFListTile(
        titleText: 'নতুন এডমিন যোগ করুন',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'এডমিনের নাম',
              ),
              validator: (value) {
                value = value?.trim();
                if (value == null || value.isEmpty) {
                  return 'এডমিনের নাম লিখেননি।';
                }
                _nameController.text = value;
                return null;
              },
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                  labelText: 'এডমিনের ইউজারনেম',
                  helperText: 'ইউজারনেম লগিনের সময় কাজে লাগবে।'),
              validator: (value) {
                value = value?.trim();
                if (value == null || value.isEmpty) {
                  return 'এডমিনের ইউজারনেম লিখেননি।';
                }
                _usernameController.text = value;
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                  labelText: 'এডমিনের পাসওয়ার্ড',
                  helperText: 'পাসওয়ার্ড লগিনের সময় কাজে লাগবে।'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'এডমিনের পাসওয়ার্ড লিখেননি।';
                }
                if (value.length < 6) {
                  return 'পাসওয়ার্ড কমপক্ষে ছয় ক্যারাক্টারের হবে।';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 16.0,
            ),
            MultiSelectDialogField(
              initialValue: const [],
              title: const Text('এডমিনের ক্ষমতা'),
              buttonText: const Text('এডমিনের ক্ষমতা বাছাই করুন'),
              itemsTextStyle: const TextStyle(
                fontFamily: 'SolaimanLipi',
              ),
              selectedItemsTextStyle: const TextStyle(
                fontFamily: 'SolaimanLipi',
                color: Colors.redAccent,
              ),
              items: authorizations
                  .map((authorization) => MultiSelectItem(
                      authorization['identifier'].toString(),
                      authorization['label'].toString()))
                  .toList(),
              onConfirm: (list) {
                //print(null.toString());
                selectedAuthorizations = list.map((e) => e.toString()).toList();
                //print(selectedAuthorizations);
                return;
              },
              validator: (list){
                if(list == null || list.map((e) => e.toString()).toList().isEmpty){
                  return 'কমপক্ষে একটি ক্ষমতা নির্বাচন করুন।';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 16.0,
            ),
            GFButton(
              fullWidthButton: true,
              text: 'ডাটাবেসে সেভ করুন',
              textStyle: const TextStyle(
                fontFamily: 'SolaimanLipi',
              ),
              onPressed: () async {

                if (!(await isSavedAuthenticationTokenValid(admin))) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LogInScene()),
                        (route) => false,
                  );
                  return;
                }


                if (!_formKey.currentState!.validate()) {
                  await showInformDialog(context, 'ভুল করছেন',
                      'দয়া করে প্রতিটি ঘর ঠিকঠাক পূরণ করুন।');
                  return;
                }
                showWaitDialog(context);

                DocumentSnapshot newAdmin = await FirebaseFirestore.instance
                    .collection('admins')
                    .doc(_usernameController.text)
                    .get();

                if (newAdmin.exists) {
                  Navigator.of(context).pop();
                  await showInformDialog(context, 'ভুল করছেন',
                      'এই ইউজারনেমের একজন এডমিন এরই মাঝে আছেন।');
                  return;
                }
                Map<String, dynamic> newAdminData = {
                  'username': _usernameController.text,
                  'name': _nameController.text,
                  'passwordSHA256Hash': getSHA256Hash(_passwordController.text),
                  'privileges': selectedAuthorizations,
                };
                newAdmin.reference.set(newAdminData).then((value) async {
                  Navigator.of(context).pop();
                  await showInformDialog(
                      context, 'সফল', 'নতুন এডমিন সিস্টেমে যুক্ত হয়েছেন।');
                  _formKey.currentState!.reset();
                  return;
                }, onError: (error) async {
                  await showInformDialog(context, 'দুঃখিত',
                      'ইন্টারনেট সংযোগ চেক করে পরে চেষ্টা করুন।');
                  return;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
