import 'package:flutter/material.dart';

class EmptyMemo extends StatelessWidget {
  const EmptyMemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120),
        Center(child: Text('メモがありません')),
      ],
    );
  }
}
