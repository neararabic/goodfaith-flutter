import 'package:flutter/material.dart';
import 'package:good_faith/providers/borrow_request_page_provider.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import 'package:provider/provider.dart';

class BorrowRequestPage extends StatefulWidget {
  final KeyPair keyPair;
  final String userAccountId;

  const BorrowRequestPage(
      {Key? key, required this.keyPair, required this.userAccountId})
      : super(key: key);

  @override
  State<BorrowRequestPage> createState() => _BorrowRequestPageState();
}

class _BorrowRequestPageState extends State<BorrowRequestPage>
    with WidgetsBindingObserver {
  late BorrowRequestPageProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<BorrowRequestPageProvider>(context);
    return buildCoinflipPage();
  }

  buildCoinflipPage() {
    return const Text("Borrow Request Form");
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
