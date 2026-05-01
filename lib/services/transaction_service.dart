import 'package:dart_mongo_backend/db.dart';
import 'package:dart_mongo_backend/real_time/socket_manager.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TransactionService {
  // CREATE TRANSACTION (DEVICE A)
  static Future<Map> create(String amount, String deviceA) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final txn = {
      "_id": id,
      "amount": amount,
      "status": "pending",
      "deviceA": deviceA,
      "deviceB": null,
      "createdAt": DateTime.now().toIso8601String(),
    };

    await DB.transactions.insert(txn);

    SocketManager.broadcast({
      "type": "TRANSACTION_CREATED",
      "data": txn,
    });

    return txn;
  }

  // PAY TRANSACTION (DEVICE B)
  static Future<Map?> pay(String txnId, String deviceB) async {
    await DB.transactions.update(
      where.eq("_id", txnId),
      modify
          .set("status", "paid")
          .set("deviceB", deviceB)
          .set("paidAt", DateTime.now().toIso8601String()),
    );

    final updated = await DB.transactions.findOne({"_id": txnId});

    SocketManager.broadcast({
      "type": "TRANSACTION_PAID",
      "data": updated,
    });

    return updated;
  }

  // GET ONE
  static Future<Map?> get(String id) async {
    return await DB.transactions.findOne({"_id": id});
  }
}
