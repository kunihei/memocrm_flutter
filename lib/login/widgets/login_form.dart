import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 目的：
/// - ログイン画面で使用するメールアドレス・パスワード入力フォームを表示する。
/// - 入力値の簡単なバリデーションを行い、問題がなければ親 Widget へログイン処理を依頼する。
///
/// 概要：
/// - `HookWidget` を使い、`TextEditingController` とエラーメッセージ状態をこの Widget 内で管理する。
/// - メールアドレスまたはパスワードが未入力の場合は、API を呼ばずにフォーム上へエラーを表示する。
/// - 実際のログイン API 呼び出しや認証状態の更新はこの Widget では行わず、`onLogin` コールバック経由で外側へ委譲する。
/// - `isLoading` が true の間はログインボタンを無効化し、二重送信を防ぐ。
class LoginForm extends HookWidget {
  /// ログイン処理中かどうか。
  /// true の場合はログインボタンを押せない状態にする。
  final bool isLoading;

  /// ログイン済みユーザー名を受け取るための値。
  /// 現在この Widget 内では表示に使っていないが、親 Widget から状態を渡せるように保持している。
  final String? name;

  /// 入力チェックを通過したメールアドレスとパスワードを親 Widget へ渡すコールバック。
  /// この Widget はフォーム表示に専念し、ログイン処理本体は呼び出し元に任せる。
  final void Function(String email, String password) onLogin;

  const LoginForm({
    super.key,
    required this.isLoading,
    required this.name,
    required this.onLogin,
  });

  /// 入力欄の下線スタイルを作成する共通メソッド。
  /// エラーがある入力欄は赤、通常時はグレーの下線にする。
  InputBorder _underLineBorder({required bool hasError}) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? Colors.red : Colors.grey,
        width: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // メールアドレス入力欄のテキストを管理する Controller。
    // Hook を使うことで Widget の破棄時に自動で dispose される。
    final emailController = useTextEditingController();

    // パスワード入力欄のテキストを管理する Controller。
    final passController = useTextEditingController();

    // メールアドレス入力欄に表示するエラーメッセージ。
    // null の場合はエラー表示を行わない。
    final emailError = useState<String?>(null);

    // パスワード入力欄に表示するエラーメッセージ。
    final passError = useState<String?>(null);

    /// ログインボタン押下時の処理。
    /// 入力欄からフォーカスを外したあと、空欄チェックを行い、
    /// 問題がなければ `onLogin` で親 Widget にログイン処理を依頼する。
    void submit() {
      // キーボードを閉じるため、現在フォーカスされている入力欄からフォーカスを外す。
      FocusScope.of(context).unfocus();

      // 前後の空白を除去して、実際にログイン処理へ渡す値を作る。
      final email = emailController.text.trim();
      final pass = passController.text.trim();

      // 必須入力チェック。
      // 未入力の場合はそれぞれの入力欄の下にエラーメッセージを表示する。
      emailError.value = email.isEmpty ? 'メールアドレスを入力してください' : null;
      passError.value = pass.isEmpty ? 'パスワードを入力してください' : null;

      // どちらかにエラーがある場合は、ログイン処理を呼ばずにここで終了する。
      if (emailError.value != null || passError.value != null) {
        return;
      }

      // 入力チェックを通過した値を親 Widget へ渡す。
      onLogin(email, pass);
    }

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // メールアドレス入力欄。
          // 入力が変更されたら、表示中のメールアドレスエラーを消す。
          TextField(
            controller: emailController,
            onChanged: (_) {
              if (emailError.value != null) {
                emailError.value = null;
              }
            },
            decoration: InputDecoration(
              hintText: 'メールアドレス',
              enabledBorder: _underLineBorder(hasError: emailError.value != null),
              focusedBorder: _underLineBorder(hasError: emailError.value != null),
            ),
          ),
          // メールアドレスの入力エラーがある場合だけ、入力欄の下にメッセージを表示する。
          if (emailError.value != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(emailError.value!, style: TextStyle(color: Colors.red)),
            ),
          ],
          const SizedBox(height: 20),
          // パスワード入力欄。
          // `obscureText: true` により、入力内容を伏せ字で表示する。
          TextField(
            controller: passController,
            onChanged: (_) {
              if (passError.value != null) {
                passError.value = null;
              }
            },
            decoration: InputDecoration(
              hintText: 'パスワード',
              enabledBorder: _underLineBorder(
                hasError: passError.value != null,
              ),
              focusedBorder: _underLineBorder(
                hasError: passError.value != null,
              ),
            ),
            obscureText: true,
          ),
          // パスワードの入力エラーがある場合だけ、入力欄の下にメッセージを表示する。
          if (passError.value != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                passError.value!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // ログイン処理中はボタンを無効化し、連続タップによる二重送信を防ぐ。
                onPressed: isLoading ? null : submit,
                child: const Text('ログイン'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
