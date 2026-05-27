// 目的：
// - アプリ内で使うルート名とパスを一箇所で管理する。
//
// 概要：
// - `AppName` は `goNamed` などで使う画面の名前を定義する。
// - `AppPath` は URL として扱われる実際のパス文字列を定義する。
// - 文字列を各画面に直接書かず、このファイルを参照することでタイプミスを減らす。

/// `GoRoute.name` に設定するルート名をまとめたクラス。
///
/// ルート名は画面を「名前」で指定して遷移したいときに使う。
/// 例：`context.goNamed(AppName.company)`
class AppName {
  /// インスタンス化を防ぐための private コンストラクタ。
  ///
  /// このクラスは定数をまとめるためだけに使うので、`AppName()` のように
  /// オブジェクトを作る必要がない。
  const AppName._();

  /// スプラッシュ画面のルート名。
  static const splash = 'splash';

  /// ログイン画面のルート名。
  static const login = 'login';

  /// 動作確認や仮実装で使うダミー画面のルート名。
  static const dummy = 'dummy';

  /// 会社リスト画面のルート名。
  static const company = 'company';
}

/// `GoRoute.path` に設定する URL パスをまとめたクラス。
///
/// パスはブラウザの URL や `context.go(AppPath.company)` のような
/// パス指定の遷移で使われる。
class AppPath {
  /// インスタンス化を防ぐための private コンストラクタ。
  ///
  /// `AppName` と同じく、このクラスも定数をまとめるためだけに使う。
  const AppPath._();

  /// アプリ起動直後に表示するスプラッシュ画面のパス。
  static const splash = '/splash';

  /// ログイン画面のパス。
  ///
  /// 現在はアプリのルート `/` をログイン画面として扱っている。
  static const login = '/';

  /// ダミー画面のパス。
  static const dummy = '/dummy';

  /// 会社リスト画面のパス。
  static const company = '/company';
}
