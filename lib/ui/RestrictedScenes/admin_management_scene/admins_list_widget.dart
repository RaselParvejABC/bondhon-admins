import 'package:flutter/foundation.dart';

import '../../dialogs/confirmation_dialog.dart';
import '../../dialogs/inform_dialog.dart';
import '../../dialogs/wait_dialog.dart';
import '../../../utilities/Cryptography/my_cryptography_utilities.dart';
import '../../../utilities/JSON/my_json_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../../log_in_scene.dart';
import 'authentication.dart';
import 'authorizations.dart';

class AdminsListWidget extends StatelessWidget {
  final DocumentSnapshot admin;
  const AdminsListWidget(this.admin, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('admins').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
              'কিছু একটা সমস্যা হয়েছে। ইন্টারনেট সংযোগ চেক করে পরে চেষ্টা করুন।');
        }
        if (snapshot.hasData) {
          List<DocumentSnapshot<Map<String, dynamic>>>? adminsSnapshots =
              snapshot.data?.docs;
          return Column(
            children: [
              const Text(
                'বর্তমান এডমিনদের তালিকা',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              if (adminsSnapshots == null || adminsSnapshots.isEmpty)
                const Text(
                  'কোনো এডমিন নেই',
                ),
              if (adminsSnapshots != null && adminsSnapshots.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: adminsSnapshots.length,
                    itemBuilder: (context, index) {
                      return getAdminCard(
                          context, adminsSnapshots.elementAt(index));
                    },
                  ),
                ),
            ],
          );
        }
        return const GFLoader();
      },
    );
  }

  Widget getAdminCard(BuildContext context, DocumentSnapshot adminOfThisCard) {
    String name = adminOfThisCard.get('name').toString();
    String username = adminOfThisCard.get('username').toString();
    List<String> privileges = getListFromJSONArray(adminOfThisCard.get('privileges'));

    return GFCard(
      title: GFListTile(
        title: Text(
          name,
          style: GoogleFonts.robotoCondensed(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subTitle: Text(
          'Username: ' + username,
          style: GoogleFonts.robotoCondensed(
            fontSize: 14.0,
          ),
        ),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
      ),
      content: GFAccordion(
        titleChild: Text(
          'Manage',
          style: GoogleFonts.robotoCondensed(
            fontSize: 12.0,
          ),
        ),
        contentChild: GFButtonBar(
          children: [
            if (username == 'superadmin')
              Text(
                'You cannot manage Super Admin.',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 12.0,
                  color: Colors.red,
                ),
              ),
            if (username != 'superadmin')
              IconButton(
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
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

                  bool delete = await showConfirmationDialog(
                      context,
                      'নিশ্চিত তো?',
                      'এডমিন $name ($username)-কে ডিলিট করতে চাচ্ছেন?');
                  if (!delete) {
                    return;
                  }
                  showWaitDialog(context);
                  adminOfThisCard.reference.delete().then((value) async {
                    Navigator.of(context).pop();
                    await showInformDialog(
                        context, 'সফল', 'এডমিন ডিলিট হয়েছে।');
                    return;
                  }, onError: (error) async {
                    Navigator.of(context).pop();
                    await showInformDialog(
                        context, 'ব্যর্থ', 'এডমিন ডিলিট হয়নি।');
                    return;
                  });
                },
              ),
            if (username != 'superadmin')
              OutlinedButton(
                child: const Text(
                  'নাম',
                  style: TextStyle(
                    fontFamily: 'SolaimanLipi',
                  ),
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

                  final _formKey = GlobalKey<FormState>();
                  final _nameController = TextEditingController();
                  _nameController.text = name;

                  bool proceed = false;

                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'নাম পরিবর্তন করুন',
                          textAlign: TextAlign.center,
                        ),
                        content: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'নাম লিখুন';
                              }
                              return null;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('হ্যাঁ'),
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              if (_nameController.text != name) {
                                proceed = true;
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('না'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (!proceed) {
                    return;
                  }
                  showWaitDialog(context);
                  adminOfThisCard.reference.update({
                    'name': _nameController.text,
                  }).then((value) async {
                    Navigator.of(context).pop();
                    await showInformDialog(context, 'সফল',
                        'এডমিনের নাম পরিবর্তন বা সংশোধন হয়েছে।');
                    return;
                  }, onError: (error) async {
                    Navigator.of(context).pop();
                    await showInformDialog(context, 'ব্যর্থ',
                        'এডমিনের নাম পরিবর্তন বা সংশোধন হয়নি।');
                    return;
                  });
                },
              ),
            if (username != 'superadmin')
              IconButton(
                icon: const Icon(Icons.key),
                onPressed: () async {

                  if (!(await isSavedAuthenticationTokenValid(admin))) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => const LogInScene()),
                          (route) => false,
                    );
                    return;
                  }

                  final _formKey = GlobalKey<FormState>();
                  final _passwordController = TextEditingController();

                  bool proceed = false;

                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'পাসওয়ার্ড পরিবর্তন করুন',
                          textAlign: TextAlign.center,
                        ),
                        content: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'পাসওয়ার্ড কমপক্ষে ছয় ক্যারাক্টারের হবে।';
                              }
                              return null;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('হ্যাঁ'),
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              proceed = true;
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('না'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (!proceed) {
                    return;
                  }
                  showWaitDialog(context);
                  adminOfThisCard.reference.update({
                    'passwordSHA256Hash': getSHA256Hash(_passwordController.text),
                    'authenticationTokens': [],
                  }).then((value) async {
                    Navigator.of(context).pop();
                    await showInformDialog(
                        context, 'সফল', 'এডমিনের পাসওয়ার্ড পরিবর্তন হয়েছে।');
                    return;
                  }, onError: (error) async {
                    Navigator.of(context).pop();
                    await showInformDialog(
                        context, 'ব্যর্থ', 'এডমিনের পাসওয়ার্ড পরিবর্তন হয়নি।');
                    return;
                  });
                },
              ),
            if (username != 'superadmin')
              MultiSelectDialogField(
              initialValue: privileges,
              title: const Text('এডমিনের ক্ষমতা বাছাই করুন'),
              buttonText: const Text('এই এডমিনের ক্ষমতাসমূহ'),
              buttonIcon: const Icon(Icons.flash_on),
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
              onConfirm: (list) async {

                if (!(await isSavedAuthenticationTokenValid(admin))) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LogInScene()),
                        (route) => false,
                  );
                  return;
                }


                final selectedAuthorizations = list.map((e) => e.toString()).toList();

                if(setEquals(selectedAuthorizations.toSet(), getListFromJSONArray(adminOfThisCard.get('privileges')).toSet())){
                  return;
                }

                showWaitDialog(context);
                adminOfThisCard.reference.update({
                  'privileges': selectedAuthorizations,
                }).then((value) async {
                  Navigator.of(context).pop();
                  await showInformDialog(
                      context, 'সফল', 'এডমিনের ক্ষমতা পরিবর্তন হয়েছে।');
                  return;
                }, onError: (error) async {
                  Navigator.of(context).pop();
                  await showInformDialog(
                      context, 'ব্যর্থ', 'এডমিনের ক্ষমতা পরিবর্তন হয়নি।');
                  return;
                });
                return;
              },
            ),
          ],
        ),
      ),
    );
  }
}
