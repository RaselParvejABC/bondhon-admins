import 'package:cloud_firestore/cloud_firestore.dart';

dynamic getFieldValueFromDocumentSnapshot(DocumentSnapshot doc, String field) {
  try {
    return doc.get(field);
  } catch (error) {
    return null;
  }
}