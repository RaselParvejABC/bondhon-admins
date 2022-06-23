import '../../log_in_scene.dart';
import '../admin_management_scene/authentication.dart';
import 'edit_member_scene.dart';
import 'member_information_screen.dart';

import '../../dialogs/confirmation_dialog.dart';
import '../../dialogs/inform_dialog.dart';
import '../../dialogs/wait_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utilities/Firebase/my_firebase_utilities.dart';
import '../../../utilities/JSON/my_json_utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:regexpattern/regexpattern.dart';

import 'blood_groups_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AllMembersWidget extends StatelessWidget {
  final DocumentSnapshot admin;
  const AllMembersWidget(this.admin, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FilterCriteria(),
        ),
      ],
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('donors')
            .orderBy('lastDonationDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
                'কিছু একটা সমস্যা হয়েছে। ইন্টারনেট সংযোগ চেক করে পরে চেষ্টা করুন।');
          }

          if (snapshot.hasData) {
            List<DocumentSnapshot<Map<String, dynamic>>>? donorsSnapshots =
                snapshot.data?.docs;

            final _searchBoxController = TextEditingController();

            String _searchKey = context.watch<FilterCriteria>().getSearchKey;
            List<String> selectedBloodGroups =
                context.watch<FilterCriteria>().getSelectedBloodGroups;

            List<DocumentSnapshot<Map<String, dynamic>>>?
                filteredDonorsSnapshots;

            if (donorsSnapshots != null) {
              filteredDonorsSnapshots = donorsSnapshots.where((donor) {
                bool hope = false;

                if (_searchKey.isNotEmpty) {
                  if (donor
                      .get('memberID')
                      .toString()
                      .toLowerCase()
                      .contains(_searchKey.toLowerCase())) {
                    hope = true;
                  }
                  if (donor
                      .get('nameInBanglaLetters')
                      .toString()
                      .toLowerCase()
                      .contains(_searchKey.toLowerCase())) {
                    hope = true;
                  }
                  if (donor
                      .get('nameInEnglishLetters')
                      .toString()
                      .toLowerCase()
                      .contains(_searchKey.toLowerCase())) {
                    hope = true;
                  }
                } else {
                  hope = true;
                }

                if (!hope) {
                  return false;
                }

                if (selectedBloodGroups.isEmpty ||
                    selectedBloodGroups.length == 8) {
                  return true;
                }

                if (selectedBloodGroups
                    .contains(donor.get('bloodGroup').toString())) {
                  return true;
                }

                return false;
              }).toList();
            }

            _searchBoxController.text = _searchKey;
            _searchBoxController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchBoxController.text.length));
            return Column(
              children: [
                TextFormField(
                  style: const TextStyle(
                    fontFamily: 'SolaimanLipi',
                  ),
                  controller: _searchBoxController,
                  decoration: const InputDecoration(
                      labelText: 'সার্চ করুন',
                      helperMaxLines: 5,
                      helperText:
                          'সদস্য নম্বর অথবা বাংলা/ইংরেজি হরফের নাম দিয়ে সার্চ করুন।'),
                  onChanged: (value) {
                    context.read<FilterCriteria>().setSearchKey = value;
                  },
                ),
                MultiSelectDialogField<String>(
                  title: const Text('যে গ্রুপের রক্তদাতাদেরকে দেখতে চাচ্ছেন'),
                  buttonText: const Text('রক্তের গ্রুপ বাছাই করুন'),
                  chipDisplay: MultiSelectChipDisplay(
                    textStyle: const TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  items: bloodGroupsList
                      .map((bloodGroup) =>
                          MultiSelectItem(bloodGroup, bloodGroup))
                      .toList(),
                  onConfirm: (list) {
                    context.read<FilterCriteria>().setSelectedBloodGroups =
                        list;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                if (filteredDonorsSnapshots != null &&
                    filteredDonorsSnapshots.isNotEmpty)
                  Text(
                    '${filteredDonorsSnapshots.length} জন',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                if (filteredDonorsSnapshots == null ||
                    filteredDonorsSnapshots.isEmpty)
                  const Text(
                    '(এমন) কোনো রক্তদাতা নেই',
                  ),
                if (filteredDonorsSnapshots != null &&
                    filteredDonorsSnapshots.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredDonorsSnapshots.length,
                      itemBuilder: (context, index) {
                        return getDonorCard(
                            context, filteredDonorsSnapshots!.elementAt(index));
                      },
                    ),
                  ),
              ],
            );
          }

          return const GFLoader();
        },
      ),
    );
  }

  Widget getDonorCard(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> donor) {
    String memberID =
        getFieldValueFromDocumentSnapshot(donor, 'memberID') ?? '';
    String nameInBanglaLetters =
        getFieldValueFromDocumentSnapshot(donor, 'nameInBanglaLetters') ?? '';
    // String nameInEnglishLetters =
    //     getFieldValueFromDocumentSnapshot(donor, 'nameInEnglishLetters') ?? '';
    String bloodGroup =
        getFieldValueFromDocumentSnapshot(donor, 'bloodGroup') ?? '';
    String lastDonationDate =
        getFieldValueFromDocumentSnapshot(donor, 'lastDonationDate') ?? '';
    List<String> phoneNumbers = getListFromJSONArray(
        getFieldValueFromDocumentSnapshot(donor, 'phoneNumbers') ?? []);
    String fbProfileLink =
        getFieldValueFromDocumentSnapshot(donor, 'fbProfileLink') ?? '';
    // String fatherOrHusbandName =
    //     getFieldValueFromDocumentSnapshot(donor, 'fatherOrHusbandName') ?? '';
    // String motherName =
    //     getFieldValueFromDocumentSnapshot(donor, 'motherName') ?? '';
    // String birthDate =
    //     getFieldValueFromDocumentSnapshot(donor, 'birthDate') ?? '';
    // String profession =
    //     getFieldValueFromDocumentSnapshot(donor, 'profession') ?? '';
    // Map<String, dynamic> currentAddress =
    //     getFieldValueFromDocumentSnapshot(donor, 'currentAddress') ?? {};
    // String village = currentAddress['village'] ?? '';
    // String post = currentAddress['post'] ?? '';
    // String upazilla = currentAddress['upazilla'] ?? '';
    // String district = currentAddress['district'] ?? '';

    List<String> adminPrivileges = getListFromJSONArray(
        getFieldValueFromDocumentSnapshot(admin, 'privileges'));

    return GFCard(
      title: GFListTile(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        icon: GFBadge(
          textStyle: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          color: GFColors.SUCCESS,
          shape: GFBadgeShape.square,
          text: bloodGroup,
          size: GFSize.LARGE,
        ),
        title: Text(
          nameInBanglaLetters,
          style: const TextStyle(
            fontSize: 16.0,
            color: GFColors.SUCCESS,
            fontWeight: FontWeight.bold,
          ),
        ),
        subTitle: Text(
          'শেষ রক্তদানের তারিখ $lastDonationDate',
          style: const TextStyle(
            fontSize: 14.0,
            color: GFColors.FOCUS,
          ),
        ),
      ),
      content: Column(
        children: [
          const Divider(
            height: 8.0,
            thickness: 1.0,
            color: Colors.black,
          ),
          Row(
            children: [
              Text(
                'ডোনার আইডিঃ $memberID',
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              const Spacer(),
            ],
          ),
          for (String phoneNumber in phoneNumbers)
            getPhoneWidget(context, phoneNumber),
        ],
      ),
      buttonBar: GFButtonBar(
        children: [
          if (fbProfileLink.isUrl())
            IconButton(
              icon: const Icon(
                Icons.facebook,
                color: Colors.blue,
              ),
              onPressed: () async {
                bool launched = false;

                try {
                  launched =
                      await launch('fb://facewebmodal/f?href=' + fbProfileLink);
                } catch (error) {
                  if (error.toString().contains('ACTIVITY_NOT_FOUND')) {
                    await showInformDialog(
                        context, 'দুঃখিত', 'ফেসবুক এ্যাপ ইন্সটলড নেই।');
                    return;
                  }
                }
                if (!launched) {
                  await showInformDialog(
                      context, 'দুঃখিত', 'কোথাও সমস্যা হচ্ছে।');
                  return;
                }
              },
            ),
          //Read A Member Information
          IconButton(
            icon: const Icon(
              Icons.newspaper,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MemberInformationScreen(donor),
                ),
              );
            },
          ),
          if (adminPrivileges.contains('member-delete'))
            IconButton(
              icon: const Icon(
                Icons.delete,
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

                bool delete = await showConfirmationDialog(context, 'সাবধান',
                    'রক্তদাতা $nameInBanglaLetters এর তথ্য ডিলিট করতে চাচ্ছেন?');
                if (!delete) {
                  return;
                }

                showWaitDialog(context);
                donor.reference.delete().then((value) async {
                  Navigator.of(context).pop();
                  await showInformDialog(context, 'সফল',
                      'রক্তদাতার তথ্য ডাটাবেস সিস্টেম থেকে ডিলিট হয়েছে।');
                  return;
                }, onError: (error) async {
                  Navigator.of(context).pop();
                  await showInformDialog(context, 'দুঃখিত',
                      'রক্তদাতার তথ্য ডাটাবেস সিস্টেম থেকে ডিলিট হয়নি। ইন্টারনেট সংযোগ চেক করে পরে চেষ্টা করুন।');
                  return;
                });
              },
            ),
          if (adminPrivileges.contains('member-edit'))
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.black,
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

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        EditMemberWidget(admin, donor),
                  ),
                );
              },
            ),
          if (adminPrivileges.contains('last-donation-date-edit'))
            IconButton(
              icon: const Icon(
                Icons.water_drop,
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

                DateTime? newDate = await showDatePicker(
                  helpText: 'শেষ রক্তদানের তারিখ',
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (newDate == null) {
                  return;
                }

                showWaitDialog(context);
                donor.reference.update({
                  'lastDonationDate':
                      '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}',
                  'addAndModificationDetails': FieldValue.arrayUnion([
                    'Last Donation Date Edited  by ${admin.get('username')} (${admin.get('name')})'
                  ]),
                }).then((value) async {
                  Navigator.of(context).pop();
                  await showInformDialog(context, 'সফল',
                      '$nameInBanglaLetters এর শেষ রক্তদানের তারিখ পরিবর্তন হয়েছে।');
                  return;
                }, onError: (error) async {
                  Navigator.of(context).pop();
                  await showInformDialog(context, 'ব্যর্থ',
                      '$nameInBanglaLetters এর শেষ রক্তদানের তারিখ পরিবর্তন হয়নি।');
                  return;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget getPhoneWidget(BuildContext context, String phoneNumber) {
    return Row(
      children: [
        Expanded(
          child: Text(phoneNumber),
        ),
        IconButton(
          icon: const Icon(Icons.call),
          iconSize: 16.0,
          onPressed: () async {
            bool launched = await launch('tel:' + phoneNumber);
            if (!launched) {
              await showInformDialog(context, 'দুঃখিত', 'কোথাও সমস্যা হচ্ছে।');
            }
          },
        ),
      ],
    );
  }
}

class FilterCriteria extends ChangeNotifier {
  String _searchKey = '';
  List<String> _selectedBloodGroups = [];

  set setSearchKey(String newSearchKey) {
    _searchKey = newSearchKey;
    notifyListeners();
  }

  set setSelectedBloodGroups(List<String> newSelectedBloodGroups) {
    _selectedBloodGroups = newSelectedBloodGroups;
    notifyListeners();
  }

  String get getSearchKey => _searchKey;
  List<String> get getSelectedBloodGroups => _selectedBloodGroups;
}
