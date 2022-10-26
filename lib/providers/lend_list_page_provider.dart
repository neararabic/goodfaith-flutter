import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:good_faith/local_storage.dart';
import 'package:good_faith/models/request.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import '../near/near_api_calls.dart';

enum LendListState { loadingList, loaded }

class LendListProvider with ChangeNotifier {
  LendListState state = LendListState.loadingList;
  String transactionMessage = "";
  List<Request> requests = [];

  Future<void> loadListData(
      {required KeyPair keyPair, required String userAccountId}) async {
    String method = 'getUnfulfilledRequests';
    String args = '{}';
    dynamic response;
    try {
      response = await NEARApi()
          .callViewFunction(userAccountId, keyPair, method, args);
      var result = utf8.decode(response['result']['result'].cast<int>());
      requests = (json.decode(result) as List)
          .map((e) => Request.fromJson(e))
          .toList();
    } catch (e) {
      transactionMessage = " RPC Error! Please try again later. ";
    }
    updateState(LendListState.loaded);
  }

  //update and notify ui state
  void updateState(LendListState state) {
    this.state = state;
    notifyListeners();
  }

  //singleton
  static final LendListProvider _singleton = LendListProvider._internal();

  factory LendListProvider() {
    return _singleton;
  }

  LendListProvider._internal();
}
