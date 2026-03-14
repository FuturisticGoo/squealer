import 'package:flutter/material.dart';
import 'package:squealer/core/entities/failure_success.dart';

class ErrorInfoWidget extends StatelessWidget {
  final String errorText;
  final Failure failure;
  const ErrorInfoWidget({
    super.key,
    required this.errorText,
    required this.failure,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              errorText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Text(failure.toString()),
            if (failure case GenericFailure(:final error))
              Text(error.toString()),
            if (failure case GenericFailure(:final stackTrace))
              Text(stackTrace.toString()),
          ],
        ),
      ),
    );
  }
}
