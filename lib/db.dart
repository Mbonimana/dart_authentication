import 'package:dart_mongo_backend/config/env_config.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DB {
  static late Db db;
  static late DbCollection transactions;

  static Future<void> init() async {
    // Load env only once
    EnvConfig.init();

    final uri = EnvConfig.mongoUri;

    if (uri.isEmpty) {
      throw Exception("MONGO_URI not found in .env");
    }

    db = await Db.create(uri);

    try {
      await db.open();
      print(" MongoDB connected successfully");
    } catch (e) {
      throw Exception(" Failed to connect MongoDB: $e");
    }

    // Collection (auto-created)
    transactions = db.collection("transactions");

    print("📦 Database: ${db.databaseName}");
  }

  static Future<void> close() async {
    await db.close();
    print("🔌 MongoDB connection closed");
  }
}
