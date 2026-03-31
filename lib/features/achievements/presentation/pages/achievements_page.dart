import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/achievement_service.dart';
import '../../domain/achievement.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// ACHIEVEMENTS PAGE – Presentation Layer
// ============================================================
// Trang hiển thị danh sách tất cả achievements với trạng thái unlock.

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final achievementService = sl<AchievementService>();
    final achievements = achievementService.getStatus();

    // Tách achievements đã unlock và chưa unlock
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievementsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thống kê tổng quan
            _buildProgressHeader(context, unlocked.length, achievements.length, l10n),

            // GridView 2 cột hiển thị achievements
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final isSmall = width < 360;
                  final bottomPad = MediaQuery.of(context).padding.bottom;
                  final aspect = isSmall ? 0.78 : 0.85;

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPad),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: isSmall ? 10 : 12,
                      crossAxisSpacing: isSmall ? 10 : 12,
                      childAspectRatio: aspect,
                    ),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = index < unlocked.length
                          ? unlocked[index]
                          : locked[index - unlocked.length];
                      return _AchievementCard(achievement: achievement);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header hiển thị tiến độ
  Widget _buildProgressHeader(BuildContext context, int unlocked, int total, AppLocalizations l10n) {
    final progress = total > 0 ? unlocked / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber.shade700,
                size: 28,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$unlocked / $total ${l10n.totalAchievements}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.amber.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Card hiển thị một Achievement
// ──────────────────────────────────────────────────────────────

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked
            ? achievement.color.withOpacity(0.15)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? achievement.color.withOpacity(0.4)
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement.color.withOpacity(0.2)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                size: 48,
                color: isUnlocked
                    ? achievement.color
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),

            // Title - Tự động thu nhỏ nếu quá dài
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? achievement.color
                      : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Description - Tự động thu nhỏ nếu quá dài
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                achievement.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isUnlocked
                      ? Colors.grey.shade700
                      : Colors.grey.shade500,
                ),
              ),
            ),

            // Ngày unlock (nếu có)
            if (isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                _formatDate(achievement.unlockedAt!),
                style: TextStyle(
                  fontSize: 10,
                  color: achievement.color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Định dạng ngày
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
