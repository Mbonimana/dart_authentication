import 'dart:io';

import 'package:dart_mongo_backend/config/env_config.dart';
import 'package:dart_mongo_backend/db.dart';
import 'package:dart_mongo_backend/routes/transaction_routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future<void> main() async {
  try {
    // 1. Init ENV + DB
    EnvConfig.init();
    await DB.init();

    // 2. Routes
    final router = TransactionRoutes().router;

    // 3. Middleware pipeline
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(router);

    // 4. Port (cloud + local safe)
    final port =
        int.tryParse(Platform.environment['PORT'] ?? '') ??
        EnvConfig.port;

    // 5. Bind correctly (CRITICAL FIX)
    final server = await serve(
      handler,
      InternetAddress("0.0.0.0"), // keeps cloud compatibility
      port,
    );

    // 6. Detect usable IP (for LAN access)
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    String localIp = 'localhost';

    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (addr.address.startsWith('192.168') ||
            addr.address.startsWith('10.')) {
          localIp = addr.address;
        }
      }
    }

    // 7. Clean output
    print('\n🚀 Server running on:');
    print('   Local:   http://localhost:$port');
    print('   Network: http://$localIp:$port');
    print('\n🔌 WebSocket:');
    print('   ws://$localIp:$port/ws\n');
  } catch (e, stack) {
    print("❌ Server failed: $e");
    print(stack);
  }
}

//
// CORS (for mobile + web)
//
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

const Map<String, String> _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
};