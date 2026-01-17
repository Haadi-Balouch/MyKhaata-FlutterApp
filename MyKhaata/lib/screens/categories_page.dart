import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/category_item.dart';
import '../dao/category_dao.dart';
import '../widgets/add_category_dialog.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final dao = CategoryDAO();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: FutureBuilder<List<CategoryItem>>(
        future: _loadCategories(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: AppColors.yellowT));
          }

          final income = snapshot.data!.where((c) => !c.isExpense).toList();
          final expense = snapshot.data!.where((c) => c.isExpense).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Income Categories",
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.yellowT,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.yellowT.withOpacity(0.3), thickness: 1),
                  SizedBox(height: 10),
                  ...income.map((item) => categoryRow(item)),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Expense Categories",
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.yellowT,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.yellowT.withOpacity(0.3), thickness: 1),
                  SizedBox(height: 10),
                  ...expense.map((item) => categoryRow(item)),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await showAddCategoryDialog(context, true);
                        setState(() {});
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppColors.yellowT),
                        ),
                      ),
                      child: Text(
                        'Add new Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.yellowT,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<CategoryItem>> _loadCategories() async {
    final income = await dao.getAll(false);
    final expense = await dao.getAll(true);
    return [...income, ...expense];
  }

  Future<void> _deleteCategory(CategoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blackBG,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Delete Category',
          style: TextStyle(
            color: AppColors.yellowT,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?\n\nThis action cannot be undone.',
          style: TextStyle(color: AppColors.yellowT.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.yellowT,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final dao = CategoryDAO();
        dao.delete(item.id!);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} deleted successfully'),
            backgroundColor: AppColors.blackBG,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting category: $e'),
            backgroundColor: Colors.red.shade900,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _editCategory(CategoryItem item) async {
    await showEditCategoryDialog(context, item);
    setState(() {});
  }

  Widget categoryRow(CategoryItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: item.color,
            child: Icon(item.icon, color: Colors.black),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(fontSize: 18, color: AppColors.yellowT),
            ),
          ),
          PopupMenuButton(
            color: AppColors.blackBG,
            icon: Icon(Icons.more_vert, color: AppColors.yellowT),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) {
              if (value == "edit") {
                _editCategory(item);
              } else if (value == "delete") {
                _deleteCategory(item);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: "edit",
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.yellowT, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Edit",
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red.shade300, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Edit Category Dialog
Future<void> showEditCategoryDialog(BuildContext context, CategoryItem category) {
  TextEditingController nameController = TextEditingController(text: category.name);
  bool isExpense = category.isExpense;

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
    {"icon": Icons.school, "color": Colors.blue.shade200},
    {"icon": Icons.flight, "color": Colors.cyan.shade200},
    {"icon": Icons.pets, "color": Colors.brown.shade200},
    {"icon": Icons.restaurant_menu, "color": Colors.orange.shade200},
    {"icon": Icons.local_cafe, "color": Colors.brown.shade300},
  ];

  // Find the current icon in the list, or default to first
  int selectedIconIndex = 0;
  for (int i = 0; i < availableIcons.length; i++) {
    if ((availableIcons[i]['icon'] as IconData).codePoint == category.iconCode &&
        (availableIcons[i]['color'] as Color).value == category.colorValue) {
      selectedIconIndex = i;
      break;
    }
  }

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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Category",
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
                        Text(
                          isExpense ? "EXPENSE" : "INCOME",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFF5E9A9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFFF5E9A9),
                          size: 20,
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
                          hintText: "Category name",
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
                      height: 250,
                      child: GridView.builder(
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
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(
                                  color: Color(0xFFF5E9A9),
                                  width: 3,
                                )
                                    : null,
                              ),
                              child: CircleAvatar(
                                radius: selected ? 30 : 28,
                                backgroundColor: item["color"],
                                child: Icon(
                                  item["icon"],
                                  size: 26,
                                  color: Colors.black,
                                ),
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
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a category name'),
                                  backgroundColor: Colors.red.shade900,
                                ),
                              );
                              return;
                            }

                            final selected = availableIcons[selectedIconIndex];
                            final updatedCat = CategoryItem(
                              id: category.id,
                              name: name,
                              iconCode: (selected['icon'] as IconData).codePoint,
                              colorValue: (selected['color'] as Color).value,
                              isExpense: isExpense,
                            );

                            final dao = CategoryDAO();
                            await dao.update(updatedCat);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Category updated successfully'),
                                backgroundColor: AppColors.blackBG,
                                duration: Duration(seconds: 2),
                              ),
                            );
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
                                "UPDATE",
                                style: TextStyle(
                                  color: Color(0xFFF5E9A9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
            ),
          );
        },
      );
    },
  );
}