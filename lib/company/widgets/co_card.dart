import 'package:flutter/material.dart';
import 'package:memocrm/company/models/co_models.dart';

/// 顧客一覧に表示する顧客1件分のカード。
///
/// 顧客名とメモ件数をまとめて表示し、タップ時に詳細画面などへ遷移するための
/// 操作領域として使う。
class CoCard extends StatelessWidget {
  const CoCard({
    super.key,
    required this.co,
    required this.index,
    required this.onTap,
  });

  /// カードに表示する顧客データ。
  final CoData co;

  /// 一覧内での表示順。
  ///
  /// 現時点では表示には使っていないが、並び順に応じた装飾や識別が必要になった時の
  /// ために親Widgetから受け取っている。
  final int index;

  /// カードをタップした時に実行する処理。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Card全体をInkWellで包み、見た目とタップ可能領域を一致させる。
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顧客を識別する主情報として顧客名を先頭に表示する。
              Text(co.coName),
              SizedBox(height: 20),
              Text('最終メモ: ${co.lastMemoTime}'),
              SizedBox(height: 20),
              // 顧客に紐づくメモ量を一覧上で確認できるようにする。
              Text('メモ件数: ${co.memoCount}'),
            ],
          ),
        ),
      ),
    );
  }
}
