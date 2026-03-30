import 'package:flutter/material.dart';

// ============================================================
// SKELETON BOX WIDGET
// ============================================================
// Skeleton loading animation cho UI.
// AnimationController lặp vô hạn (reverse) với độ mờ thay đổi 0.06 ↔ 0.18.

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.radius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    // AnimationController với duration 1000ms, lặp reverse vô hạn
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Animation độ mờ từ 0.06 đến 0.18 với Curves.easeInOut
    _anim = Tween<double>(begin: 0.06, end: 0.18).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(_anim.value),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

// ============================================================
// TASK CARD SKELETON
// ============================================================
// Skeleton cho một TaskCard: tiêu đề + mô tả + khoảng cách.

class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SkeletonBox full width, chiều cao 14
        const SkeletonBox(height: 14),
        const SizedBox(height: 8),
        // SkeletonBox width 100, chiều cao 11 (mô tả ngắn)
        const SkeletonBox(width: 100, height: 11),
      ],
    );
  }
}

// ============================================================
// QUADRANT SKELETON
// ============================================================
// Skeleton cho một Quadrant: chứa 3 TaskCardSkeleton.

class QuadrantSkeleton extends StatelessWidget {
  const QuadrantSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: TaskCardSkeleton(),
        ),
      ),
    );
  }
}
