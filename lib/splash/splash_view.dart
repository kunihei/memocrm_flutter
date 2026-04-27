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
/// `StatefulWidget` にしているのは、ローディング表示をふわっと出すための
/// アニメーション状態を持つ必要があるため。
/// セッション復元や画面遷移の判断は router 側で行う。
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

/// スプラッシュ画面内のフェード表示を管理する State。
///
/// ここで行っているフェードは「画面内のローディングをふわっと表示する」ためのもの。
/// スプラッシュ画面から次画面へ移るときのフェード遷移は `app_router.dart` 側で制御する。
class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  /// アニメーションを準備し、画面表示時にフェードインを開始する。
  ///
  /// `AnimationController` は時間の進み方を管理し、`CurvedAnimation` は
  /// 動きが自然に見えるように変化のカーブを付ける。
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  /// 画面が破棄されるときに、アニメーション用のリソースを解放する。
  ///
  /// `AnimationController` は内部で ticker を使うため、使い終わったら
  /// `dispose` して不要な処理が残らないようにする。
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// スプラッシュ画面の UI を組み立てる。
  ///
  /// 中央の `CircularProgressIndicator` を `FadeTransition` で包み、
  /// 起動直後にふわっと表示されるようにしている。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
