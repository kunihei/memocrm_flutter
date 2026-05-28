import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:memocrm/router/app_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/utils/messenger_key.dart';
import 'package:memocrm/company/view_model/co_list_view_model.dart';
import 'package:memocrm/company/widgets/widgets.dart';
import 'package:memocrm/utils/loading_overlay.dart';

/// 顧客会社の一覧を表示する画面。
///
/// 会社データを取得して一覧表示し、未登録時の空状態、読み込み中のローディング、
/// エラー時の通知までをまとめて扱う。
class CompanyListView extends HookConsumerWidget {
  const CompanyListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 一覧データ、読み込み状態、エラーメッセージをViewModelから購読する。
    final coState = ref.watch(coListViewModelProvider);

    // 画面表示直後に会社一覧を取得する。
    // build中に状態を更新しないよう、描画後のコールバックで実行する。
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(coListViewModelProvider.notifier).fetchCoList();
      });
      return null;
    }, [ref]);

    // データ取得などで発生したエラーをSnackBarでユーザーに知らせる。
    // 同じエラーを再表示し続けないよう、前回と違うメッセージだけ表示する。
    ref.listen<CoListState>(coListViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    // Pull-to-refreshで会社一覧を再取得するための処理。
    Future<void> refresh() async {
      await ref.read(coListViewModelProvider.notifier).fetchCoList();
    }

    // View側では状態オブジェクトから表示に必要な一覧データだけを取り出す。
    final coList = coState.data;

    // 一覧が空の場合は空状態のWidgetを表示し、データがある場合はカード形式で表示する。
    // RefreshIndicatorで包むことで、どちらの状態でも下に引っ張って再読み込みできる。
    final listView = RefreshIndicator(
      onRefresh: refresh,
      child: coList.isEmpty
          ? const EmptyCoList()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: coList.length,
              itemBuilder: (context, index) {
                final co = coList[index];
                return CoCard(
                  co: co,
                  onTap: () {
                    context.pushNamed(
                      AppName.memo,
                      pathParameters: {'coCd': co.coCd.toString()},
                      extra: co.coName,
                    );
                  },
                );
              },
            ),
    );

    // 読み込み中は画面全体にローディングを重ね、一覧操作と状態表示を分離する。
    return LoadingOverlay(
      isLoading: coState.isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('会社リスト')),
        body: listView,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('Add button pressed');
          },
          backgroundColor: const Color(0xFF0068B7),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
