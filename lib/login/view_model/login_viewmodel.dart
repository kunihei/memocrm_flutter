import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/login/repo/login_repo.dart';
import 'package:memocrm/utils/api/api_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// - UI 層から呼ばれるログイン処理 / セッション復元 / ログアウトのロジックを持つ。
/// - 状態は LoginState（ApiState を継承）で管理し、イミュータブルな `copyWith` で更新する。
/// - 永続化には SharedPreferences を使用し、認証情報（最小限）を保存/復元する。
class LoginState extends ApiState {
  final bool isAuthenticated;
  final String? userName;
  final int? userCd;
  final String? accessToken;
  final DateTime? accessTokenExpiresAt;
  final String? refreshToken;
  final DateTime? refreshTokenExpiresAt;
  final String? tokenType;
  final bool isRestoring;

  const LoginState({
    super.isLoading = false,
    this.isAuthenticated = false,
    this.userName,
    this.userCd,
    this.accessToken,
    this.accessTokenExpiresAt,
    this.refreshToken,
    this.refreshTokenExpiresAt,
    this.tokenType,
    this.isRestoring = false,
    super.errorMessage,
  });

  @override
  LoginState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userName,
    int? userCd,
    String? accessToken,
    DateTime? accessTokenExpiresAt,
    String? refreshToken,
    DateTime? refreshTokenExpiresAt,
    String? tokenType,
    bool? isRestoring,
    String? errorMessage,
    bool clearError = false,
  }) {
    final baseState = super.copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      clearError: clearError,
    );
    return LoginState(
      isLoading: baseState.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      userCd: userCd ?? this.userCd,
      accessToken: accessToken ?? this.accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshTokenExpiresAt: refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
      tokenType: tokenType ?? this.tokenType,
      isRestoring: isRestoring ?? this.isRestoring,
      errorMessage: baseState.errorMessage,
    );
  }
}

class LoginViewModel extends Notifier<LoginState> {
  // リポジトリ（Dio を内包したもの）を後で注入する
  late final LoginRepo _loginRepo;

  // SharedPreferences に保存するキー名
  static const _prefIsAuthenticated = 'login_isAuthenticated';
  static const _prefUserName = 'login_userName';
  static const _prefUserCd = 'login_userCd';
  static const _prefAccessToken = 'login_accessToken';
  static const _prefAccessTokenExpiresAt = 'login_accessTokenExpiresAt';
  static const _prefRefreshToken = 'login_refreshToken';
  static const _prefRefreshTokenExpiresAt = 'login_refreshTokenExpiresAt';
  static const _prefTokenType = 'login_tokenType';

  // 既に復元処理が行われたかどうかを制御するフラグ
  bool _restored = false;

  @override
  LoginState build() {
    // Provider からリポジトリを読み取って保持
    _loginRepo = ref.read(loginRepositoryProvider);
    // 初期状態はローディング中にしておき、UI が復元処理をトリガーしやすくする
    return const LoginState(isLoading: true);
  }

  /// セッション復元
  /// - アプリ起動時に SharedPreferences から認証情報を読み取り、状態を復元する。
  /// - 同じ復元処理が複数回走らないよう _restored でガードしている。
  Future<void> restoreSession() async {
    // 既に復元済みなら何もしない（重複呼び出し防止）
    if (_restored) {
      return;
    }
    _restored = true;
    final prefs = await SharedPreferences.getInstance();

    // 永続化された認証フラグを確認。なければ未認証扱い。
    final isAuthenticated = prefs.getBool(_prefIsAuthenticated) ?? false;
    if (!isAuthenticated) {
      // 未認証の場合は復元完了フラグのみクリアして戻る
      state = state.copyWith(isRestoring: false);
      return;
    }

    // 認証している場合は保存されたユーザー情報を復元
    final userName = prefs.getString(_prefUserName);
    final userCd = prefs.getInt(_prefUserCd);
    final accessToken = prefs.getString(_prefAccessToken);
    final accessTokenExpiresAtString = prefs.getString(_prefAccessTokenExpiresAt);
    final refreshToken = prefs.getString(_prefRefreshToken);
    final refreshTokenExpiresAtString = prefs.getString(_prefRefreshTokenExpiresAt);
    final tokenType = prefs.getString(_prefTokenType);

    final accessTokenExpiresAt = accessTokenExpiresAtString != null
        ? DateTime.tryParse(accessTokenExpiresAtString)
        : null;
    final refreshTokenExpiresAt = refreshTokenExpiresAtString != null
        ? DateTime.tryParse(refreshTokenExpiresAtString)
        : null;

    state = state.copyWith(
      isAuthenticated: true,
      // null 合体を使って null 安全に値を取る（この例では userName をそのまま設定）
      userName: userName ?? userName,
      userCd: userCd,
      accessToken: accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshToken: refreshToken,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
      tokenType: tokenType,
      clearError: true,
      isRestoring: false,
    );
  }

