import 'package:flutter/material.dart';

/// エラー用のシンプルなアラートを表示する
Future<void> showErrorDialog(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('エラー'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    ),
  );
}

/// 汎用的な情報のアラートを表示する
Future<void> showInfoDialog(
  BuildContext context,
  String title,
  String message,
) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    ),
  );
}
