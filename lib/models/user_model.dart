class User {
  String? id;
  String username;
  String email;
  String passwordHash;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id']?.toString(),
      username: map['username'],
      email: map['email'],
      passwordHash: map['passwordHash'],
    );
  }
}
