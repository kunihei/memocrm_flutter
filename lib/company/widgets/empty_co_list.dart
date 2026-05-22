import 'package:flutter/material.dart';

/// 顧客一覧が空の時に表示するプレースホルダー。
///
/// 一覧画面側の状態分岐をシンプルに保つため、空状態の表示だけをこのWidgetに
/// 切り出している。
class EmptyCoList extends StatelessWidget {
  const EmptyCoList({super.key});

  @override
  Widget build(BuildContext context) {
    // RefreshIndicatorなどの親Widgetと組み合わせても下方向に引っ張れるように、
    // 空状態でも常にスクロール可能なListViewとして返す。
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // 画面上部に余白を取り、空状態メッセージが詰まって見えないようにする。
        SizedBox(height: 120),
        // 顧客データが存在しないことをユーザーに明示する。
        Center(child: Text('顧客がいません')),
      ],
    );
  }
}
