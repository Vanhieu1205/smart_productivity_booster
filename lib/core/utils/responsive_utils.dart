import 'package:flutter/material.dart';

/// Utility class cho responsive design
/// Cung cấp các hàm helper để kiểm tra kích thước màn hình
class ResponsiveUtils {
  /// Kiểm tra nếu màn hình là điện thoại nhỏ (< 360dp)
  static bool isVerySmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 360;
  }

  /// Kiểm tra nếu màn hình là tablet hoặc lớn hơn (>= 600dp)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  /// Kiểm tra nếu màn hình ở chế độ landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Lấy độ rộng của màn hình
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Lấy chiều cao của màn hình
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Tính padding ngang dựa trên kích thước màn hình
  static double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 8.0;
    if (width < 600) return 16.0;
    if (width < 900) return 24.0;
    return 32.0;
  }

  /// Tính padding dọc dựa trên kích thước màn hình
  static double verticalPadding(BuildContext context) {
    final height = screenHeight(context);
    if (height < 640) return 8.0;
    if (height < 840) return 12.0;
    return 16.0;
  }

  /// Tính font size cho tiêu đề dựa trên kích thước màn hình
  static double titleFontSize(BuildContext context) {
    if (isVerySmallPhone(context)) return 20.0;
    if (isTablet(context)) return 28.0;
    return 24.0;
  }

  /// Tính font size cho body text dựa trên kích thước màn hình
  static double bodyFontSize(BuildContext context) {
    if (isVerySmallPhone(context)) return 13.0;
    if (isTablet(context)) return 16.0;
    return 14.0;
  }

  /// Tính icon size dựa trên kích thước màn hình
  static double iconSize(BuildContext context) {
    if (isVerySmallPhone(context)) return 20.0;
    if (isTablet(context)) return 28.0;
    return 24.0;
  }

  /// Tính spacing (khoảng cách) dựa trên kích thước màn hình
  static double spacing(BuildContext context) {
    if (isVerySmallPhone(context)) return 6.0;
    if (isTablet(context)) return 16.0;
    return 12.0;
  }

  /// Tính card padding dựa trên kích thước màn hình
  static EdgeInsets cardPadding(BuildContext context) {
    if (isVerySmallPhone(context)) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  }

  /// Tính button padding dựa trên kích thước màn hình
  static EdgeInsets buttonPadding(BuildContext context) {
    if (isVerySmallPhone(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  /// Tính timer size dựa trên kích thước màn hình
  static double timerSize(BuildContext context) {
    final height = screenHeight(context);

    if (isVerySmallPhone(context)) {
      return screenWidth(context) * 0.55;
    }
    if (isLandscape(context)) {
      return height * 0.5;
    }
    if (isTablet(context)) {
      return screenWidth(context) * 0.35;
    }
    return screenWidth(context) * 0.65;
  }

  /// Tính progress ring size dựa trên kích thước màn hình
  static double progressRingSize(BuildContext context) {
    if (isVerySmallPhone(context)) return 80.0;
    if (isTablet(context)) return 130.0;
    return 110.0;
  }

  /// Tính aspect ratio cho grid quadrant dựa trên kích thước màn hình
  static double quadrantAspectRatio(BuildContext context) {
    final width = screenWidth(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isVerySmallPhone(context)) {
      return isLandscape ? 0.85 : 0.7;
    }
    if (isTablet(context)) {
      return isLandscape ? 1.0 : 0.9;
    }
    return isLandscape ? 0.95 : 0.75;
  }
}

/// Widget wrapper để tạo responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? customPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    final padding = customPadding ?? EdgeInsets.symmetric(
      horizontal: ResponsiveUtils.horizontalPadding(context),
      vertical: ResponsiveUtils.verticalPadding(context),
    );

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Widget wrapper để ẩn hiện nội dung dựa trên kích thước màn hình
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final Widget? hiddenOnPhone;
  final Widget? hiddenOnTablet;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.hiddenOnPhone,
    this.hiddenOnTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (hiddenOnPhone != null && ResponsiveUtils.isVerySmallPhone(context)) {
      return hiddenOnPhone!;
    }
    if (hiddenOnTablet != null && ResponsiveUtils.isTablet(context)) {
      return hiddenOnTablet!;
    }
    return child;
  }
}

/// Widget để hiển thị content với layout khác nhau trên phone vs tablet
class ResponsiveLayout extends StatelessWidget {
  final Widget phoneLayout;
  final Widget? tabletLayout;

  const ResponsiveLayout({
    super.key,
    required this.phoneLayout,
    this.tabletLayout,
  });

  @override
  Widget build(BuildContext context) {
    if (tabletLayout != null && ResponsiveUtils.isTablet(context)) {
      return tabletLayout!;
    }
    return phoneLayout;
  }
}
