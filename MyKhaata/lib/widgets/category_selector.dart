import 'package:flutter/material.dart';
import '../models/category_item.dart';
import '../dao/category_dao.dart';
import '../utils/app_colors.dart';

class CategorySelector extends StatelessWidget {
  final bool isExpense;
  final dao = CategoryDAO();

  CategorySelector({required this.isExpense});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: BoxDecoration(
        color: AppColors.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: FutureBuilder<List<CategoryItem>>(
        future: dao.getAll(isExpense),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: AppColors.yellowT));
          }

          final list = snapshot.data!;

          return Column(
            children: [
              Text("Select Category", style: TextStyle(color: AppColors.yellowT, fontSize: 22)),
              SizedBox(height: 20),
              Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final item = list[i];
                      return GestureDetector(
                        onTap: () => Navigator.pop(context, item),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: item.color,
                              child: Icon(item.icon, color: Colors.black, size: 30),
                            ),
                            SizedBox(height: 5),
                            Text(
                              item.name,
                              style: TextStyle(color: AppColors.yellowT, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ),
            ],
          );
        },
      ),
    );
  }
}
