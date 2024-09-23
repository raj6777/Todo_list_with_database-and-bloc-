import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../events/todeevent.dart';
import '../state/todostate.dart';
import '../todobloc/todo_bloc.dart';
import '../tododetail/todo_detail_screen.dart';

class CustomTodoListCard extends StatelessWidget {
  final List<Map<dynamic, dynamic>>? todoList;

  CustomTodoListCard({Key? key, this.todoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoaded) {
            return ListView.builder(
              itemCount: state.todoList.length,
              itemBuilder: (context, index) {
                final todo = state.todoList[index];
                final id = todo['id'];
                final title = todo['title'] ?? 'No Title';
                final description = todo['description'] ?? 'No Description';
                final date = todo['date'] ?? 'No Date';
                final checked = todo['isChecked'] ?? 0;
                bool isChecked = checked == 1;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(description),
                              Text(date),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TodoDetailScreen(
                                  isEditMode: true,
                                  todoId: id,
                                  finalIsChecked: isChecked ? 1 : 0,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<TodoBloc>().add(DeleteTodos(id));
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                        ),
                        Checkbox(
                          activeColor: Colors.green,
                          onChanged: (bool? newValue) {
                            if (newValue != null) {
                              context.read<TodoBloc>().add(
                                    ToggleTodoSelection(id, newValue),
                                  );
                              context.read<TodoBloc>().add(UpdateTodo(
                                  id: id!,
                                  title: title,
                                  description: description,
                                  date: date,
                                  isChecked: isChecked ? 0 : 1));
                            }
                          },
                          value: isChecked,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Failed to load todos'));
          }
        },
      ),
    );
  }
}
