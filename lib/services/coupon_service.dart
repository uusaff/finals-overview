import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize the database with the default coupon if it doesn't exist
  // We do this just so the @S1zLtTM code works immediately for the developer
  Future<void> initializeDefaultCoupon() async {
    try {
      final doc = await _firestore.collection('coupons').doc('@S1zLtTM').get();
      if (!doc.exists) {
        await _firestore.collection('coupons').doc('@S1zLtTM').set({
          'code': '@S1zLtTM',
          'type': 'lifetime_pro',
          'active': true,
        });
      }
    } catch (e) {
      debugPrint("Error initializing default coupon: $e");
    }
  }

  // Verifies the coupon against Firestore
  Future<bool> verifyCoupon(String code) async {
    try {
      final snapshot = await _firestore
          .collection('coupons')
          .where('code', isEqualTo: code)
          .where('active', isEqualTo: true)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error verifying coupon: $e");
      return false;
    }
  }
}
