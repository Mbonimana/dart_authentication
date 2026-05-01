import 'dart:io';

import 'package:dart_mongo_backend/config/env_config.dart';
import 'package:dart_mongo_backend/db.dart';
import 'package:dart_mongo_backend/routes/transaction_routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future<void> main() async {
  try {
    EnvConfig.init();
    await DB.init();

    final router = TransactionRoutes().router;

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(router);

    // IMPORTANT: cloud-ready port
    final port = int.parse(Platform.environment['PORT'] ?? '8080');

    final server = await serve(
      handler,
      InternetAddress.anyIPv4,
      port,
    );

    print("🚀 Server running on:");
    print("   http://${server.address.address}:$port");
    print("🔌 WebSocket:");
    print("   ws://${server.address.address}:$port/ws");
  } catch (e, stack) {
    print("❌ Server failed: $e");
    print(stack);
  }
}

Middleware _corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders);
    };
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
};