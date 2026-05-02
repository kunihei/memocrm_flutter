import 'package:flutter/material.dart';

class EmptyCoList extends StatelessWidget {
  const EmptyCoList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120),
        Center(child: Text('顧客がいません')),
      ],
    );
  }
}
