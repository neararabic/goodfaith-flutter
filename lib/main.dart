import 'package:flutter/material.dart';
import 'package:good_faith/providers/borrow_request_page_provider.dart';
import 'package:good_faith/providers/goodfaith_page_provider.dart';
import 'package:good_faith/providers/connect_wallet_provider.dart';
import 'package:good_faith/providers/lend_list_page_provider.dart';
import 'package:good_faith/screens/connect_wallet.dart';
import 'package:good_faith/screens/goodfaith_home_page.dart';
import 'package:good_faith/widgets/centered_progress_indicator_with_app_bar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Good Faith',
        theme: ThemeData(primarySwatch: Colors.blueGrey),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<WalletConnectProvider>(
                create: (_) => WalletConnectProvider()),
            ChangeNotifierProvider<GoodFaithProvider>(
                create: (_) => GoodFaithProvider()),
            ChangeNotifierProvider<LendListProvider>(
                create: (_) => LendListProvider()),
            ChangeNotifierProvider<BorrowRequestPageProvider>(
                create: (_) => BorrowRequestPageProvider())
          ],
          child: const AppContainer(),
        ));
  }
}

class AppContainer extends StatelessWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WalletConnectProvider provider =
        Provider.of<WalletConnectProvider>(context);

    switch (provider.state) {
      case WalletConnectionState.initial:
        provider.checkLoggedInUser();
        return const CenteredCircularProgressIndicatorWithAppBar();
      case WalletConnectionState.loggedIn:
        return GoodFaithPage(
            keyPair: provider.keyPair!, userAccountId: provider.userAccountId!);
      case WalletConnectionState.loggedOut:
      case WalletConnectionState.loginFailed:
        return const ConnectWalletScreen();
      case WalletConnectionState.validatingLogin:
        return const CenteredCircularProgressIndicatorWithAppBar();
      case WalletConnectionState.resetingState:
        provider.resetState();
        return const CenteredCircularProgressIndicatorWithAppBar();
    }
  }
}
