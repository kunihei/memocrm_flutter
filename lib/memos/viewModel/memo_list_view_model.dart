import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/memos/models/memo_model.dart';
import 'package:memocrm/memos/repo/memo_repo.dart';
import 'package:memocrm/utils/api/api_state.dart';

class MemoListState extends ApiState {
  const MemoListState({
    super.isLoading = false,
    super.errorMessage,
    this.data = const [],
  });

  final List<MemoData> data;

  @override
  MemoListState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<MemoData>? data,
  }) {
    final baseState = super.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      clearError: clearError,
    );
    return MemoListState(
      isLoading: baseState.isLoading,
      errorMessage: baseState.errorMessage,
      data: data ?? this.data,
    );
  }
}

class MemoListViewModel extends Notifier<MemoListState> {
  late final MemoRepo _repository;

  @override
  MemoListState build() {
    _repository = ref.watch(memoRepoProvider);
    return const MemoListState();
  }

  Future<void> fetchMemoList(int coCd) async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.fetchMemoList(coCd);
      if (response.isSuccess) {
        state = state.copyWith(isLoading: false, data: response.data);
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'メモの取得に失敗しました',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'メモの取得に失敗しました');
    }
  }
}

final memoListViewModelProvider =
    NotifierProvider<MemoListViewModel, MemoListState>(MemoListViewModel.new);
