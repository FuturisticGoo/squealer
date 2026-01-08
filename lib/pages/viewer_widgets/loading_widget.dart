import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String loadingText;
  const LoadingWidget({super.key, this.loadingText = "Loading..."});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [CircularProgressIndicator(), Text(loadingText)],
      ),
    );
  }
}
