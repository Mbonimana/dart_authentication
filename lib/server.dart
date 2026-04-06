import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_mongo_backend/models/user_model.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

Handler createHandler(Db db) {
  final usersCollection = db.collection('users');
  final app = Router();

  app.post('/register', (Request req) async {
    try {
      final payload = await req.readAsString();
      final data = jsonDecode(payload);

      final username = data['username'];
      final email = data['email'];
      final password = data['password'];

      if (username == null || email == null || password == null) {
        return Response(400,
            body: jsonEncode({'error': 'Missing required fields'}),
            headers: {'Content-Type': 'application/json'});
      }

      final existingUser = await usersCollection.findOne(
        where.eq('username', username).or(where.eq('email', email)),
      );

      if (existingUser != null) {
        return Response(409,
            body: jsonEncode({'error': 'Username or email already exists'}),
            headers: {'Content-Type': 'application/json'});
      }

      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      final newUser = User(
        username: username,
        email: email,
        passwordHash: hashedPassword,
      );

      await usersCollection.insertOne(newUser.toMap());

      return Response(201,
          body: jsonEncode({'status': 'User registered successfully'}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response(500,
          body: jsonEncode({'error': 'Server error'}),
          headers: {'Content-Type': 'application/json'});
    }
  });

  return const Pipeline().addMiddleware(logRequests()).addHandler(app);
}

void main() async {
  final dotenv = DotEnv()..load();
  final dbUri = dotenv['MONGO_URI'];

  if (dbUri == null) {
    print('Error: MONGO_URI not found in .env file.');
    return;
  }

  final db = await Db.create(dbUri);
  await db.open();

  final handler = createHandler(db);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('Server listening on port ${server.port}');
}
