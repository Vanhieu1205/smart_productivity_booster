import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.updateUserUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateUserRequested>(_onUpdateUserRequested);
    on<CheckSecurityQuestionRequested>(_onCheckSecurityQuestion);
    on<VerifySecurityAnswerRequested>(_onVerifySecurityAnswer);
    on<ResetPasswordRequested>(_onResetPassword);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await checkAuthStatusUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Tài khoản hoặc mật khẩu không đúng'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(
        event.username,
        event.email,
        event.password,
        event.securityQuestion,
        event.securityAnswer,
      );
      if (user != null) {
        emit(AuthRegisterSuccess());
      } else {
        emit(const AuthError(message: 'Đăng ký thất bại'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserRequested(UpdateUserRequested event, Emitter<AuthState> emit) async {
    try {
      final updatedUser = await updateUserUseCase(
        newUsername: event.newUsername,
        newAvatarPath: event.newAvatarPath,
      );
      if (updatedUser != null) {
        emit(AuthAuthenticated(user: updatedUser));
      }
    } catch (e) {
      // Giữ nguyên AuthAuthenticated; lỗi hiển thị tại Profile nếu cần (timeout nút Lưu).
    }
  }

  Future<void> _onCheckSecurityQuestion(
    CheckSecurityQuestionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final question = await authRepository.getSecurityQuestion(event.email);
      if (question != null) {
        emit(AuthSecurityQuestionLoaded(email: event.email, question: question));
      } else {
        emit(const AuthError(message: 'Tài khoản không tồn tại.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifySecurityAnswer(
    VerifySecurityAnswerRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isValid = await authRepository.verifySecurityAnswer(event.email, event.answer);
      if (isValid) {
        emit(AuthSecurityAnswerVerified(email: event.email));
      } else {
        emit(const AuthError(message: 'Câu trả lời không chính xác.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.resetPassword(event.email, event.newPassword);
      emit(AuthPasswordResetSuccess());
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
