import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:good_faith/local_storage.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import '../near/near_api_calls.dart';

enum BorrowRequestPageState { init, loading }

class BorrowRequestPageProvider with ChangeNotifier {
  BorrowRequestPageState state = BorrowRequestPageState.init;
  String transactionMessage = "";

  //update and notify ui state
  void updateState(BorrowRequestPageState state) {
    this.state = state;
    notifyListeners();
  }

  //singleton
  static final BorrowRequestPageProvider _singleton =
      BorrowRequestPageProvider._internal();

  factory BorrowRequestPageProvider() {
    return _singleton;
  }

  BorrowRequestPageProvider._internal();
}
