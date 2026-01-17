import 'package:flutter/material.dart';
import '../models/category_item.dart';
import '../dao/category_dao.dart';
import '../utils/app_colors.dart';

Future<void> showAddCategoryDialog(BuildContext context, bool isExpense) {
  TextEditingController nameController = TextEditingController();

  List<Map<String, dynamic>> availableIcons = [
    {"icon": Icons.car_crash, "color": Colors.purple.shade200},
    {"icon": Icons.checkroom, "color": Colors.orange.shade300},
    {"icon": Icons.restaurant, "color": Colors.pink.shade200},
    {"icon": Icons.home, "color": Colors.pink.shade100},
    {"icon": Icons.shopping_cart, "color": Colors.blue.shade200},
    {"icon": Icons.sports_basketball, "color": Colors.green.shade200},
    {"icon": Icons.health_and_safety, "color": Colors.red.shade300},
    {"icon": Icons.movie, "color": Colors.deepPurple.shade200},
    {"icon": Icons.receipt_long, "color": Colors.blueGrey.shade300},
    {"icon": Icons.security, "color": Colors.orange.shade400},
  ];

  int selectedIconIndex = 0;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Color(0xFF5A5A52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add new category",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5E9A9),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => setState(() => isExpense = false),
                        child: Row(
                          children: [
                            Text(
                              "INCOME",
                              style: TextStyle(
                                fontSize: 16,
                                color: isExpense ? Colors.grey : Color(0xFFF5E9A9),
                              ),
                            ),
                            if (!isExpense)
                              Icon(Icons.check, color: Color(0xFFF5E9A9), size: 18),
                          ],
                        ),
                      ),
                      SizedBox(width: 25),
                      InkWell(
                        onTap: () => setState(() => isExpense = true),
                        child: Row(
                          children: [
                            Text(
                              "EXPENSE",
                              style: TextStyle(
                                fontSize: 16,
                                color: isExpense ? Color(0xFFF5E9A9) : Colors.grey,
                              ),
                            ),
                            if (isExpense)
                              Icon(Icons.check, color: Color(0xFFF5E9A9), size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFF5E9A9)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: nameController,
                      style: TextStyle(color: Color(0xFFF5E9A9)),
                      cursorColor: Color(0xFFF5E9A9),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Untitled",
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Icon",
                      style: TextStyle(fontSize: 16, color: Color(0xFFF5E9A9)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 170,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final item = availableIcons[index];
                        bool selected = selectedIconIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedIconIndex = index);
                          },
                          child: CircleAvatar(
                            radius: selected ? 32 : 30,
                            backgroundColor: item["color"],
                            child: Icon(
                              item["icon"],
                              size: 26,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 120,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFF5E9A9)),
                          ),
                          child: Center(
                            child: Text(
                              "CANCEL",
                              style: TextStyle(
                                color: Color(0xFFF5E9A9),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;

                          final selected = availableIcons[selectedIconIndex];
                          final newCat = CategoryItem(
                            name: name,
                            iconCode: (selected['icon'] as IconData).codePoint,
                            colorValue: (selected['color'] as Color).value,
                            isExpense: isExpense,
                          );

                          final dao = CategoryDAO();
                          await dao.insert(newCat);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 120,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFF5E9A9)),
                          ),
                          child: Center(
                            child: Text(
                              "SAVE",
                              style: TextStyle(
                                color: Color(0xFFF5E9A9),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}