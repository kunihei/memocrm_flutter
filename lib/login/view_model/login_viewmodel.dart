import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memocrm/login/repo/login_repo.dart';
import 'package:memocrm/utils/api/api_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginState extends ApiState {
  final bool isAuthenticated;
  final String? userName;
  final int? userCd;
  final bool isRestoring;

  const LoginState({
    super.isLoading = false,
    this.isAuthenticated = false,
    this.userName,
    this.userCd,
    this.isRestoring = false,
    super.errorMessage,
  });

  @override
  LoginState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userName,
    int? userCd,
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
      isRestoring: isRestoring ?? this.isRestoring,
      errorMessage: baseState.errorMessage,
    );
  }
}

class LoginViewModel extends Notifier<LoginState> {
  late final LoginRepo _loginRepo;
  static const _prefIsAuthenticated = 'login_isAuthenticated';
  static const _prefUserName = 'login_userName';
  static const _prefUserCd = 'login_userCd';
  bool _restored = false;

  @override
  LoginState build() {
    _loginRepo = ref.read(loginRepositoryProvider);
    return const LoginState(isLoading: true);
  }

  Future<void> restoreSession() async {
    if (_restored) {
      return;
    }
    _restored = true;
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool(_prefIsAuthenticated) ?? false;
    if (!isAuthenticated) {
      state = state.copyWith(isRestoring: false);
      return;
    }

    final userName = prefs.getString(_prefUserName);
    final userCd = prefs.getInt(_prefUserCd);
    state = state.copyWith(
      isAuthenticated: true,
      userName: userName ?? userName,
      userCd: userCd,
      clearError: true,
      isRestoring: false,
    );
  }

  Future<void> login({
    required String userCd,
    required String password,
  }) async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (userCd.isEmpty || password.isEmpty) {
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
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: loginResponse.message ?? 'IDまたはパスワードが違います',
        );
        return;
      }

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
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'ログインに失敗しました'
      );
    }
  }

  void logout() {
    if (state.isLoading) {
      return;
    }
    state = const LoginState();
    _clearSession();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefIsAuthenticated);
    await prefs.remove(_prefUserName);
    await prefs.remove(_prefUserCd);
  }

  Future<void> _persistSession({
    required bool isAuthenticated,
    String? userName,
    int? userCd,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIsAuthenticated, isAuthenticated);
    if (userName != null) {
      await prefs.setString(_prefUserName, userName);
    }
    if (userCd != null) {
      await prefs.setInt(_prefUserCd, userCd);
    }
  }

}