  /// ログイン処理
  /// - 入力検証、API 呼び出し、状態更新、セッション永続化を行う。
  Future<void> login({
    required String userCd,
    required String password,
  }) async {
    // 既にローディング中なら二重送信を防ぐ
    if (state.isLoading) {
      return;
    }
    // ローディング開始、既存エラーはクリア
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // 入力が空の場合は早期リターン（エラーメッセージの表示は呼び出し側で制御）
      if (userCd.isEmpty || password.isEmpty) {
        // 本来はここでエラーメッセージを設定しても良いが、UI 側でバリデーションする設計のため
        // ここでは単にローディング状態を継続させないようにして戻る
        state = state.copyWith(
          isLoading: true,
          clearError: true,
        );
        return;
      }
      final requestCd = userCd;
      final requestPassword = password;
      final loginResponse = await _loginRepo.login(userCd: requestCd, password: requestPassword,);
      if (!loginResponse.isSuccess) {
        // API が成功ではない場合、サーバからのメッセージを優先して表示
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: loginResponse.message ?? 'IDまたはパスワードが違います',
        );
        return;
      }

      // 成功時の状態更新とセッション永続化
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userName: loginResponse.data?.name ?? '',
        userCd: loginResponse.data?.userCd ?? 0,
        clearError: true,
        isRestoring: false,
      );
      await _persistSession(
        isAuthenticated: true,
        userName: state.userName,
        userCd: state.userCd,
        accessToken: loginResponse.data?.accessToken,
        accessTokenExpiresAt: loginResponse.data?.accessTokenExpiresAt,
        refreshToken: loginResponse.data?.refreshToken,
        refreshTokenExpiresAt: loginResponse.data?.refreshTokenExpiresAt,
        tokenType: loginResponse.data?.tokenType,
      );

    } catch (e) {
      // 例外発生時は汎用エラーメッセージをセット
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'ログインに失敗しました'
      );
    }
  }

  /// ログアウト
  /// - ローディング中は操作をブロックし、状態を初期化して永続化データをクリアする
  void logout() {
    if (state.isLoading) {
      return;
    }
    state = const LoginState();
    _clearSession();
  }

  /// SharedPreferences の認証情報を削除
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefIsAuthenticated);
    await prefs.remove(_prefUserName);
    await prefs.remove(_prefUserCd);
    await prefs.remove(_prefAccessToken);
    await prefs.remove(_prefAccessTokenExpiresAt);
    await prefs.remove(_prefRefreshToken);
    await prefs.remove(_prefRefreshTokenExpiresAt);
    await prefs.remove(_prefTokenType);
  }

  /// SharedPreferences に最低限のセッション情報を保存
  Future<void> _persistSession({
    required bool isAuthenticated,
    String? userName,
    int? userCd,
    String? accessToken,
    DateTime? accessTokenExpiresAt,
    String? refreshToken,
    DateTime? refreshTokenExpiresAt,
    String? tokenType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIsAuthenticated, isAuthenticated);
    if (userName != null) {
      await prefs.setString(_prefUserName, userName);
    }
    if (userCd != null) {
      await prefs.setInt(_prefUserCd, userCd);
    }
    if (accessToken != null) {
      await prefs.setString(_prefAccessToken, accessToken);
    }
    if (accessTokenExpiresAt != null) {
      await prefs.setString(_prefAccessTokenExpiresAt, accessTokenExpiresAt.toIso8601String());
    }
    if (refreshToken != null) {
      await prefs.setString(_prefRefreshToken, refreshToken);
    }
    if (refreshTokenExpiresAt != null) {
      await prefs.setString(_prefRefreshTokenExpiresAt, refreshTokenExpiresAt.toIso8601String());
    }
    if (tokenType != null) {
      await prefs.setString(_prefTokenType, tokenType);
    }

  }

}
