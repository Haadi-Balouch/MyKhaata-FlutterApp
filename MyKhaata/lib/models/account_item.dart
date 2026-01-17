import 'package:flutter/material.dart';

class AccountItem {
  final int? id;
  final String name;
  final double balance;
  final int iconCode;
  final int colorValue;

  AccountItem({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.balance = 0.0,
  });

  // Getters for easy access
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  // Convert to Map for database insertion
  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'icon_code': iconCode,
      'color_value': colorValue,
      'balance': balance,
    };

    // Only include id if it's not null
    if (id != null) {
      map['id'] = id as Object;
    }

    return map;
  }

  // Create AccountItem from Map
  factory AccountItem.fromMap(Map<String, dynamic> map) {
    return AccountItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int,
      colorValue: map['color_value'] as int,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // CopyWith method for easy updates
  AccountItem copyWith({
    int? id,
    String? name,
    int? iconCode,
    int? colorValue,
    double? balance,
  }) {
    return AccountItem(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      balance: balance ?? this.balance,
    );
  }

  @override
  String toString() {
    return 'AccountItem(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountItem &&
        other.id == id &&
        other.name == name &&
        other.iconCode == iconCode &&
        other.colorValue == colorValue;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    iconCode.hashCode ^
    colorValue.hashCode;
  }
}