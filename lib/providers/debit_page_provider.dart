import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lend_me/models/request.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import '../near/near_api_calls.dart';

enum DebitPageState { loading, loaded }

class DebitPageProvider with ChangeNotifier {
  DebitPageState state = DebitPageState.loading;
  String transactionMessage = "";
  List<Request> requests = [];

  Future<void> loadListData(
      {required KeyPair keyPair,
      required String userAccountId,
      Request? payedbackRequest}) async {
    String method = 'getAccountFulfilledRequests';
    String args = '{"accountId":"$userAccountId"}';
    dynamic response;

    if (payedbackRequest != null) {
      // Delay 1 second to make sure transactions finalized before getting updated data
      await Future.delayed(const Duration(seconds: 1));
    }
    try {
      response = await NEARApi()
          .callViewFunction(userAccountId, keyPair, method, args);
      var result = utf8.decode(response['result']['result'].cast<int>());
      requests = (json.decode(result) as List)
          .map((e) => Request.fromJson(e))
          .toList();
      if (payedbackRequest != null) {
        if (requests.contains(payedbackRequest)) {
          transactionMessage =
              "Something went wrong!\nplease make sure you follow the wallet and approve the transaction.";
        } else {
          transactionMessage = "Thank you for keeping your end of the deal";
        }
      }
    } catch (e) {
      transactionMessage = " RPC Error! Please try again later. ";
    }
    updateState(DebitPageState.loaded);
  }

  payback(KeyPair keyPair, String userAccountId, Request fullfilledRequest,
      double deposit) async {
    String method = 'payback';
    String args = '{"requestId":"${fullfilledRequest.id}"}';
    await NEARApi().callFunction(userAccountId, keyPair, deposit, method, args);
  }

  //update and notify ui state
  void updateState(DebitPageState state) {
    this.state = state;
    notifyListeners();
  }

  //singleton
  static final DebitPageProvider _singleton = DebitPageProvider._internal();

  factory DebitPageProvider() {
    return _singleton;
  }

  DebitPageProvider._internal();
}
