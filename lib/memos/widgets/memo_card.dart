import 'package:flutter/material.dart';
import 'package:memocrm/memos/models/memo_model.dart';

class MemoCard extends StatelessWidget {
  const MemoCard({super.key, required this.memo});

  final MemoData memo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 20, 22, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B2559).withValues(alpha: 0.66),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Expanded(
            child: Column(
              children: [
                Text(memo.title),
                SizedBox(height: 8),
                Text(memo.content),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
