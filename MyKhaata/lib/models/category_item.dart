import 'package:flutter/material.dart';

class CategoryItem {
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isExpense;

  CategoryItem({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.isExpense,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'icon_code': iconCode,
      'color_value': colorValue,
      'is_expense': isExpense ? 1 : 0,
    };

    // Only include id if it's not null
    if (id != null) {
      map['id'] = id as Object;
    }

    return map;
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int,
      colorValue: map['color_value'] as int,
      isExpense: map['is_expense'] == 1,
    );
  }
}