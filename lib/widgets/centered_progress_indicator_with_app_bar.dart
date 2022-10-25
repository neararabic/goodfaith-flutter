import 'package:flutter/material.dart';

class CenteredCircularProgressIndicatorWithAppBar extends StatelessWidget {
  const CenteredCircularProgressIndicatorWithAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Good Faith")),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
