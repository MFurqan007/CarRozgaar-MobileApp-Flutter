import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AdvertsRecord extends FirestoreRecord {
  AdvertsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "company" field.
  String? _company;
  String get company => _company ?? '';
  bool hasCompany() => _company != null;

  // "logo" field.
  String? _logo;
  String get logo => _logo ?? '';
  bool hasLogo() => _logo != null;

  // "rate" field.
  String? _rate;
  String get rate => _rate ?? '';
  bool hasRate() => _rate != null;

  // "detail" field.
  String? _detail;
  String get detail => _detail ?? '';
  bool hasDetail() => _detail != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "refnum" field.
  String? _refnum;
  String get refnum => _refnum ?? '';
  bool hasRefnum() => _refnum != null;

  void _initializeFields() {
    _company = snapshotData['company'] as String?;
    _logo = snapshotData['logo'] as String?;
    _rate = snapshotData['rate'] as String?;
    _detail = snapshotData['detail'] as String?;
    _date = snapshotData['date'] as DateTime?;
    _refnum = snapshotData['refnum'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('adverts');

  static Stream<AdvertsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AdvertsRecord.fromSnapshot(s));

  static Future<AdvertsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AdvertsRecord.fromSnapshot(s));

  static AdvertsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AdvertsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AdvertsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AdvertsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AdvertsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AdvertsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAdvertsRecordData({
  String? company,
  String? logo,
  String? rate,
  String? detail,
  DateTime? date,
  String? refnum,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'company': company,
      'logo': logo,
      'rate': rate,
      'detail': detail,
      'date': date,
      'refnum': refnum,
    }.withoutNulls,
  );

  return firestoreData;
}

class AdvertsRecordDocumentEquality implements Equality<AdvertsRecord> {
  const AdvertsRecordDocumentEquality();

  @override
  bool equals(AdvertsRecord? e1, AdvertsRecord? e2) {
    return e1?.company == e2?.company &&
        e1?.logo == e2?.logo &&
        e1?.rate == e2?.rate &&
        e1?.detail == e2?.detail &&
        e1?.date == e2?.date &&
        e1?.refnum == e2?.refnum;
  }

  @override
  int hash(AdvertsRecord? e) => const ListEquality()
      .hash([e?.company, e?.logo, e?.rate, e?.detail, e?.date, e?.refnum]);

  @override
  bool isValidKey(Object? o) => o is AdvertsRecord;
}
