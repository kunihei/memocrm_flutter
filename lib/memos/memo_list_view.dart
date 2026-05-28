import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoListView extends HookConsumerWidget {
  final int coCd;
  final String coName;

  const MemoListView({super.key, required this.coCd, required this.coName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(coName),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(coName),
              SizedBox(height: 10),
              Text('Company Code: $coCd'),
            ],
          ),
        ),
      )
    );
  }
}
