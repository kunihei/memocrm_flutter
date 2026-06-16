import 'package:flutter/material.dart';

class MemoHistoryTitleGroup extends StatelessWidget {
  const MemoHistoryTitleGroup({
    super.key,
    required this.onSort,
    required this.onSearch,
  });

  final VoidCallback onSort;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'メモ履歴',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        IconButton(
          onPressed: onSort,
          iconSize: 30,
          icon: const Icon(Icons.sort),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: onSearch,
          iconSize: 30,
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}
