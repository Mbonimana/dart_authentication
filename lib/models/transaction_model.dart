class TransactionModel {
  String id;
  String amount;
  String status;
  String deviceA;
  String? deviceB;
  String createdAt;
  String? paidAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.deviceA,
    this.deviceB,
    required this.createdAt,
    this.paidAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "_id": id,
      "amount": amount,
      "status": status,
      "deviceA": deviceA,
      "deviceB": deviceB,
      "createdAt": createdAt,
      "paidAt": paidAt,
    };
  }
}