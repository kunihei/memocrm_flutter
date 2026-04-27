// 目的：
// - ログイン画面の UI を組み立て、ログイン処理の実行とエラー表示を担当する。
//
// 概要：
// - 入力フォームの見た目や入力値の扱いは `LoginForm` に委譲する。
// - ログイン API の実行は `loginViewModelProvider` の ViewModel に委譲する。
// - ログイン成功後の画面遷移はこの画面では行わず、`GoRouter.redirect` に任せる。
// - この画面で行う副作用は、ログイン失敗時のエラーダイアログ表示だけに絞る。
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/login/view_model/login_viewmodel.dart';
import 'package:memocrm/utils/dialog_utils.dart';
import 'package:memocrm/login/widgets/login_form.dart';

/// ログイン画面を表示する Widget。
///
/// `HookConsumerWidget` を使っている理由：
/// - `ref.watch` で Riverpod の状態を読み、画面へ反映するため。
/// - `useEffect` でエラー表示のような UI 副作用を登録するため。
class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  /// 目的：
  /// - ログインフォームを表示し、ViewModel の状態変化に応じて UI を更新する。
  ///
  /// 概要：
  /// - `isLoading` をフォームへ渡し、ログイン処理中はボタンなどをローディング状態にできる。
  /// - `errorMessage` が新しく入ったときだけ、エラーダイアログを表示する。
  /// - 認証成功時の遷移は router 側が行うため、ここでは `context.go(...)` を呼ばない。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在のログイン状態を監視する。
    // `watch` は状態が変わるたびにこの Widget を再ビルドし、
    // `isLoading` などの表示状態を `LoginForm` に反映するために使う。
    final state = ref.watch(loginViewModelProvider);

    // useEffect は、Widget の描画後に一度だけ実行したい処理や、
    // 依存値が変わったときに登録し直したい副作用を扱うための Hook。
    //
    // ここでは画面の見た目を作るのではなく、
    // - エラー発生時にダイアログを表示する
    // という UI 側の副作用を ViewModel の状態変化に紐づけている。
    useEffect(() {
      // `listenManual` は Provider の状態変化を手動で購読するための仕組み。
      // `previous` には変更前の状態、`next` には変更後の状態が入る。
      // これにより「未ログイン → ログイン済み」のような変化だけを検知できる。
      final subscription = ref.listenManual<LoginState>(
        loginViewModelProvider,
        (previous, next) {
          // 変更前と変更後のエラーメッセージを比較する。
          // 新しいエラーが入った場合だけダイアログを表示したいので、
          // 同じエラーメッセージで何度も表示されないようにしている。
          final hadError = previous?.errorMessage;
          final newError = next.errorMessage;
          final shouldShowError = newError != null && newError != hadError;

          // 新しいエラーメッセージが入った場合だけダイアログを表示する。
          // 同じエラーで何度もダイアログが出ると操作しづらいため、前回値と比較している。
          if (shouldShowError) {
            // ダイアログ表示も画面遷移と同じく UI の副作用なので、
            // build 中ではなく現在のフレーム描画後に実行する。
            SchedulerBinding.instance.addPostFrameCallback((_) {
              // Widget が破棄されたあとに dialog を出そうとするとエラーになるため、
              // context がまだ有効か確認してから表示する。
              // `mounted` が false の場合は、すでにこの画面が閉じられている。
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
    // 画面側では API の詳細を知らず、ViewModel に処理を任せる。
    void handleLogin(String email, String password) {
      ref
          .read(loginViewModelProvider.notifier)
          .login(email: email, password: password);
    }

    return Scaffold(
      body: Center(
        child: LoginForm(
          isLoading: state.isLoading,
          // 認証済みの場合だけユーザー名をフォームへ渡す。
          // 未認証のときは null にして、フォーム側で未ログイン状態として扱えるようにする。
          name: state.isAuthenticated ? state.userName : null,
          onLogin: handleLogin,
        ),
      ),
    );
  }
}
