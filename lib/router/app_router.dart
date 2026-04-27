// 目的：
// - アプリ全体の画面遷移ルールを `GoRouter` に集約する。
//
// 概要：
// - 起動直後はスプラッシュ画面を表示し、保存済みログイン情報の復元を待つ。
// - 復元が終わったら、ログイン済みなら会社リスト画面、未ログインならログイン画面へ遷移する。
// - ログイン状態が変わったときだけ router に再判定を通知し、`GoRouter` 自体の作り直しは避ける。
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/company/company_list_view.dart';
import 'package:memocrm/dummy/dummy_view.dart';
import 'package:memocrm/login/login_view.dart';
import 'package:memocrm/login/view_model/login_viewmodel.dart';
import 'package:memocrm/router/app_route.dart';
import 'package:memocrm/splash/splash_view.dart';

/// アプリ全体で使う `GoRouter` を生成する Provider。
///
/// `GoRouter` は画面遷移の中心になるオブジェクトなので、ログイン状態が変わるたびに
/// 作り直すのではなく、`refreshListenable` で「遷移条件をもう一度確認して」と通知する。
/// これにより、router の責務は保ったまま、不要な再生成を避けられる。
final goRouterProvider = Provider<GoRouter>((ref) {
  // `GoRouter` に redirect の再評価を知らせるための通知用オブジェクト。
  // 値そのものには意味はなく、値が変わることを通知として使っている。
  final routerRefreshNotifier = ValueNotifier<int>(0);

  // ログイン状態が変わったときに、router へ再判定を依頼する。
  // `ref.watch` ではなく `ref.listen` を使うことで、Provider 全体の再生成を避けている。
  ref.listen<LoginState>(loginViewModelProvider, (_, __) {
    routerRefreshNotifier.value++;
  });

  // `goRouterProvider` が破棄されたとき、通知用オブジェクトも破棄してメモリリークを防ぐ。
  ref.onDispose(routerRefreshNotifier.dispose);

  // アプリ起動直後に保存済みセッションを復元する。
  // microtask にすることで、Provider の生成処理が終わった後に非同期処理を開始できる。
  Future.microtask(() {
    ref.read(loginViewModelProvider.notifier).restoreSession();
  });

  return GoRouter(
    initialLocation: AppPath.splash,
    refreshListenable: routerRefreshNotifier,
    redirect: (context, state) {
      final loginState = ref.read(loginViewModelProvider);
      return _redirectByLoginState(loginState: loginState, routeState: state);
    },
    routes: [
      GoRoute(
        path: AppPath.splash,
        name: AppName.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppPath.login,
        name: AppName.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppPath.dummy,
        name: AppName.dummy,
        builder: (context, state) => const DummyView(),
      ),
      GoRoute(
        path: AppPath.company,
        name: AppName.company,
        builder: (context, state) => const CompanyListView(),
      ),
    ],
  );
});

/// ログイン状態と現在の場所から、遷移先を決める。
///
/// 戻り値の意味：
/// - `null` の場合は、現在の画面にそのまま留まる。
/// - パス文字列を返す場合は、`GoRouter` がそのパスへ自動で遷移する。
///
/// この関数に認証まわりの遷移ルールを集めることで、各画面側に
/// `context.go(...)` のような個別遷移を書かなくて済むようにしている。
String? _redirectByLoginState({
  required LoginState loginState,
  required GoRouterState routeState,
}) {
  final location = routeState.matchedLocation;
  final isSplash = location == AppPath.splash;
  final isLogin = location == AppPath.login;
  final isAuthenticated = loginState.isAuthenticated;

  // セッション復元中は、ログイン済みかどうかがまだ確定していない。
  // そのため、スプラッシュ画面以外にいる場合は一度スプラッシュへ戻す。
  if (loginState.isRestoring) {
    return isSplash ? null : AppPath.splash;
  }

  // スプラッシュ画面は待機用の画面なので、復元完了後は必ず次の画面へ進める。
  // ログイン済みなら会社リスト、未ログインならログイン画面へ振り分ける。
  if (isSplash) {
    return isAuthenticated ? AppPath.company : AppPath.login;
  }

  // 未ログインのユーザーがログイン画面以外へ行こうとした場合は、ログイン画面へ戻す。
  // これにより、URL 直打ちや不正な遷移でも認証が必要な画面を表示しない。
  if (!isAuthenticated && !isLogin) {
    return AppPath.login;
  }

  // ログイン済みのユーザーがログイン画面へ戻った場合は、会社リストへ送る。
  // すでにログインしているのにログインフォームが出る状態を防ぐため。
  if (isAuthenticated && isLogin) {
    return AppPath.company;
  }

  // 上のどの条件にも当てはまらない場合は、現在の画面表示を続ける。
  return null;
}
