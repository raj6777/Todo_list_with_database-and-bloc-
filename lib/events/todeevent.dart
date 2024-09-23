abstract class TodoEvent {}

class AddTodo extends TodoEvent {
  final String? title;
  final String? description;
  final String? date;
  final bool isChecked;


  AddTodo({this.title, this.description, this.date,this.isChecked = false});
}

class FetchTodos extends TodoEvent {}

class DeleteTodos extends TodoEvent {
  final int id;

  DeleteTodos(this.id);
}

class FetchTodoDetail extends TodoEvent {
  final int id;

  FetchTodoDetail(this.id);
}

class UpdateTodo extends TodoEvent {
  final int id;
  final String? title;
  final String? description;
  final String? date;
  final int isChecked;

  UpdateTodo({
    required this.id,
    this.title,
    this.description,
    this.date,
    required this.isChecked
  });
}

class ToggleTodoSelection extends TodoEvent {
  final int id;
  final bool isSelected;

  ToggleTodoSelection(this.id, this.isSelected);
}

