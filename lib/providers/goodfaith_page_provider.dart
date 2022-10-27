import 'package:flutter/material.dart';
import 'package:lend_me/local_storage.dart';
import 'package:lend_me/providers/connect_wallet_provider.dart';

enum GoodFaithPageState { loggedIn, loggedout }

class GoodFaithProvider with ChangeNotifier {
  GoodFaithPageState state = GoodFaithPageState.loggedIn;

  //update and notify ui state
  void updateState(GoodFaithPageState state) {
    this.state = state;
    notifyListeners();
  }

  Future<void> logout() async {
    WalletConnectProvider().updateState(WalletConnectionState.resetingState);
    await LocalStorage.deleteKeys();
    updateState(GoodFaithPageState.loggedout);
  }

  //singleton
  static final GoodFaithProvider _singleton = GoodFaithProvider._internal();

  factory GoodFaithProvider() {
    return _singleton;
  }

  GoodFaithProvider._internal();
}
