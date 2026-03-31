import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/streak_service.dart';
import '../../data/services/backup_service.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// SETTINGS PAGE
// ============================================================
// Trang quản lý Cấu Hình và Thông tin Cá nhân của SV.
// Tương tác trực tiếp bằng BlocBuilder và gởi lệnh State.

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      // Bọc ListView thay vì SingleChildScrollView cho dễ build ListTile
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // Trạng thái đang tải lần đầu
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Lỗi hiển thị fallback rỗng (không thể Load JSON, vv)
          if (state is! SettingsLoaded) {
            return Center(child: Text(l10n.cannotLoadSettings));
          }

          final isDarkMode = state.isDarkMode;
          final languageCode = state.languageCode;
          final bool soundEnabled = state.isSoundEnabled;
          final int dailyGoal = state.dailyPomodoroGoal;

          // Đọc trạng thái AuthBloc bằng context.watch để tự động cập nhật nếu Auth thay đổi
          final authState = context.watch<AuthBloc>().state;
          UserEntity? currentUser;
          if (authState is AuthAuthenticated) {
            currentUser = authState.user;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // ===== 0. THÔNG TIN TÀI KHOẢN =====
              if (currentUser != null) ...[
                ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      currentUser.avatarInitials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(currentUser.username,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(currentUser.email),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.profile);
                  },
                ),
                const Divider(height: 32),
              ],

              // ===== 1. MỤC CẤU HÌNH GIAO DIỆN (THEMES) =====
              _buildSectionHeader(context, l10n.settings),
              SwitchListTile(
                title: Text(l10n.darkMode,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text(''),
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: isDarkMode ? Colors.purple : Colors.orange,
                ),
                value: isDarkMode,
                onChanged: (value) {
                  // Truyền event thay đổi xuống Bloc để update Hive & State
                  context.read<SettingsBloc>().add(ToggleDarkMode(value));
                },
              ),

              // Bật/tắt âm thanh thông báo Pomodoro
              SwitchListTile(
                title: Text(
                  l10n.notificationSound,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.playSoundOnComplete),
                secondary: Icon(
                  soundEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: soundEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                value: soundEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(ToggleSoundEnabled(value));
                },
              ),

              const Divider(height: 32),

              // ===== 1.5. MỤC TIÊU POMODORO HÀNG NGÀY =====
              _buildSectionHeader(context, l10n.pomodoroGoal),
              ListTile(
                leading: Icon(
                  Icons.flag_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  l10n.dailyGoal,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('$dailyGoal ${l10n.pomodoroPerDay}'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('1',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Slider(
                        value: dailyGoal.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '$dailyGoal',
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                ChangeDailyPomodoroGoal(value.round()),
                              );
                        },
                      ),
                    ),
                    const Text('20',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              const Divider(height: 32),

              // ===== 1.5. THỐNG KÊ STREAK =====
              _buildSectionHeader(context, l10n.streak),
              // Lấy streak hiện tại và kỷ lục từ StreakService
              ListTile(
                leading: const Icon(Icons.local_fire_department,
                    color: Colors.orange),
                title: Text(
                  l10n.currentStreak,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Text(
                  '${sl<StreakService>().getCurrentStreak()} ${l10n.daysShort}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: Text(
                  l10n.streakRecord,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Text(
                  '${sl<StreakService>().getLongestStreak()} ${l10n.daysShort}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber,
                  ),
                ),
              ),

              const Divider(height: 32),

              // ===== 2. MỤC CẤU HÌNH NGÔN NGỮ =====
              _buildSectionHeader(context, l10n.language),
              RadioListTile<String>(
                title: Text(l10n.vietnamese),
                secondary: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
                value: 'vi',
                groupValue: languageCode,
                onChanged: (code) {
                  if (code != null) {
                    context.read<SettingsBloc>().add(ChangeLanguage(code));
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.english),
                secondary: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                value: 'en',
                groupValue: languageCode,
                onChanged: (code) {
                  if (code != null) {
                    context.read<SettingsBloc>().add(ChangeLanguage(code));
                  }
                },
              ),

              const Divider(height: 32),

              // ===== 3. VỀ ỨNG DỤNG (ABOUT / CREDITS) =====
              _buildSectionHeader(context, l10n.about),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.appName),
                subtitle: Text('${l10n.appVersion}: 1.0.0 (Beta)'),
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(l10n.developedBy),
                subtitle: Text(
                    '${l10n.developerName}\n${l10n.studentId}: 3120222037\n${l10n.graduationProject}'),
                isThreeLine:
                    true, // Hỗ trợ text dòng dài mà không bị tràn khung
              ),

              const Divider(height: 32),

              // ===== 3.5. THÀNH TỰU (ACHIEVEMENTS) =====
              _buildSectionHeader(context, l10n.achievements),
              ListTile(
                leading: Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber.shade600,
                ),
                title: Text(
                  l10n.viewAchievements,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.checkAchievements),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.achievements);
                },
              ),

              const Divider(height: 32),

              // ===== 4. DỮ LIỆU & SAO LƯU =====
              _buildSectionHeader(context, l10n.dataBackup),
              ExpansionTile(
                leading: Icon(
                  Icons.backup_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  l10n.backupRestore,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                children: [
                  // Nút Xuất dữ liệu
                  ListTile(
                    leading: const Icon(Icons.upload_rounded),
                    title: Text(l10n.exportData),
                    subtitle: Text(l10n.shareBackupFile),
                    onTap: () => _exportData(context),
                  ),
                  // Nút Nhập dữ liệu
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l10n.importData),
                    subtitle: Text(l10n.restoreFromBackup),
                    onTap: () => _showImportConfirmDialog(context),
                  ),
                ],
              ),

              const Divider(height: 32),

              // ===== 5. TÀI KHOẢN =====
              _buildSectionHeader(context, l10n.settings),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  _showLogoutDialog(context, l10n);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog xác nhận Đăng xuất
  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext); // Đóng dialog

              // Gọi event đăng xuất
              context.read<AuthBloc>().add(LogoutRequested());

              // Điều hướng về LoginPage và xóa toàn bộ lịch sử (stack) đằng trước
              // Giải thích: Navigator.pushNamedAndRemoveUntil(..., (route) => false)
              // giúp đẩy màn hình Đăng nhập (auth) lên và xóa (remove) tất cả các màn hình cũ.
              // Ngăn người dùng không bị "vô tình lọt lại" vào ứng dụng khi bấm nút (Back) ở điện thoại.
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.auth, (route) => false);
            },
            child:
                Text(l10n.logout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BACKUP & RESTORE
  // ────────────────────────────────────────────────────────────────────────────

  /// Xuất dữ liệu ra file JSON và chia sẻ
  Future<void> _exportData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final backupService = sl<BackupService>();
      await backupService.shareBackup();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.exportError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Dialog xác nhận trước khi nhập dữ liệu
  void _showImportConfirmDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmImportData),
        content: Text(l10n.importWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(dialogContext);
              _importData(context);
            },
            child: Text(l10n.continueText,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Nhập dữ liệu từ file backup
  Future<void> _importData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final backupService = sl<BackupService>();
      final success = await backupService.importData();

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.importSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Nếu người dùng hủy chọn file thì không hiển thị gì
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.importError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Cấu trúc Text làm Header chia section
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
