import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../settings/data/services/backup_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

enum AuthMode { login, register, forgotPassword, verifyAnswer, resetPassword }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthMode _currentMode = AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isImporting = false;
  bool _isRestoring = false;

  String? _currentEmail;
  String? _currentQuestion;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _answerFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();

  int _selectedQuestionIndex = 0;
  static const List<String> _securityQuestions = [
    'Tên thú cưng đầu tiên của bạn là gì?',
    'Thành phố bạn sinh ra là gì?',
    'Tên trường tiểu học của bạn là gì?',
    'Món ăn yêu thích nhất của bạn là gì?',
    'Người anh hùng tuổi thơ của bạn là ai?',
  ];

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(_onFocusChange);
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
    _confirmPasswordFocusNode.addListener(_onFocusChange);
    _answerFocusNode.addListener(_onFocusChange);
    _newPasswordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // Force rebuild to update focus state if needed
  }

  @override
  void dispose() {
    _usernameFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _confirmPasswordFocusNode.removeListener(_onFocusChange);
    _answerFocusNode.removeListener(_onFocusChange);
    _newPasswordFocusNode.removeListener(_onFocusChange);

    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _answerController.dispose();
    _newPasswordController.dispose();

    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _answerFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _currentMode = mode;
      _obscurePassword = true;
      _obscureConfirmPassword = true;
    });
    _clearFields();
    _clearFocus();
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _usernameController.clear();
    _answerController.clear();
    _newPasswordController.clear();
  }

  void _clearFocus() {
    FocusScope.of(context).unfocus();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    _clearFocus();
    context.read<AuthBloc>().add(
          LoginRequested(
              _emailController.text.trim(), _passwordController.text),
        );
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    _clearFocus();
    context.read<AuthBloc>().add(
          RegisterRequested(
            _usernameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
            _securityQuestions[_selectedQuestionIndex],
            _answerController.text.trim(),
          ),
        );
  }

  void _handleCheckSecurityQuestion() {
    if (!_formKey.currentState!.validate()) return;
    _clearFocus();
    _currentEmail = _emailController.text.trim();
    context
        .read<AuthBloc>()
        .add(CheckSecurityQuestionRequested(_currentEmail!));
  }

  void _handleVerifyAnswer() {
    if (!_formKey.currentState!.validate()) return;
    _clearFocus();
    context.read<AuthBloc>().add(
          VerifySecurityAnswerRequested(
              _currentEmail!, _answerController.text.trim()),
        );
  }

  void _handleResetPassword() {
    if (!_formKey.currentState!.validate()) return;
    _clearFocus();
    context.read<AuthBloc>().add(
          ResetPasswordRequested(_currentEmail!, _newPasswordController.text),
        );
  }

  /// Khôi phục dữ liệu từ file backup + đăng nhập tự động
  Future<void> _onRestoreFromBackup() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isRestoring = true);

    try {
      final backupService = sl<BackupService>();
      final userData = await backupService.restoreDataAndGetUser();

      if (!mounted) return;

      if (userData != null) {
        final email = userData['email'] as String?;
        final password = userData['password'] as String?;

        if (email != null && password != null) {
          _emailController.text = email;
          _passwordController.text = password;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.backupRestoredLogin),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          context.read<AuthBloc>().add(LoginRequested(email, password));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backupNoAccount),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.importError}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Hiển thị snackbar trước rồi mới chuyển trang
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.success}! Đăng nhập thành công.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, AppRouter.main);
            }
          });
        } else if (state is AuthRegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.success}! Vui lòng đăng nhập.'),
              backgroundColor: Colors.green,
            ),
          );
          _switchMode(AuthMode.login);
        } else if (state is AuthSecurityQuestionLoaded) {
          setState(() {
            _currentEmail = state.email;
            _currentQuestion = state.question;
            _currentMode = AuthMode.verifyAnswer;
          });
          _answerController.clear();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _answerFocusNode.requestFocus();
          });
        } else if (state is AuthSecurityAnswerVerified) {
          setState(() {
            _currentMode = AuthMode.resetPassword;
          });
          _newPasswordController.clear();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _newPasswordFocusNode.requestFocus();
          });
        } else if (state is AuthPasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.success}! Đặt lại mật khẩu thành công.'),
              backgroundColor: Colors.green,
            ),
          );
          _switchMode(AuthMode.login);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: AppLogo(size: 100, showBackground: true),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.welcomeSpb,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildCurrentContent(l10n, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentContent(AppLocalizations l10n, ThemeData theme) {
    switch (_currentMode) {
      case AuthMode.forgotPassword:
        return _buildForgotPasswordContent(l10n, theme);
      case AuthMode.verifyAnswer:
        return _buildVerifyAnswerContent(l10n, theme);
      case AuthMode.resetPassword:
        return _buildResetPasswordContent(l10n, theme);
      default:
        return _buildLoginRegisterContent(l10n, theme);
    }
  }

  Widget _buildLoginRegisterContent(AppLocalizations l10n, ThemeData theme) {
    final isLogin = _currentMode == AuthMode.login;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isLogin ? l10n.loginTitle : l10n.registerTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Username field (Register only)
            if (!isLogin) ...[
              TextFormField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                decoration: InputDecoration(
                  labelText: l10n.registerUsername,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.nameCannotBeEmpty;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
              ),
              const SizedBox(height: 16),
            ],

            // Email field
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: InputDecoration(
                labelText: l10n.loginEmail,
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isLogin ? l10n.cannotBeEmpty : l10n.emailCannotBeEmpty;
                }
                if (!value.contains('@')) {
                  return l10n.invalidEmail;
                }
                return null;
              },
              onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                labelText: l10n.loginPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction:
                  isLogin ? TextInputAction.done : TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isLogin
                      ? l10n.cannotBeEmpty
                      : l10n.passwordCannotBeEmpty;
                }
                if (!isLogin && value.length < 6) {
                  return l10n.passwordMinLength;
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (isLogin) {
                  _handleLogin();
                } else {
                  _confirmPasswordFocusNode.requestFocus();
                }
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password field (Register only)
            if (!isLogin) ...[
              TextFormField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                decoration: InputDecoration(
                  labelText: l10n.registerConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.cannotBeEmpty;
                  }
                  if (value != _passwordController.text) {
                    return l10n.passwordMismatch;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _answerFocusNode.requestFocus(),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.securityQuestion,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedQuestionIndex,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.help_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                selectedItemBuilder: (context) {
                  return List.generate(_securityQuestions.length, (index) {
                    return Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _securityQuestions[index],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  });
                },
                items: List.generate(_securityQuestions.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(
                      _securityQuestions[index],
                      style: const TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
                onChanged: (value) {
                  setState(() => _selectedQuestionIndex = value ?? 0);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                focusNode: _answerFocusNode,
                decoration: InputDecoration(
                  labelText: l10n.securityAnswer,
                  prefixIcon: const Icon(Icons.quiz_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.cannotBeEmpty;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: 24),
            ],

            // Forgot Password link (Login only)
            if (isLogin) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _switchMode(AuthMode.forgotPassword),
                  child: Text(l10n.loginForgotPassword),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Nút nhập file dữ liệu (Login only)
            if (isLogin) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_isRestoring || _isImporting)
                          ? null
                          : _onRestoreFromBackup,
                      icon: _isRestoring
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore, size: 18),
                      label: Text(l10n.restoreFromBackup,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Submit button
            FilledButton(
              onPressed:
                  isLoading ? null : (isLogin ? _handleLogin : _handleRegister),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLogin ? l10n.loginButton : l10n.registerButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Switch mode link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? l10n.loginNoAccount : l10n.registerHasAccount,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => _switchMode(
                            isLogin ? AuthMode.register : AuthMode.login,
                          ),
                  child: Text(isLogin ? l10n.registerButton : l10n.loginButton),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

// Forgot Password Content dùng để nhập email và gửi link đặt lại mật khẩu
  Widget _buildForgotPasswordContent(AppLocalizations l10n, ThemeData theme) {
    final emailFocusNode = FocusNode();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => _switchMode(AuthMode.login),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.forgotPasswordTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.forgotPasswordDesc,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              focusNode: emailFocusNode,
              decoration: InputDecoration(
                labelText: l10n.forgotPasswordEmail,
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.cannotBeEmpty;
                }
                if (!value.contains('@')) {
                  return l10n.invalidEmail;
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleCheckSecurityQuestion(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading ? null : _handleCheckSecurityQuestion,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.forgotPasswordButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _switchMode(AuthMode.login),
              child: Text(l10n.forgotPasswordBack),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerifyAnswerContent(AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => _switchMode(AuthMode.login),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.verifySecurityQuestion,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentQuestion ?? '',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _answerController,
              focusNode: _answerFocusNode,
              decoration: InputDecoration(
                labelText: l10n.securityAnswer,
                prefixIcon: const Icon(Icons.quiz_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.cannotBeEmpty;
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleVerifyAnswer(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading ? null : _handleVerifyAnswer,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.verifyButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _switchMode(AuthMode.login),
              child: Text(l10n.forgotPasswordBack),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResetPasswordContent(AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => _switchMode(AuthMode.login),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.resetPasswordTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.resetPasswordDesc,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _newPasswordController,
              focusNode: _newPasswordFocusNode,
              decoration: InputDecoration(
                labelText: l10n.loginPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.cannotBeEmpty;
                }
                if (value.length < 6) {
                  return l10n.passwordMinLength;
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleResetPassword(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading ? null : _handleResetPassword,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.resetPasswordButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _switchMode(AuthMode.login),
              child: Text(l10n.forgotPasswordBack),
            ),
          ],
        );
      },
    );
  }
}
