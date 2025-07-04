part of 'task_cubit.dart';

sealed class AddNewTaskState {
  const AddNewTaskState();
}

final class AddNewTaskInitial extends AddNewTaskState {}

final class AddNewTaskLoading extends AddNewTaskState {}

final class AddNewTaskError extends AddNewTaskState {
  final String message;
  const AddNewTaskError(this.message);
}

final class AddNewTaskSuccess extends AddNewTaskState {
  final TaskModel taskModel;
  const AddNewTaskSuccess(this.taskModel);
}

final class GetTaskSuccess extends AddNewTaskState {
  final List<TaskModel> taskList;
  const GetTaskSuccess(this.taskList);
}