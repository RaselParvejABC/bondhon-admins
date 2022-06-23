import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:regexpattern/regexpattern.dart';
import '../../../utilities/Firebase/my_firebase_utilities.dart';
import '../../../utilities/JSON/my_json_utilities.dart';

class MemberInformationScreen extends StatelessWidget {
  final DocumentSnapshot donor;
  const MemberInformationScreen(this.donor, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String memberID =
        getFieldValueFromDocumentSnapshot(donor, 'memberID') ?? '';
    String nameInBanglaLetters =
        getFieldValueFromDocumentSnapshot(donor, 'nameInBanglaLetters') ?? '';
    String nameInEnglishLetters =
        getFieldValueFromDocumentSnapshot(donor, 'nameInEnglishLetters') ?? '';
    String bloodGroup =
        getFieldValueFromDocumentSnapshot(donor, 'bloodGroup') ?? '';
    String lastDonationDate =
        getFieldValueFromDocumentSnapshot(donor, 'lastDonationDate') ?? '';
    List<String> phoneNumbers = getListFromJSONArray(
        getFieldValueFromDocumentSnapshot(donor, 'phoneNumbers') ?? []);
    String fbProfileLink =
        getFieldValueFromDocumentSnapshot(donor, 'fbProfileLink') ?? '';
    String fatherOrHusbandName =
        getFieldValueFromDocumentSnapshot(donor, 'fatherOrHusbandName') ?? '';
    String motherName =
        getFieldValueFromDocumentSnapshot(donor, 'motherName') ?? '';
    String birthDate =
        getFieldValueFromDocumentSnapshot(donor, 'birthDate') ?? '';
    String profession =
        getFieldValueFromDocumentSnapshot(donor, 'profession') ?? '';
    Map<String, dynamic> currentAddress =
        getFieldValueFromDocumentSnapshot(donor, 'currentAddress') ?? {};
    String village = currentAddress['village'] ?? '';
    String post = currentAddress['post'] ?? '';
    String upazilla = currentAddress['upazilla'] ?? '';
    String district = currentAddress['district'] ?? '';

    String currentAddressString = [
      'গ্রামঃ $village',
      'পোস্টঃ $post',
      'উপজেলাঃ $upazilla',
      'জেলাঃ $district',
    ].join('\n');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('রক্তদাতার তথ্য'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(
                borderRadius: const BorderRadius.all(Radius.elliptical(3, 4)),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                1: FlexColumnWidth(2.0),
              },
              children: [
                TableRow(children: getTableRowCells('ডোনার আইডি', memberID)),
                TableRow(children: getTableRowCells('নাম (বাংলা)', nameInBanglaLetters)),
                TableRow(children: getTableRowCells('নাম (ইংরেজি)', nameInEnglishLetters)),
                TableRow(children: getTableRowCells('রক্তের গ্রুপ', bloodGroup)),
                TableRow(children: getTableRowCells('শেষ রক্তদানের তারিখ', lastDonationDate)),
                TableRow(children: getTableRowCells('দূরালাপন', phoneNumbers.join("\n"))),
                if(fbProfileLink.isUrl())
                TableRow(children: getTableRowCells('ফেসবুক প্রোফাইল', fbProfileLink)),
                TableRow(children: getTableRowCells('পিতা/স্বামীর নাম', fatherOrHusbandName)),
                TableRow(children: getTableRowCells('মাতা', motherName)),
                TableRow(children: getTableRowCells('জন্মতারিখ', birthDate)),
                TableRow(children: getTableRowCells('পেশা', profession)),
                TableRow(children: getTableRowCells('বর্তমান ঠিকানা', currentAddressString)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getTableRowCells(String key, String value) {
    return [
      getTableCell(key),
      getTableCell(value),
    ];
  }

  Widget getTableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectableText(content),
    );
  }
}