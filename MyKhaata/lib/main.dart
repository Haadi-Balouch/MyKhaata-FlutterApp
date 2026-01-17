import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/app_database.dart';
import 'models/category_item.dart';
import 'models/account_item.dart';
import 'dao/category_dao.dart';
import 'dao/account_dao.dart';
import 'screens/home_page.dart';
import 'screens/passcode_screen.dart';
import 'utils/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.instance.database;

  final categoryDao = CategoryDAO();
  final accountDao = AccountDAO();

  if (await categoryDao.isEmpty()) {
    await _insertDefaultCategories(categoryDao);
  }

  if (await accountDao.isEmpty()) {
    await _insertDefaultAccounts(accountDao);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

Future<void> _insertDefaultCategories(CategoryDAO dao) async {
  final List<Map<String, dynamic>> expenseCategories = [
    {"name": "Baby", "icon": Icons.child_friendly, "color": Colors.grey.shade300},
    {"name": "Beauty", "icon": Icons.brush, "color": Colors.pink.shade200},
    {"name": "Bills", "icon": Icons.receipt_long, "color": Colors.blueGrey.shade200},
    {"name": "Car", "icon": Icons.directions_car, "color": Colors.purple.shade200},
    {"name": "Clothing", "icon": Icons.checkroom, "color": Colors.orange.shade300},
    {"name": "Education", "icon": Icons.school, "color": Colors.blue.shade200},
    {"name": "Electronics", "icon": Icons.devices_other, "color": Colors.teal.shade200},
    {"name": "Entertainment", "icon": Icons.movie_creation, "color": Colors.indigo.shade200},
    {"name": "Food", "icon": Icons.restaurant, "color": Colors.red.shade200},
    {"name": "Home", "icon": Icons.home, "color": Colors.pink.shade300},
    {"name": "Insurance", "icon": Icons.verified_user, "color": Colors.orange.shade400},
    {"name": "Health", "icon": Icons.health_and_safety, "color": Colors.red.shade300},
    {"name": "Shopping", "icon": Icons.shopping_cart, "color": Colors.blue.shade300},
    {"name": "Social", "icon": Icons.group, "color": Colors.green.shade200},
    {"name": "Sport", "icon": Icons.sports_tennis, "color": Colors.green.shade400},
    {"name": "Tax", "icon": Icons.money_off, "color": Colors.red.shade400},
    {"name": "Telephone", "icon": Icons.phone_android, "color": Colors.yellow.shade200},
    {"name": "Transport", "icon": Icons.directions_bus, "color": Colors.blue.shade300},
    {"name": "Others", "icon": Icons.question_mark_outlined, "color": Colors.grey.shade300},
  ];

  final List<Map<String, dynamic>> incomeCategories = [
    {"name": "Salary", "icon": Icons.work_outline, "color": Colors.green.shade300},
    {"name": "Business", "icon": Icons.storefront_outlined, "color": Colors.blue.shade300},
    {"name": "Freelance", "icon": Icons.laptop_mac, "color": Colors.purple.shade300},
    {"name": "Investments", "icon": Icons.trending_up, "color": Colors.orange.shade300},
    {"name": "Rent", "icon": Icons.house_siding_outlined, "color": Colors.brown.shade300},
    {"name": "Loan Received", "icon": Icons.attach_money_rounded, "color": Colors.teal.shade300},
    {"name": "Refunds", "icon": Icons.refresh_outlined, "color": Colors.cyan.shade300},
    {"name": "Bonus", "icon": Icons.card_giftcard, "color": Colors.deepOrange.shade300},
    {"name": "Gifts", "icon": Icons.redeem_outlined, "color": Colors.pink.shade200},
    {"name": "Savings Interest", "icon": Icons.savings_outlined, "color": Colors.green.shade200},
    {"name": "Rewards", "icon": Icons.stars_outlined, "color": Colors.yellow.shade300},
    {"name": "Pension", "icon": Icons.account_balance_wallet_outlined, "color": Colors.blueGrey.shade300},
    {"name": "Scholarship", "icon": Icons.school_outlined, "color": Colors.deepPurple.shade200},
    {"name": "Side Hustle", "icon": Icons.lightbulb_outline, "color": Colors.indigo.shade300},
    {"name": "Others", "icon": Icons.more_horiz, "color": Colors.grey.shade400},
  ];

  for (var map in expenseCategories) {
    await dao.insert(CategoryItem(
      name: map["name"] as String,
      iconCode: (map["icon"] as IconData).codePoint,
      colorValue: (map["color"] as Color).value,
      isExpense: true,
    ));
  }

  for (var map in incomeCategories) {
    await dao.insert(CategoryItem(
      name: map["name"] as String,
      iconCode: (map["icon"] as IconData).codePoint,
      colorValue: (map["color"] as Color).value,
      isExpense: false,
    ));
  }
}

Future<void> _insertDefaultAccounts(AccountDAO dao) async {
  final defaults = [
    AccountItem(
      name: "Cash",
      iconCode: Icons.money.codePoint,
      colorValue: Colors.green.shade300.value,
      balance: 0.0,
    ),
    AccountItem(
      name: "Bank",
      iconCode: Icons.account_balance.codePoint,
      colorValue: Colors.blue.shade300.value,
      balance: 0.0,
    ),
    AccountItem(
      name: "Easypaisa",
      iconCode: Icons.phone_iphone.codePoint,
      colorValue: Colors.purple.shade300.value,
      balance: 0.0,
    ),
  ];

  for (var item in defaults) {
    await dao.insert(item);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'MyKhaata',
          home: themeProvider.passcodeEnabled
              ? PasscodeScreen()
              : MyHomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}