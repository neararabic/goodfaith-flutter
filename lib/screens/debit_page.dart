import 'package:flutter/material.dart';
import 'package:lend_me/constants.dart';
import 'package:lend_me/models/request.dart';
import 'package:lend_me/providers/debit_page_provider.dart';
import 'package:lend_me/widgets/centered_progress_indicator.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import 'package:provider/provider.dart';

class DebitPage extends StatefulWidget {
  final KeyPair keyPair;
  final String userAccountId;

  const DebitPage(
      {Key? key, required this.keyPair, required this.userAccountId})
      : super(key: key);

  @override
  State<DebitPage> createState() => _DebitPageState();
}

class _DebitPageState extends State<DebitPage> with WidgetsBindingObserver {
  late BuildContext buildContext;
  late DebitPageProvider provider;
  Request? requestToBePayedback;
  final List<bool> selectedFilters = <bool>[true, false];
  final List<Widget> filters = const [
    Text('All'),
    Text('Owed'),
  ];
  BigInt totalDebit = BigInt.zero;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<DebitPageProvider>(context);
    calculateTotalDebit();
    switch (provider.state) {
      case DebitPageState.loading:
        provider.loadListData(
            userAccountId: widget.userAccountId,
            keyPair: widget.keyPair,
            payedbackRequest: requestToBePayedback);
        return const CenteredCircularProgressIndicator();
      case DebitPageState.loaded:
        showTransactionMessage(context);
        return buildDebitPage();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  buildDebitPage() {
    return RefreshIndicator(
      onRefresh: () async {
        provider.updateState(DebitPageState.loading);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Debit",
                      style: Constants.HEADING_1,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ToggleButtons(
                      direction: Axis.horizontal,
                      onPressed: (int index) {
                        setState(() {
                          totalDebit = BigInt.zero;
                          // The button that is tapped is set to true, and the others to false.
                          for (int i = 0; i < selectedFilters.length; i++) {
                            selectedFilters[i] = i == index;
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      constraints: const BoxConstraints(
                        minHeight: 40.0,
                        minWidth: 80.0,
                      ),
                      isSelected: selectedFilters,
                      children: filters,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: provider.requests.length,
                      itemBuilder: (context, index) {
                        Request request = provider.requests[index];
                        String requestAmountInNear =
                            yoctoToNear(request.amount.toString());
                        if (selectedFilters[0] ||
                            selectedFilters[1] &&
                                request.borrower == widget.userAccountId) {
                          String headingAccountId =
                              request.lender == widget.userAccountId
                                  ? request.borrower
                                  : request.lender;
                          return ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            minVerticalPadding: 15,
                            horizontalTitleGap: 0,
                            minLeadingWidth: 0,
                            leading: request.lender != widget.userAccountId
                                ? const VerticalDivider(
                                    color: Colors.deepOrange,
                                    thickness: 3,
                                  )
                                : const SizedBox(
                                    width: 15,
                                  ),
                            title: Text(
                                '$headingAccountId - $requestAmountInNearⓃ'),
                            subtitle: Text(
                                '${request.desc}\n${DateTime.fromMicrosecondsSinceEpoch((request.paybackTimestamp ~/ BigInt.from(1000)).toInt()).toString().substring(0, 16)}'),
                            trailing: (request.lender != widget.userAccountId)
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.deepOrange),
                                    onPressed: () {
                                      requestToBePayedback = request;
                                      provider.payback(
                                          widget.keyPair,
                                          widget.userAccountId,
                                          request,
                                          double.parse(requestAmountInNear));
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Payback'),
                                    ),
                                  )
                                : Container(
                                    width: 20,
                                  ),
                            isThreeLine: true,
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(
                      color: Colors.blueGrey,
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Total Debit: "),
                        Text(yoctoToNear(totalDebit.toString()))
                      ],
                    )
                  ]),
            ),
          ),
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

  calculateTotalDebit() {
    totalDebit = BigInt.zero;
    if (provider.requests.isNotEmpty) {
      for (var request in provider.requests) {
        if (selectedFilters[0] ||
            selectedFilters[1] && request.borrower == widget.userAccountId) {
          setState(() {
            if (request.lender == widget.userAccountId) {
              totalDebit += request.amount;
            } else {
              totalDebit -= request.amount;
            }
          });
        }
      }
    }
  }

  //this is to reload requests when coming back from signing
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //detect when app opens back after connecting to te wallet
    switch (state) {
      case AppLifecycleState.resumed:
        if (provider.state == DebitPageState.loaded) {
          provider.updateState(DebitPageState.loading);
        }
        break;
      default:
        break;
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
      provider.transactionMessage = '';
    }
  }
}
