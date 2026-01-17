class BudgetItem {
  final int? id;
  final String categoryName;
  final double limit;
  final int month;
  final int year;

  BudgetItem({
    this.id,
    required this.categoryName,
    required this.limit,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'category_name': categoryName,
      'limit_amount': limit,
      'month': month,
      'year': year,
    };

    // Only include id if it's not null
    if (id != null) {
      map['id'] = id as Object;
    }

    return map;
  }

  factory BudgetItem.fromMap(Map<String, dynamic> map) {
    return BudgetItem(
      id: map['id'],
      categoryName: map['category_name'],
      limit: map['limit_amount'],
      month: map['month'],
      year: map['year'],
    );
  }
}