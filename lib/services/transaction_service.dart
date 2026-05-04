import 'package:dart_mongo_backend/db.dart';
import 'package:dart_mongo_backend/real_time/socket_manager.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TransactionService {
  // CREATE TRANSACTION (DEVICE A)
  static Future<Map> create(String amount, String deviceA) async {
    final id = ObjectId();

    final txn = {
      "_id": id,
      "amount": amount,
      "status": "pending",
      "deviceA": deviceA,
      "deviceB": null,
      "createdAt": DateTime.now().toIso8601String(),
    };

    await DB.transactions.insert(txn);

    // Convert ObjectId for API friendliness (optional but recommended)
    final responseTxn = Map<String, dynamic>.from(txn);
    responseTxn["_id"] = id.toHexString();

    SocketManager.broadcast({
      "type": "TRANSACTION_CREATED",
      "data": responseTxn,
    });

    return responseTxn;
  }

  // PAY TRANSACTION (DEVICE B)
  static Future<Map?> pay(String txnId, String deviceB) async {
    final oid = ObjectId.parse(txnId);

    await DB.transactions.update(
      where.eq("_id", oid),
      modify
          .set("status", "paid")
          .set("deviceB", deviceB)
          .set("paidAt", DateTime.now().toIso8601String()),
    );

    final updated = await DB.transactions.findOne({"_id": oid});

    if (updated == null) {
      return null;
    }

    final responseTxn = Map<String, dynamic>.from(updated);
    responseTxn["_id"] = (responseTxn["_id"] as ObjectId).toHexString();

    SocketManager.broadcast({
      "type": "TRANSACTION_PAID",
      "data": responseTxn,
    });

    return responseTxn;
  }

  // GET ONE
  static Future<Map?> get(String id) async {
    final txn = await DB.transactions.findOne({"_id": ObjectId.parse(id)});

    if (txn == null) {
      return null;
    }

    final responseTxn = Map<String, dynamic>.from(txn);
    responseTxn["_id"] = (responseTxn["_id"] as ObjectId).toHexString();
    return responseTxn;
  }
}
