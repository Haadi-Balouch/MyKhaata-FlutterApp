class TransactionItem {
  final int? id;
  final double amount;
  final String note;
  final String categoryName;
  final int categoryIconCode;
  final int categoryColorValue;
  final String accountName;
  final int accountIconCode;
  final int accountColorValue;
  final String date;
  final String time;
  final bool isExpense;
  final DateTime timestamp;

  TransactionItem({
    this.id,
    required this.amount,
    required this.note,
    required this.categoryName,
    required this.categoryIconCode,
    required this.categoryColorValue,
    required this.accountName,
    required this.accountIconCode,
    required this.accountColorValue,
    required this.date,
    required this.time,
    required this.isExpense,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'amount': amount,
      'note': note,
      'category_name': categoryName,
      'category_icon_code': categoryIconCode,
      'category_color_value': categoryColorValue,
      'account_name': accountName,
      'account_icon_code': accountIconCode,
      'account_color_value': accountColorValue,
      'date': date,
      'time': time,
      'is_expense': isExpense ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };

    // Only include id if it's not null
    if (id != null) {
      map['id'] = id as Object;
    }

    return map;
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      amount: map['amount'],
      note: map['note'] ?? '',
      categoryName: map['category_name'],
      categoryIconCode: map['category_icon_code'],
      categoryColorValue: map['category_color_value'],
      accountName: map['account_name'],
      accountIconCode: map['account_icon_code'],
      accountColorValue: map['account_color_value'],
      date: map['date'],
      time: map['time'],
      isExpense: map['is_expense'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}