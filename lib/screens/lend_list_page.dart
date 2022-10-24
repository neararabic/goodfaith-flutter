import 'package:flutter/material.dart';
import 'package:good_faith/providers/lend_list_page_provider.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import 'package:provider/provider.dart';

class LendListPage extends StatefulWidget {
  final KeyPair keyPair;
  final String userAccountId;

  const LendListPage(
      {Key? key, required this.keyPair, required this.userAccountId})
      : super(key: key);

  @override
  State<LendListPage> createState() => _LendListPageState();
}

class _LendListPageState extends State<LendListPage>
    with WidgetsBindingObserver {
  late LendListProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<LendListProvider>(context);
    return buildCoinflipPage();
  }

  buildCoinflipPage() {
    return const Text("Lend List");
  }

  showTransactionMessage(BuildContext context) async {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(provider.transactionMessage),
      action: SnackBarAction(
        label: 'Hide',
        onPressed: () {
          setState(() {
            provider.transactionMessage = '';
          });
        },
      ),
    );
    if (provider.transactionMessage.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1), (() {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }));
    }
  }
}
