import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/login/view_model/login_viewmodel.dart';
import 'package:memocrm/router/app_route.dart';
import 'package:memocrm/utils/dialog_utils.dart';
import 'package:memocrm/login/widgets/login_form.dart';

/// 目的：
/// - ログイン画面の UI を組み立て、ViewModel の状態変化に応じた画面遷移や
///   エラーダイアログ表示を制御する。
///
/// 概要：
/// - `loginViewModelProvider` を監視して、ローディング状態や認証状態を取得する。
/// - 認証成功時は次画面へ遷移し、エラー発生時はダイアログを表示する。
/// - 実際の入力フォーム表示は `LoginForm` に委譲し、ログイン実行だけを受け持つ。
class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  /// 目的：
  /// - ログイン画面を描画し、ViewModel の状態変化に応じた副作用を登録する。
  ///
  /// 概要：
  /// - `ref.watch` でログイン状態を購読し、フォームへ必要な値を渡す。
  /// - `useEffect` 内で状態変化を監視し、認証成功時の画面遷移と
  ///   エラー発生時のダイアログ表示を post frame で安全に実行する。
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在のログイン状態を監視する。
    // `watch` は状態が変わるたびにこの Widget を再ビルドし、
    // `isLoading` などの表示状態を `LoginForm` に反映するために使う。
    final state = ref.watch(loginViewModelProvider);

    // useEffect は、Widget の描画後に一度だけ実行したい処理や、
    // 依存値が変わったときに登録し直したい副作用を扱うための Hook。
    //
    // ここでは画面の見た目を作るのではなく、
    // - ログイン成功時に画面遷移する
    // - エラー発生時にダイアログを表示する
    // という UI 側の副作用を ViewModel の状態変化に紐づけている。
    useEffect(() {
      // `listenManual` は Provider の状態変化を手動で購読するための仕組み。
      // `previous` には変更前の状態、`next` には変更後の状態が入る。
      // これにより「未ログイン → ログイン済み」のような変化だけを検知できる。
      final subscription = ref.listenManual<LoginState>(
        loginViewModelProvider,
        (previous, next) {
          // 変更前の認証状態を取得する。
          // 初回は previous が null になる可能性があるため、未認証として扱う。
          final wasAuthenticated = previous?.isAuthenticated ?? false;

          // 未認証状態から認証済み状態に変わったタイミングだけ画面遷移する。
          // next.isAuthenticated だけを見ると、再ビルドや状態更新のたびに
          // 何度も遷移処理が走る可能性があるため、previous と next を比較している。
          if (!wasAuthenticated && next.isAuthenticated) {
            // 画面遷移は build 中に直接実行すると Flutter の描画処理と衝突することがある。
            // そのため、現在のフレーム描画が終わったあとに実行するよう予約する。
            SchedulerBinding.instance.addPostFrameCallback((_) {
              // 予約した処理が実行される時点で、この Widget が破棄済みの可能性がある。
              // `mounted` を確認してから context を使うことで、安全に画面遷移する。
              if (context.mounted) {
                context.goNamed(AppRoute.dummy, extra: next.userName);
              }
            });
          }

          // 変更前と変更後のエラーメッセージを比較する。
          // 新しいエラーが入った場合だけダイアログを表示したいので、
          // 同じエラーメッセージで何度も表示されないようにしている。
          final hadError = previous?.errorMessage;
          final newError = next.errorMessage;
          final shouldShowError = newError != null && newError != hadError;

          if (shouldShowError) {
            // ダイアログ表示も画面遷移と同じく UI の副作用なので、
            // build 中ではなく現在のフレーム描画後に実行する。
            SchedulerBinding.instance.addPostFrameCallback((_) {
              // Widget が破棄されたあとに dialog を出そうとするとエラーになるため、
              // context がまだ有効か確認してから表示する。
              if (!context.mounted) {
                return;
              }
              showErrorDialog(context, newError);
            });
          }
        },
      );

      // useEffect の戻り値はクリーンアップ処理。
      // LoginView が破棄されるとき、または依存値が変わって useEffect が再実行される前に呼ばれる。
      // Provider の購読を閉じて、不要な監視が残らないようにする。
      return () => subscription.close();
    }, [ref, context]);

    // フォームから受け取った入力値を ViewModel のログイン処理へ渡す。
    void handleLogin(String email, String password) {
      ref
          .read(loginViewModelProvider.notifier)
          .login(email: email, password: password);
    }

    return Scaffold(
      body: Center(
        child: LoginForm(
          isLoading: state.isLoading,
          name: state.isAuthenticated ? state.userName : null,
          onLogin: handleLogin,
        ),
      ),
    );
  }
}
