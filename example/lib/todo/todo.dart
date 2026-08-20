class Todo {
  const Todo({required this.id, required this.title, this.completed = false});

  final int id;
  final String title;
  final bool completed;

  @override
  bool operator ==(Object other) =>
      other is Todo &&
      other.id == id &&
      other.title == title &&
      other.completed == completed;

  @override
  int get hashCode => Object.hash(id, title, completed);

  @override
  String toString() => 'Todo(id: $id, title: $title, completed: $completed)';
}

class TodoNotFound implements Exception {
  const TodoNotFound(this.id);

  final int id;

  @override
  String toString() => 'TodoNotFound($id)';
}
