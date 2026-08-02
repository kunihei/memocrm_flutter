import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memocrm/memos/models/memo_model.dart';
import 'package:memocrm/router/app_route.dart';

class MemoCard extends StatelessWidget {
  const MemoCard({super.key, required this.memo, this.onTap});

  final MemoData memo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B2559).withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${memo.tantoName} 様',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            memo.time,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8A8C92),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                            child: Text(
                              '削除',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  memo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF252634),
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  memo.content,
                  style: const TextStyle(
                    color: Color(0xFF8A8C92),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                  ),
                ),
                if (memo.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: memo.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
