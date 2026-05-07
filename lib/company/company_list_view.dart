import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/utils/messenger_key.dart';
import 'package:memocrm/company/view_model/co_list_view_model.dart';
import 'package:memocrm/company/widgets/widgets.dart';
import 'package:memocrm/utils/loading_overlay.dart';

class CompanyListView extends HookConsumerWidget {
  const CompanyListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coState = ref.watch(coListViewModelProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(coListViewModelProvider.notifier).fetchCoList();
      });
      return null;
    }, [ref]);

    ref.listen<CoListState>(coListViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    Future<void> refresh() async {
      await ref.read(coListViewModelProvider.notifier).fetchCoList();
    }

    final coList = coState.data;

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
                return CoCard(co: co, index: index, onTap: () {});
              },
            ),
    );

    return LoadingOverlay(
      isLoading: coState.isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('会社リスト')),
        body: listView,
      ),
    );
  }
}
