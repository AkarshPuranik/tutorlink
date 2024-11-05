import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentSubscriptionScreen extends StatefulWidget {
  const PaymentSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<PaymentSubscriptionScreen> createState() => _PaymentSubscriptionScreenState();
}

class _PaymentSubscriptionScreenState extends State<PaymentSubscriptionScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final expiryDate = DateTime.now().add(Duration(days: 7));
      await FirebaseFirestore.instance.collection('students').doc(user.uid).update({
        'subscriptionExpiry': Timestamp.fromDate(expiryDate),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subscription activated!")));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment failed. Please try again.")));
  }

  void _initiatePayment() {
    var options = {
      'key': 'rzp_test_wFEIWe7sxtp71p',
      'amount': 10000, // ₹100 in paise
      'name': 'Tutor Finder',
      'description': '7-Day Access to Tutor Contact Details',
      'prefill': {'contact': '9123456789', 'email': FirebaseAuth.instance.currentUser?.email},
    };

    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subscribe")),
      body: Center(
        child: ElevatedButton(
          onPressed: _initiatePayment,
          child: Text("Unlock Contact Details for ₹100 / 7 days"),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
