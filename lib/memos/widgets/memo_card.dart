import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memocrm/memos/models/memo_model.dart';
import 'package:memocrm/router/app_route.dart';

class MemoCard extends StatelessWidget {
  const MemoCard({super.key, required this.memo});

  final MemoData memo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.fromLTRB(22, 20, 22, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${memo.tantoName} 様',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      memo.time,
                      style: TextStyle(fontSize: 14, color: Color(0xFF8A8C92)),
                    ),
                  ],
                ),
                Spacer(),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.pushNamed(AppName.dummy);
                      }
                      if (value == 'delete') {
                        print('削除');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        height: 35,
                        value: 'edit',
                        child: Text('編集'),
                      ),
                      const PopupMenuDivider(height: 1),
                      const PopupMenuItem(
                        height: 35,
                        value: 'delete',
                        child: Text('削除', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              memo.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(memo.content, style: const TextStyle(color: Color(0xFF8A8C92))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: memo.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(206, 241, 242, 246),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag.tagName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
