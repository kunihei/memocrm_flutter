import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/memos/viewModel/memo_list_view_model.dart';
import 'package:memocrm/memos/widgets/widgets.dart';
import 'package:memocrm/router/app_route.dart';
import 'package:memocrm/utils/loading_overlay.dart';
import 'package:memocrm/utils/messenger_key.dart';

class MemoListView extends HookConsumerWidget {
  final int coCd;
  final String coName;

  const MemoListView({super.key, required this.coCd, required this.coName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoState = ref.watch(memoListViewModelProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(memoListViewModelProvider.notifier).fetchMemoList(coCd);
      });
      return null;
    }, [ref]);

    ref.listen<MemoListState>(memoListViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    Future<void> refresh() async {
      await ref.read(memoListViewModelProvider.notifier).fetchMemoList(coCd);
    }

    final memoList = memoState.data;

    final listView = RefreshIndicator(
      onRefresh: refresh,
      child: memoList.isEmpty
          ? const EmptyMemo()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: memoList.length,
              itemBuilder: (context, index) {
                final memo = memoList[index];
                return MemoCard(memo: memo);
              },
            ),
    );

    return LoadingOverlay(
      isLoading: memoState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(coName),
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.pushNamed(AppName.dummy);
          },
          backgroundColor: const Color(0xFF0068B7),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        body: listView,
      ),
    );
  }
}
