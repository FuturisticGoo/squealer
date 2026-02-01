import 'package:flutter/material.dart';
import 'package:futuristicgoo_utils/futuristicgoo_utils.dart';

Future<void> showProgressDialog<
  U extends ProgressUpdate,
  F extends ProgressFinished,
  E extends ProgressError
>(
  BuildContext context, {
  required String titleText,
  String subtitle = "Loading...",
}) {
  return showAdaptiveDialog<void>(
    context: context,
    builder: (context) {
      return _ProgressDialog<U, F, E>(titleText: titleText, subtitle: subtitle);
    },
  );
}

class _ProgressDialog<
  U extends ProgressUpdate,
  F extends ProgressFinished,
  E extends ProgressError
>
    extends StatefulWidget {
  final String titleText;
  final String subtitle;
  const _ProgressDialog({
    super.key,
    required this.titleText,
    required this.subtitle,
  });

  @override
  State<_ProgressDialog> createState() => _ProgressDialogState<U, F, E>();
}

class _ProgressDialogState<
  U extends ProgressUpdate,
  F extends ProgressFinished,
  E extends ProgressError
>
    extends State<_ProgressDialog> {
  double? _progressValue;
  bool _showOkButton = false;
  bool _isSubscribedToProgress = false;
  bool _exportSuccess = false;
  @override
  Widget build(BuildContext context) {
    if (!_isSubscribedToProgress) {
      _isSubscribedToProgress = true;
      GlobalProgressPipe.instance.subscribeToProgress<U, F, E>(
        onUpdate: (progressUpdate) {
          //TODO: fix this, it's not updating for  some reason
          if (context.mounted) {
            setState(() {
              _progressValue = progressUpdate.percentageFinished;
            });
          }
        },
        onFinish: (progressFinish) {
          if (context.mounted) {
            setState(() {
              _progressValue = 1;
              _showOkButton = true;
              _exportSuccess = true;
            });
          }
        },
        onError: (progressError) {
          if (context.mounted) {
            setState(() {
              _progressValue = 1;
              _showOkButton = true;
            });
          }
        },
      );
    }
    return SimpleDialog(
      title: Text(widget.titleText),
      contentPadding: EdgeInsetsGeometry.all(24.0),
      children: [
        SizedBox(height: 10),
        LinearProgressIndicator(value: _progressValue),
        SizedBox(height: 10),
        Text(_exportSuccess ? "Export complete!" : widget.subtitle),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
              onPressed: _showOkButton
                  ? () {
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Text("Ok"),
            ),
          ],
        ),
      ],
    );
  }
}
