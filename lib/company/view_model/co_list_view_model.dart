import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/company/models/co_models.dart';
import 'package:memocrm/company/repo/co_repo.dart';
import 'package:memocrm/utils/api/api_state.dart';

/// 企業一覧画面の状態を表す State クラス。
///
/// 目的:
/// - 企業一覧画面で必要になる「読み込み中かどうか」「エラーメッセージ」「企業一覧データ」をまとめて管理する。
/// - ViewModel から画面へ渡す状態を 1 つのオブジェクトにまとめ、UI 側が状態を参照しやすくする。
///
/// 概要:
/// - [ApiState] を継承しているため、共通の `isLoading` と `errorMessage` を利用できる。
/// - この画面固有の状態として、企業データの一覧である [data] を追加している。
/// - 状態更新は直接フィールドを書き換えず、[copyWith] で新しい [CoListState] を作って差し替える。
class CoListState extends ApiState {
  /// 企業一覧画面の状態を作成する。
  ///
  /// 初期状態では以下になる。
  /// - `isLoading`: false。まだ通信中ではない。
  /// - `errorMessage`: null。まだエラーは発生していない。
  /// - `data`: 空リスト。まだ企業一覧を取得していない。
  const CoListState({
    super.isLoading = false,
    super.errorMessage,
    this.data = const [],
  });

  /// API から取得した企業一覧データ。
  ///
  /// 画面側ではこのリストを使って企業一覧を表示する。
  /// 初期値は空リストなので、データ取得前でも null チェックなしで扱える。
  final List<CoData> data;

  /// 現在の状態をもとに、一部の値だけを変更した新しい [CoListState] を作る。
  ///
  /// 処理の流れ:
  /// 1. 親クラス [ApiState] の [copyWith] を呼び出し、共通状態である `isLoading` と `errorMessage` を更新する。
  /// 2. 親クラス側で作られた状態から、更新後の `isLoading` と `errorMessage` を取り出す。
  /// 3. 企業一覧データ [data] は、引数で渡された場合だけ新しい値に差し替える。
  /// 4. 更新後の値を使って、新しい [CoListState] を返す。
  ///
  /// `clearError` について:
  /// - true を渡すと、親クラス側の [ApiState.copyWith] でエラーメッセージをクリアする想定。
  /// - API 再取得前に前回のエラー表示を消したい場合に使う。
  @override
  CoListState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<CoData>? data,
  }) {
    final baseState = super.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      clearError: clearError,
    );
    return CoListState(
      isLoading: baseState.isLoading,
      errorMessage: baseState.errorMessage,
      data: data ?? this.data,
    );
  }
}

/// 企業一覧画面の状態管理と API 呼び出しを担当する ViewModel。
///
/// 目的:
/// - 画面から直接 Repository を呼ばず、ViewModel 経由で企業一覧取得処理を実行する。
/// - API 通信中、成功時、失敗時の状態更新をこのクラスに集約する。
///
/// 概要:
/// - [Notifier] を継承し、Riverpod の Provider 経由で画面へ状態を公開する。
/// - [build] で Repository を取得し、初期状態として空の [CoListState] を返す。
/// - [fetchCoList] で企業一覧 API を呼び出し、結果に応じて [state] を更新する。
class CoListViewModel extends Notifier<CoListState> {
  /// 企業一覧 API へのアクセスを担当する Repository。
  ///
  /// [build] の中で [coRepoProvider] から取得する。
  /// ViewModel はこの Repository を通して企業一覧を取得する。
  late final CoRepo _repository;

  /// ViewModel の初期化処理。
  ///
  /// 処理の流れ:
  /// 1. [coRepoProvider] から [CoRepo] を取得し、[_repository] に保持する。
  /// 2. 画面の初期状態として、空の [CoListState] を返す。
  ///
  /// `ref.read` を使う理由:
  /// - Repository 自体の状態変化を監視する必要はなく、API 呼び出し用のインスタンスを取得できればよいため。
  @override
  CoListState build() {
    _repository = ref.read(coRepoProvider);
    return const CoListState();
  }

  /// 企業一覧を取得し、画面状態を更新する。
  ///
  /// 処理の流れ:
  /// 1. すでに読み込み中なら、二重リクエストを防ぐため何もせず終了する。
  /// 2. 読み込み開始として `isLoading` を true にし、前回のエラーをクリアする。
  /// 3. Repository の [CoRepo.fetchCoList] を呼び出して API から企業一覧を取得する。
  /// 4. API が成功した場合は、取得した企業一覧を [state.data] に入れて読み込みを終了する。
  /// 5. API は返ってきたが失敗扱いの場合は、レスポンスのメッセージまたは固定文言をエラーとして設定する。
  /// 6. 通信例外などが発生した場合も、固定文言をエラーとして設定して読み込みを終了する。
  ///
  /// 注意:
  /// - 例外の詳細はここでは画面へ直接出さず、ユーザー向けの固定文言にしている。
  /// - 詳細ログが必要な場合は、別途ログ出力の仕組みを追加する。
  Future<void> fetchCoList() async {
    // すでに API 呼び出し中の場合は、同じリクエストが重複して走らないように終了する。
    if (state.isLoading) {
      return;
    }

    // 読み込み状態を開始し、前回のエラー表示を消す。
    // データ自体はこの時点では維持されるため、再読み込み中も既存リストを表示し続けられる。
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Repository 経由で企業一覧 API を呼び出す。
      // API パスの組み立てや JSON 変換は Repository 側の責務。
      final response = await _repository.fetchCoList();

      // レスポンスが成功の場合、取得した企業一覧を状態へ反映して読み込みを終了する。
      if (response.isSuccess) {
        state = state.copyWith(isLoading: false, data: response.data);
        return;
      }

      // 通信自体は完了したが、API の結果が失敗扱いだった場合。
      // サーバーからメッセージが返っていればそれを使い、なければ画面表示用の固定文言を使う。
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? '顧客リストの取得に失敗しました',
      );
    } catch (e) {
      // Dio の通信例外や予期しないエラーが発生した場合。
      // 画面には内部エラー詳細を出さず、ユーザー向けの固定文言を設定する。
      state = state.copyWith(isLoading: false, errorMessage: '顧客リストの取得に失敗しました');
    }
  }
}

/// 企業一覧画面から [CoListViewModel] と [CoListState] を利用するための Provider。
///
/// 画面側ではこの Provider を監視することで、読み込み状態、エラー、企業一覧データを受け取れる。
/// また、Notifier を取得すれば [CoListViewModel.fetchCoList] を呼び出して企業一覧を再取得できる。
final coListViewModelProvider = NotifierProvider<CoListViewModel, CoListState>(
  CoListViewModel.new,
);
