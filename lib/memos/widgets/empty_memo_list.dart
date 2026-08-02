import 'package:flutter/material.dart';

class EmptyMemoList extends StatelessWidget {
  const EmptyMemoList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Center(child: Text('メモがありません'),)
      ],
    );
  }
}