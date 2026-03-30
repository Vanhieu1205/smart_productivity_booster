// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      quadrantIndex: fields[3] as int,
      createdAt: fields[4] as DateTime,
      isCompleted: fields[5] as bool,
      labelIndex: fields[6] as int?,
      dueDate: fields[7] as DateTime?,
      estimatedPomodoros: fields[8] as int,
      completedPomodoros: fields[9] as int,
      subTasks: (fields[10] as List).cast<SubTaskModel>(),
      tags: (fields[11] as List).cast<String>(),
      recurrenceRule: fields[12] as String?,
      notes: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.quadrantIndex)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.labelIndex)
      ..writeByte(7)
      ..write(obj.dueDate)
      ..writeByte(8)
      ..write(obj.estimatedPomodoros)
      ..writeByte(9)
      ..write(obj.completedPomodoros)
      ..writeByte(10)
      ..write(obj.subTasks)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.recurrenceRule)
      ..writeByte(13)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
