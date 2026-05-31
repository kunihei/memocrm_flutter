import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/utils/messenger_key.dart';
import 'package:memocrm/memos/viewModel/memo_list_view_model.dart';
import 'package:memocrm/utils/loading_overlay.dart';

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

    final memoList = memoState.data;
    print('memoList: $memoList');

    return Scaffold(
      appBar: AppBar(
        title: Text(coName),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(coName),
              SizedBox(height: 10),
              Text('Company Code: $coCd'),
            ],
          ),
        ),
      ),
    );
  }
}
