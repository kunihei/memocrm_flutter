import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class CompanyListView extends HookConsumerWidget {
  const CompanyListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会社リスト'),
      ),
      body: Center(child: const Text('会社リストの内容')),
    );
  }
}