import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/transaction_service.dart';

class TransactionRoutes {
  Router get router {
    final router = Router();

    // CREATE
    router.post('/create', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      final txn = await TransactionService.create(
        body["amount"],
        body["deviceA"],
      );

      return Response.ok(jsonEncode(txn));
    });

    // PAY
    router.post('/pay', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      final txn = await TransactionService.pay(
        body["txnId"],
        body["deviceB"],
      );

      return Response.ok(jsonEncode(txn));
    });

    // GET
    router.get('/transaction/<id>', (Request req, String id) async {
      final txn = await TransactionService.get(id);
      return Response.ok(jsonEncode(txn));
    });

    return router;
  }
}