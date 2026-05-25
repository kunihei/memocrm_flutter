import 'package:flutter/material.dart';
import 'package:memocrm/company/models/co_models.dart';

/// 顧客一覧に表示する顧客1件分のカード。
///
/// 顧客名とメモ件数をまとめて表示し、タップ時に詳細画面などへ遷移するための
/// 操作領域として使う。
class CoCard extends StatelessWidget {
  const CoCard({super.key, required this.co, required this.onTap});

  /// カードに表示する顧客データ。
  final CoData co;

  /// カードをタップした時に実行する処理。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Card全体をInkWellで包み、見た目とタップ可能領域を一致させる。
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        co.coName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF252634),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '最終メモ:${_formatLastMemoTime(co.lastMemoTime)}',
                        style: const TextStyle(
                          color: Color(0xFF747B8B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: Color(0xFF5D6472),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${co.memoCount}件のメモ',
                              style: const TextStyle(
                                color: Color(0xFF4E5563),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.chevron_right,
                    color: Color(0xFFB5BAC6),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastMemoTime(String value) {
    final dateTime = DateTime.tryParse(value);
    if (dateTime == null) {
      final lastColonIndex = value.lastIndexOf(':');
      return lastColonIndex == -1 ? value : value.substring(0, lastColonIndex);
    }
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 $hour:$minute';
  }
}
