import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/dummy/dummy_view.dart';
import 'package:memocrm/login/login_view.dart';
import 'package:memocrm/router/app_route.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppPath.login,
    routes: [
      GoRoute(
        path: AppPath.login,
        name: AppRoute.login,
        builder: (context, state) => LoginView(),
      ),
      GoRoute(
        path: AppPath.dummy,
        name: AppRoute.dummy,
        builder: (context, state) => DummyView(),
      ),
    ],
  );
});
