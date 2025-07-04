import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_offline_first/core/constants/utils.dart';
import 'package:task_offline_first/features/auth/pages/cubit/auth_cubit.dart';
import 'package:task_offline_first/features/home/cubit/task_cubit.dart';
import 'package:task_offline_first/features/home/pages/add_new_task_page.dart';
import 'package:task_offline_first/features/home/widgets/date_selector.dart';
import 'package:task_offline_first/features/home/widgets/task_card.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const HomePage());
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    context.read<AddNewTaskCubit>().getAllTasks(token: user.user.token);
    Connectivity().onConnectivityChanged.listen((data) async {
      if (data.contains(ConnectivityResult.wifi) ||
          data.contains(ConnectivityResult.other)) {
        await context.read<AddNewTaskCubit>().syncTasks(user.user.token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('My Tasks')),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, AddNewTaskPage.route());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),

      body: BlocBuilder<AddNewTaskCubit, AddNewTaskState>(
        builder: (context, state) {
          if (state is AddNewTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AddNewTaskError) {
            return Center(child: Text(state.message));
          } else if (state is GetTaskSuccess) {
            final tasks =
                state.taskList
                    .where(
                      (elem) =>
                          DateFormat('d').format(elem.dueAt) ==
                              DateFormat('d').format(selectedDate) &&
                          DateFormat('M').format(elem.dueAt) ==
                              DateFormat('M').format(selectedDate) &&
                          DateFormat('y').format(elem.dueAt) ==
                              DateFormat('y').format(selectedDate),
                    )
                    .toList();

            // print('Number of tasks: ${tasks.length}');
            return Column(
              children: [
                // date selector
                DateSelector(
                  selectedDate: selectedDate,
                  ontap: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Row(
                        children: [
                          Expanded(
                            child: TaskCard(
                              color: task.color,
                              headerText: task.title,
                              descriptionText: task.description,
                            ),
                          ),
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: strengthenColor(task.color, 0.69),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              DateFormat.jm().format(task.dueAt),
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
