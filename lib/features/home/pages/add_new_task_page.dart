import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_offline_first/features/auth/pages/cubit/auth_cubit.dart';
import 'package:task_offline_first/features/home/cubit/task_cubit.dart';
import 'package:task_offline_first/features/home/pages/home_page.dart';

class AddNewTaskPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const AddNewTaskPage());
  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Color selectedColor = const Color.fromRGBO(246, 224, 194, 1);
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void createNewTask() async {
    if (formKey.currentState!.validate()) {
      AuthLoggedIn user = context.read<AuthCubit>().state as AuthLoggedIn;
      await context.read<AddNewTaskCubit>().createNewTask(
        uid: user.user.id,
        title: titleController.text.trim(),
        description: descriptionController.text,
        color: selectedColor,
        dueAt: selectedDate,
        token: user.user.token,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(DateFormat("d-MM-y").format(selectedDate)),
            ),
            onTap: () async {
              final _selectedDate = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              setState(() {
                selectedDate = _selectedDate ?? selectedDate;
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<AddNewTaskCubit, AddNewTaskState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is AddNewTaskSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Task added successfully!")),
            );

            // final user = context.read<AuthCubit>().state as AuthLoggedIn;
            // context.read<AddNewTaskCubit>().getAllTasks(token: user.user.token);

            Navigator.pushAndRemoveUntil(
              context,
              HomePage.route(),
              (_) => false,
            );
          } else if (state is AddNewTaskError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AddNewTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                      controller: titleController,
                      decoration: const InputDecoration(hintText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                      maxLines: 4,
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ColorPicker(
                      heading: const Text('Select color'),
                      subheading: Text('Select a different shade'),
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      color: selectedColor,
                      pickersEnabled: const {ColorPickerType.wheel: true},
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        createNewTask();
                      },
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
