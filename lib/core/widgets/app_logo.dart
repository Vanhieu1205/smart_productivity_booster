import 'package:flutter/material.dart';

/// Widget hiển thị logo/icon của ứng dụng
/// Có thể tái sử dụng ở nhiều nơi: AppBar, AuthPage, Splash,...
/// [showBackground]: chỉ thêm đổ bóng nhẹ cho màn hình lớn, không dùng nền trắng
class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/icons/app_icon_remove_bg.png',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.task_alt,
          size: size * (showBackground ? 0.8 : 1),
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );

    if (showBackground) {
      // Logo lớn (auth): không nền trắng — chỉ đổ bóng nhẹ quanh ảnh PNG
      return SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(size * 0.06),
            child: image,
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(size * 0.08),
        child: image,
      ),
    );
  }
}
