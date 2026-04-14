import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../settings/data/services/backup_service.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isRestoring = false;
  bool _isImporting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
            LoginRequested(
              _emailController.text.trim(),
              _passwordController.text,
            ),
          );
    }
  }

  Future<void> _onRestoreFromBackup() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isRestoring = true);

    try {
      final backupService = sl<BackupService>();
      final userData = await backupService.restoreDataAndGetUser();

      if (!mounted) return;

      if (userData != null) {
        // Có tài khoản trong backup - tự động đăng nhập
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

          // Đăng nhập tự động
          context.read<AuthBloc>().add(LoginRequested(email, password));
        }
      } else {
        // Không có tài khoản trong backup
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

  /// Nhập dữ liệu từ file backup (chỉ nhập dữ liệu, không đăng nhập)
  Future<void> _onImportFromBackup() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isImporting = true);

    try {
      final backupService = sl<BackupService>();
      final success = await backupService.importData();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
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
        setState(() => _isImporting = false);
      }
    }
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.cannotBeEmpty;
    }
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.cannotBeEmpty;
    }
    if (value.length < 6) {
      return l10n.passwordMinLength;
    }
    return null;
  }

  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Khi đăng nhập thành công: hiển thị snackbar trước rồi mới chuyển trang
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Đăng nhập thành công!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Delay để snackbar hiển thị trước khi chuyển trang
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRouter.main);
              }
            });
          } else if (state is AuthError) {
            // Nếu có lỗi, hiển thị SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon Logo cho Đăng nhập
                    Icon(
                      Icons.account_circle_rounded,
                      size: 100,
                      color: colorScheme
                          .primary, // Sẽ lấy deepPurple nếu cấu hình theme đúng
                    ),
                    const SizedBox(height: 32),

                    // Tiêu đề
                    Text(
                      l10n.loginTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Theo dõi và tối ưu hiệu suất của bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // TextFormField Email
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.loginEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) => _validateEmail(v, l10n),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                    ),
                    const SizedBox(height: 16),

                    // TextFormField Mật khẩu với Obscure Toggle
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l10n.loginPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) => _validatePassword(v, l10n),
                      onFieldSubmitted: (_) => _onLogin(),
                    ),
                    const SizedBox(height: 32),

                    // Nút Đăng nhập với Loading Indicator
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: (state is AuthLoading || _isRestoring || _isImporting) ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state is AuthLoading || _isRestoring || _isImporting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  l10n.loginButton,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Nút Khôi phục từ Backup
                    OutlinedButton.icon(
                      onPressed: _isRestoring ? null : _onRestoreFromBackup,
                      icon: _isRestoring
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore),
                      label: Text(
                        l10n.restoreFromBackup,
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Nút Nhập dữ liệu từ Backup
                    OutlinedButton.icon(
                      onPressed: (_isRestoring || _isImporting) ? null : _onImportFromBackup,
                      icon: _isImporting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(
                        l10n.importData,
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nút chuyển sang Đăng ký
                    TextButton(
                      onPressed: () {
                        // Chuyển sang màn hình Đăng ký
                        Navigator.pushNamed(context, AppRouter.register);
                      },
                      child: Text(
                        l10n.loginNoAccount,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
