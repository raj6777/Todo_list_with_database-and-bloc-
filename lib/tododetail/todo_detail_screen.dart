import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Ensure you have flutter_bloc imported
import '../events/todeevent.dart';
import '../state/todostate.dart';
import '../todobloc/todo_bloc.dart'; // Import your states

class TodoDetailScreen extends StatefulWidget {
  final bool isEditMode;
  final int? todoId;
  final int finalIsChecked;

  TodoDetailScreen({super.key, required this.isEditMode, this.todoId,required this.finalIsChecked});

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode dateFocusNode = FocusNode();

  @override
  void initState() {
    if (widget.isEditMode && widget.todoId != null) {
      context.read<TodoBloc>().add(FetchTodoDetail(widget.todoId!));
    }
    super.initState();
  }

  Future<void> _pickDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        dateController.text = '${selectedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("ToDo Details")),
        backgroundColor: Colors.red,
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Todo added successfully')),
            );
            Navigator.pop(context); // Navigate back after adding the todo
          } else if (state is TodoDetailLoaded && widget.isEditMode) {
            final todo = state.todoDetail;
            titleController.text = todo['title'] ?? '';
            descriptionController.text = todo['description'] ?? '';
            dateController.text = todo['date'] ?? '';
          } else if (state is TodoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _form,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: titleController,
                    keyboardType: TextInputType.text,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                    ],
                    validator: (value)  {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                    },
                    decoration: const InputDecoration(
                        labelText: 'Title', hintText: 'Enter Your Title'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: descriptionController,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                    ],
                    decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter Your Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: dateController,
                    focusNode: dateFocusNode,
                    onTap: () {
                      _pickDate();
                    },
                    decoration: const InputDecoration(
                        labelText: 'Date', hintText: 'Enter Your Date'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 40),
                  if (!widget.isEditMode) ...[
                    ElevatedButton(
                      onPressed: () {
                        if (_form.currentState!.validate()) {
                          context.read<TodoBloc>().add(AddTodo(
                                title: titleController.text,
                                description: descriptionController.text,
                                date: dateController.text,
                              ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.8, 50),
                          backgroundColor: Colors.red),
                      child: const Text(
                        "Add",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ],
                  if (widget.isEditMode) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_form.currentState!.validate()) {
                              context.read<TodoBloc>().add(UpdateTodo(
                                    id: widget.todoId!,
                                    title: titleController.text,
                                    description: descriptionController.text,
                                    date: dateController.text,
                                    isChecked: widget.finalIsChecked
                                  ));
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.3, 35),
                              backgroundColor: Colors.red),
                          child: const Text("Update",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the screen
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.3, 35),
                              backgroundColor: Colors.red),
                          child: const Text("Cancel",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15)),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
