abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoAdded extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Map<dynamic, dynamic>> todoList;
  final Set<int> selectedTodoIds; // Track selected todos

  TodoLoaded({
    required this.todoList,
    this.selectedTodoIds = const {}, // Default empty set for selected todos
  });

  // Copy method for updating state
  TodoLoaded copyWith({
    List<Map<dynamic, dynamic>>? todoList,
    Set<int>? selectedTodoIds,
  }) {
    return TodoLoaded(
      todoList: todoList ?? this.todoList,
      selectedTodoIds: selectedTodoIds ?? this.selectedTodoIds,
    );
  }
}

class TodoDetailLoaded extends TodoState {
  final Map<String, dynamic> todoDetail;

  TodoDetailLoaded({required this.todoDetail});
}

class DeleteTodo extends TodoState {
  final int id;

  DeleteTodo(this.id);
}

class TodoError extends TodoState {
  final String message;

  TodoError(this.message);
}

class TodoUpdated extends TodoState {
  final int id;

  TodoUpdated(this.id);
}
