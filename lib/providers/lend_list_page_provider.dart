import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:good_faith/local_storage.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import '../near/near_api_calls.dart';

enum LendListState { loadingList, loaded }

class LendListProvider with ChangeNotifier {
  LendListState state = LendListState.loadingList;
  String transactionMessage = "";

  Future<void> loadPageData(
      {required KeyPair keyPair,
      required String userAccountId}) async {
    // Delay 1 second to make sure transactions finalized before getting updated data
    await Future.delayed(const Duration(seconds: 1));

    // // Get player data
    // String method = 'viewPlayer';
    // String args = '{"accountId":"$userAccountId"}';
    // if (!saveTransactionMessage) {
    //   transactionMessage = "";
    // }
    // try {
    //   var response = await NEARApi()
    //       .callViewFunction(userAccountId, keyPair, method, args);
    //   var decodedResult = utf8.decode(response['result']['result'].cast<int>());
    // } catch (e) {
    //   transactionMessage = "RPC Error! Please try again later.";
    // }

    // // Get leaderboad data
    // method = 'viewLeaderboard';
    // args = '{}';
    // try {
    //   var response = await NEARApi()
    //       .callViewFunction(userAccountId, keyPair, method, args);
    //   var decodedResult = utf8.decode(response['result']['result'].cast<int>());
    //   leaderboard = (json.decode(decodedResult) as List)
    //       .map((e) => Player.fromJson(e))
    //       .toList();
    // } catch (e) {
    //   transactionMessage = "RPC Error! Please try again later.";
    // }

    updateState(LendListState.loaded);
  }

  //update and notify ui state
  void updateState(LendListState state) {
    this.state = state;
    notifyListeners();
  }

  //singleton
  static final LendListProvider _singleton =
      LendListProvider._internal();

  factory LendListProvider() {
    return _singleton;
  }

  LendListProvider._internal();
}
