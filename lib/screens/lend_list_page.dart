import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:good_faith/constants.dart';
import 'package:good_faith/models/request.dart';
import 'package:good_faith/providers/lend_list_page_provider.dart';
import 'package:good_faith/widgets/centered_progress_indicator.dart';
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
    switch (provider.state) {
      case LendListState.loadingList:
        provider.loadListData(
            userAccountId: widget.userAccountId, keyPair: widget.keyPair);
        return const CenteredCircularProgressIndicator();
      case LendListState.loaded:
        return buildLendListPage();
    }
  }

  buildLendListPage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Text(
              "Borrow Requests",
              style: Constants.HEADING_1,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.requests.length,
                itemBuilder: (context, index) {
                  Request request = provider.requests[index];
                  if (request.lender == '' ||
                      request.lender == widget.userAccountId &&
                          request.borrower != widget.userAccountId) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      horizontalTitleGap: 0,
                      minLeadingWidth: 0,
                      leading: request.lender == widget.userAccountId
                          ? const VerticalDivider(
                              color: Colors.deepOrange,
                              thickness: 3,
                            )
                          : const SizedBox(
                              width: 15,
                            ),
                      title: Text(
                          '${request.borrower} - ${yoctoToNear(request.amount.toString())}Ⓝ'),
                      subtitle: Text(
                          '${request.desc}\n${DateTime.fromMicrosecondsSinceEpoch((request.paybackTimestamp ~/ BigInt.from(1000)).toInt())}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.deepOrange),
                        onPressed: () {},
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Lend'),
                        ),
                      ),
                      isThreeLine: true,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            )
          ]),
        ),
      ),
    );
  }

  String yoctoToNear(String yocto) {
    if (yocto == '0') {
      return yocto;
    } else {
      double parsed = double.parse(yocto);
      double oneNear = 1000000000000000000000000.0;
      return (parsed / oneNear).toStringAsFixed(3);
    }
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
