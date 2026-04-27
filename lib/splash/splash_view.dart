// 目的：
// - アプリ起動直後やログイン状態の復元中に、待機中であることを表示する。
//
// 概要：
// - この画面ではログイン済みかどうかの判定は行わない。
// - 認証状態に応じた遷移は `GoRouter` の `redirect` に任せる。
// - 画面としてはローディング表示だけを担当し、責務を小さく保つ。
import 'package:flutter/material.dart';

/// スプラッシュ画面を表示する Widget。
///
/// `StatelessWidget` にしているのは、この画面自体が状態を持たないため。
/// セッション復元や画面遷移の判断は router 側で行う。
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  /// スプラッシュ画面の UI を組み立てる。
  ///
  /// ここでは中央に `CircularProgressIndicator` を出すだけにしている。
  /// ログイン画面や会社リスト画面を直接返さないことで、画面遷移の責務を
  /// `app_router.dart` に集約している。
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
