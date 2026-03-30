import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/eisenhower_matrix/presentation/bloc/eisenhower_bloc.dart';
import '../../../../features/eisenhower_matrix/presentation/bloc/eisenhower_event.dart';
import '../../../../features/eisenhower_matrix/presentation/bloc/eisenhower_state.dart';
import '../../../../features/eisenhower_matrix/domain/entities/quadrant_type.dart';
import '../../../theme/app_theme.dart';

/// Placeholder cho màn hình Ma trận Eisenhower
/// Sẽ được thay bằng EisenhowerMatrixPage hoàn chỉnh
class EisenhowerPlaceholder extends StatelessWidget {
  const EisenhowerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma trận Eisenhower'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<EisenhowerBloc>().add(const LoadTasks()),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: BlocBuilder<EisenhowerBloc, EisenhowerState>(
        builder: (context, state) {
          if (state is EisenhowerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EisenhowerLoaded) {
            return _buildMatrix(context, state);
          }
          if (state is EisenhowerError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const Center(child: Text('Nhấn nút làm mới để tải tasks'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm task'),
      ),
    );
  }

  Widget _buildMatrix(BuildContext context, EisenhowerLoaded state) {
    final quadrantLabels = ['Làm Ngay', 'Lên Kế Hoạch', 'Ủy Thác', 'Loại Bỏ'];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 4,
      itemBuilder: (context, i) {
        final tasks = (state.tasksByQuadrant[QuadrantType.values[i]] ?? []);
        return Card(
          color: AppColors.quadrantLightColor(i),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: AppColors.quadrantColor(i),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quadrantLabels[i],
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.quadrantColor(i),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${tasks.length}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.quadrantColor(i),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có task',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (_, j) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '• ${tasks[j].title}',
                              style: AppTextStyles.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    // TODO: Implement full add task dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng thêm task sẽ được cập nhật sớm!')),
    );
  }
}
