/// API 呼び出しの UI 状態を表現する軽量な Value Object。
///
/// 主に ViewModel / StateNotifier などが API リクエストの進行状態やエラーメッセージ
/// を持ち回るために使います。イミュータブルな設計で `copyWith` によって状態を
/// 部分的に更新します。
class ApiState {
  /// コンストラクタ
  /// - `isLoading`: ローディング中かどうか。デフォルトは `false`。
  /// - `errorMessage`: 表示するエラーメッセージ（なければ `null`）。
  const ApiState({this.isLoading = false, this.errorMessage});

  /// API のリクエストが進行中であれば `true`。
  final bool isLoading;

  /// エラー発生時にユーザーへ表示するメッセージ。
  /// - 通常は `null`（エラーなし）か簡潔な文字列を保持する。
  final String? errorMessage;

  /// 部分更新ユーティリティ
  ///
  /// - `isLoading`: ローディング状態を更新したい場合に指定。
  /// - `errorMessage`: 新しいエラーメッセージを設定する場合に指定。
  /// - `clearError`: `true` を渡すと `errorMessage` を強制的に `null` にする（優先度が高い）。
  ///
  /// 使い方の例:
  /// ```dart
  /// // ローディング開始
  /// state = state.copyWith(isLoading: true, clearError: true);
  ///
  /// // エラー発生（ローディング解除 + メッセージ設定）
  /// state = state.copyWith(isLoading: false, errorMessage: '通信に失敗しました');
  /// ```
  ApiState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ApiState(
      // 指定がなければ既存の値を引き継ぐ
      isLoading: isLoading ?? this.isLoading,
      // clearError が true の場合は null で上書き、それ以外は引数か既存の値
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
