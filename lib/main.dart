import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/customodolistcard/custom_todo_list_card.dart';
import 'package:todo_list/state/todostate.dart';
import 'package:todo_list/todobloc/todo_bloc.dart';
import 'package:todo_list/tododetail/todo_detail_screen.dart';

import 'events/todeevent.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TodoBloc()..add(FetchTodos()), // Dispatch FetchTodos at the beginning
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(FetchTodos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("ToDo List")),
        backgroundColor: Colors.red,
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            // Show a loading indicator while fetching todos
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoaded) {
            // If todos are loaded, display them in CustomTodoListCard
            return state.todoList.isNotEmpty
                ? CustomTodoListCard(todoList: state.todoList)
                : const Center(child: Text("No Todos available"));
          } else if (state is TodoError) {
            // Display an error message if something goes wrong
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text("No Todos available"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.black,
        onPressed: () {
          // Navigate to TodoDetailScreen when floating action button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailScreen(
                isEditMode: false,
                todoId: null,
                finalIsChecked: 0,
              ),
            ),
          ).then((_) {
            // Reload todos when returning from the detail screen
            context.read<TodoBloc>().add(FetchTodos());
          });
        },
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
