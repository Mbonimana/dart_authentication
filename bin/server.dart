import 'dart:convert';

import 'package:dotenv/dotenv.dart'; // dotenv v4
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  // Create a DotEnv instance
  final dotenv = DotEnv()..load(); 

  final dbUri = dotenv['MONGO_URI']; 

  if (dbUri == null) {
    print('Error: MONGO_URI not found in .env file.');
    return;
  }

  // Connect to MongoDB
  final db = await Db.create(dbUri);
  await db.open();
  final collection = db.collection('items');

  final app = Router();

  // Add new item
  app.post('/add', (Request req) async {
    final payload = await req.readAsString();
    final data = jsonDecode(payload);

    await collection.insertOne(data);

    return Response.ok(
      jsonEncode({'status': 'success', 'data': data}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Get all items
  app.get('/items', (Request req) async {
    final items = await collection.find().toList();
    return Response.ok(
      jsonEncode(items),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Middleware + start server
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}
