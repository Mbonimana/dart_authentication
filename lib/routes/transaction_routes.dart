import 'dart:convert';

import 'package:dart_mongo_backend/services/transaction_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class TransactionRoutes {
  Router get router {
    final router = Router();

    // CREATE
    router.post('/transaction/create', (Request req) async {
      try {
        final body = jsonDecode(await req.readAsString());

        final amount = body["amount"];
        final deviceA = body["device"];

        if (amount == null || deviceA == null) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "error": "amount and device are required",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final txn = await TransactionService.create(
          amount.toString(),
          deviceA.toString(),
        );

        return Response.ok(
          jsonEncode({
            "success": true,
            "data": txn,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response(
          500,
          body: jsonEncode({
            "success": false,
            "error": e.toString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // PAY
    router.post('/transaction/pay', (Request req) async {
      try {
        final body = jsonDecode(await req.readAsString());

        final txnId = body["txnId"];
        final deviceB = body["deviceB"];

        if (txnId == null || deviceB == null) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "error": "txnId and deviceB are required",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final txn = await TransactionService.pay(
          txnId.toString(),
          deviceB.toString(),
        );

        if (txn == null) {
          return Response(
            404,
            body: jsonEncode({
              "success": false,
              "error": "transaction not found",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({
            "success": true,
            "data": txn,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response(
          500,
          body: jsonEncode({
            "success": false,
            "error": e.toString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    router.get('/ping', (req) {
      print("PING HIT");
      return Response.ok("pong");
    });

    // GET
    router.get('/transaction/<id>', (Request req, String id) async {
      final txn = await TransactionService.get(id);
      return Response.ok(jsonEncode(txn));
    });

    return router;
  }
}
