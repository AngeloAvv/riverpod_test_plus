class User {
  const User({required this.id, required this.name});

  final int id;
  final String name;

  User copyWith({String? name}) => User(id: id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      other is User && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'User(id: $id, name: $name)';
}

class UserNotFound implements Exception {
  const UserNotFound(this.id);

  final int id;

  @override
  String toString() => 'UserNotFound($id)';
}
