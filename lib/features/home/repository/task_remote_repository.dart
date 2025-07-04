import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_offline_first/core/constants/constants.dart';
import 'package:task_offline_first/core/constants/utils.dart';
import 'package:task_offline_first/features/home/repository/task_local_repository.dart';
import 'package:task_offline_first/models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final taskLocalRepository = TaskLocalRepository();

  Future<Object> createTask({
    required String title,
    required String description,
    required String hexColor,
    required DateTime dueAt,
    required String token,
    required String uid,
  }) async {
    try {
      final result = await http
          .post(
            Uri.parse("${Constants.backendUri}/task"),
            headers: {'Content-Type': 'application/json', 'auth-token': token},
            body: jsonEncode({
              "title": title,
              "description": description,
              "hexColor": hexColor,
              "dueAt": dueAt.toIso8601String(),
            }),
          )
          .timeout(
            const Duration(milliseconds: 500),
            onTimeout: () {
              print('TaskRemoteRepository: createTask request timed out');
              throw Exception('Network timeout');
            },
          );

      if (result.statusCode != 201) {
        throw jsonDecode(result.body)['taskCreateError'];
      }

      return TaskModel.fromJson(result.body);
    } catch (e) {
      try {
        final taskModel = TaskModel(
          id: const Uuid().v4(),
          uid: uid,
          title: title,
          description: description,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueAt: dueAt,
          color: hexToRgb(hexColor),
          isSynced: 0,
        );
        await taskLocalRepository.insertTask(taskModel);
        return taskModel;
      } catch (e) {
        rethrow;
      }
      throw Exception('Failed to create task');
    }
  }

  Future<List<TaskModel>> getTask({required String token}) async {
    try {
      print('TaskRemoteRepository: Fetching tasks from remote');
      final result = await http
          .get(
            Uri.parse("${Constants.backendUri}/task"),
            headers: {'Content-Type': 'application/json', 'auth-token': token},
          )
          .timeout(
            const Duration(seconds: 1),
            onTimeout: () {
              print('TaskRemoteRepository: getTask request timed out');
              throw Exception('Network timeout');
            },
          );

      if (result.statusCode != 200) {
        throw jsonDecode(result.body)['error'];
      }

      final listOfTasks = jsonDecode(result.body);
      final List<TaskModel> taskList = [];

      for (var task in listOfTasks) {
        taskList.add(TaskModel.fromMap(task));
      }

      await taskLocalRepository.insertTasks(taskList);

      print(
        'TaskRemoteRepository: Remote fetch succeeded, tasks: \\${taskList.length}',
      );
      return taskList;
    } catch (e) {
      print('TaskRemoteRepository: Exception caught: $e');
      rethrow;
    }
  }

  Future<Object> syncTask({
    required List<TaskModel> tasks,
    required String token,
  }) async {
    try {
      final taskListInMap = [];
      for(final q in tasks) taskListInMap.add(q.toMap());
      final result = await http.post(
        Uri.parse("${Constants.backendUri}/tasks/sync"),
        headers: {'Content-Type': 'application/json', 'auth-token': token},
        body: jsonEncode(taskListInMap),
      );

      if (result.statusCode != 201) {
        throw jsonDecode(result.body)['error'];
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
