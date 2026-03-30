import 'package:equatable/equatable.dart';

class SubTaskEntity extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  SubTaskEntity toggleCompletion() => copyWith(isCompleted: !isCompleted);

  @override
  List<Object?> get props => [id, title, isCompleted];
}
