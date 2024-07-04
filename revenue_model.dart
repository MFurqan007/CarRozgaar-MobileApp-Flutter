import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevenueModel with ChangeNotifier {
  double _revenue = 0.0;

  double get revenue => _revenue;

  Future<void> fetchInitialRevenue() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    var walletDoc =
        await FirebaseFirestore.instance.collection('wallet').doc(userId).get();
    if (walletDoc.exists) {
      _revenue = double.parse(walletDoc.data()?['revenue'] ?? '0');
      notifyListeners();
    }
  }

  void updateRevenue(double amount) {
    _revenue += amount;
    notifyListeners();
    _updateRevenueFirestore();
  }

  Future<void> _updateRevenueFirestore() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('wallet').doc(userId).set({
      'revenue': _revenue.toString(),
    }, SetOptions(merge: true));
  }
}
