import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_offline_first/core/constants/utils.dart';
import 'package:task_offline_first/features/home/repository/task_local_repository.dart';
import 'package:task_offline_first/features/home/repository/task_remote_repository.dart';
import 'package:task_offline_first/models/task_model.dart';

part 'task_state.dart';

class AddNewTaskCubit extends Cubit<AddNewTaskState> {
  AddNewTaskCubit() : super(AddNewTaskInitial());
  final taskRemoteRepository = TaskRemoteRepository();
  final taskLocalRepository = TaskLocalRepository();

  Future<void> createNewTask({
    required String title,
    required String description,
    required Color color,
    required DateTime dueAt,
    required String token,
    required String uid,
  }) async {
    try {
      emit(AddNewTaskLoading());
      final taskModel =
          await taskRemoteRepository.createTask(
                uid: uid,
                title: title,
                description: description,
                hexColor: rgbToHex(color),
                dueAt: dueAt,
                token: token,
              )
              as TaskModel;

      await taskLocalRepository.insertTask(taskModel);

      emit(AddNewTaskSuccess(taskModel));
    } catch (e) {
      emit(AddNewTaskError(e.toString()));
    }
  }

  Future<void> getAllTasks({required String token}) async {
    try {
      emit(AddNewTaskLoading());
      final tasks = await taskRemoteRepository.getTask(token: token);
      emit(GetTaskSuccess(tasks));
    } catch (e) {
      // Try to load from local storage if remote fetch fails
      try {
        final localTasks = await taskLocalRepository.getTasks();

        if (localTasks.isNotEmpty) {
          emit(GetTaskSuccess(localTasks));
        } else {
          emit(AddNewTaskError('No tasks available offline.'));
        }
      } catch (localError) {
        emit(AddNewTaskError('Failed to load tasks: \\n$e\\n$localError'));
      }
    }
  }

  Future<void> syncTasks(String token) async {
    //get all unsyced tasks from our sqlite db
    final unsyncedTasks = await taskLocalRepository.getUnsyncedTasks();
    // send to our backend to add unsynced tasks
    if(unsyncedTasks.isEmpty) return;

    final isSynced = await taskRemoteRepository.syncTask(
      tasks: unsyncedTasks,
      token: token,
    ) as bool? ;
    // change the tasks status to synced to 0 to 1
    if (isSynced!=null && isSynced) {
      for (final task in unsyncedTasks) {
        await taskLocalRepository.updateSyncedTasks(task.id, 1);
      }
    }
  }
}
