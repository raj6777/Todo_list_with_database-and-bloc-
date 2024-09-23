import 'package:flutter_bloc/flutter_bloc.dart';
import '../databasehelper/database_helper.dart';
import '../events/todeevent.dart';
import '../state/todostate.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  TodoBloc() : super(TodoInitial()) {
    on<AddTodo>(_onAddTodo);
    on<FetchTodos>(_onFetchTodos);
    on<DeleteTodos>(_onDeleteTodo);
    on<FetchTodoDetail>(_onFetchTodoDetail);
    on<UpdateTodo>(_onUpdateTodo);
    on<ToggleTodoSelection>(_onToggleTodoSelection); // New handler for checkbox selection
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      await _databaseHelper.addTodo(
        event.title ?? "",
        event.description ?? "",
        event.date ?? "",
        event.isChecked
      );
      emit(TodoAdded());
    } catch (e) {
      emit(TodoError('Failed to add todo'));
    }
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());

    try {
      final todos = await _databaseHelper.getTodos();
      emit(TodoLoaded(todoList: todos));
    } catch (e) {
      emit(TodoError('Failed to retrieve data'));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());

    try {
      await _databaseHelper.deleteTodo(event.id);
      add(FetchTodos()); // Refresh list after deletion
    } catch (e) {
      emit(TodoError('Failed to delete todo'));
    }
  }

  Future<void> _onFetchTodoDetail(FetchTodoDetail event, Emitter<TodoState> emit) async {
    emit(TodoLoading());

    try {
      final todoDetail = await _databaseHelper.getTodoById(event.id);
      emit(TodoDetailLoaded(todoDetail: todoDetail));
    } catch (e) {
      emit(TodoError('Failed to retrieve todo details'));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    emit(TodoLoading());

    try {
      await _databaseHelper.updateTodo(
        event.id,
        event.title ?? "",
        event.description ?? "",
        event.date ?? "",
        event.isChecked
      );
      add(FetchTodos()); // Refresh list after update
    } catch (e) {
      emit(TodoError('Failed to update todo'));
    }
  }

  Future<void> _onToggleTodoSelection(
      ToggleTodoSelection event,
      Emitter<TodoState> emit,
      ) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      final selectedTodos = Set<int>.from(currentState.selectedTodoIds);

      if (event.isSelected) {
        selectedTodos.add(event.id);
      } else {
        selectedTodos.remove(event.id);
      }
      emit(currentState.copyWith(selectedTodoIds: selectedTodos));
    }
  }
}
