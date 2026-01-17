import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dao/transaction_dao.dart';
import '../dao/category_dao.dart';
import '../dao/account_dao.dart';
import '../dao/budget_dao.dart';
import '../models/category_item.dart';
import '../models/account_item.dart';
import '../utils/app_colors.dart';

class DeleteResetPage extends StatelessWidget {
  // Function to insert default categories
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

  // Function to insert default accounts
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

  Future<void> _deleteRecords(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Delete Records',
          style: TextStyle(color: AppColors.yellowT, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will delete all transactions and budgets but keep your accounts and categories.\n\nNote: Account balances will be reset to 0.\n\nThis action cannot be undone!',
          style: TextStyle(color: AppColors.yellowT.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.yellowT, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red.shade300, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete all transactions
        await TransactionDAO().deleteAll();

        // Delete all budgets
        await BudgetDAO().deleteAll();

        // Reset all account balances to 0
        final accountDao = AccountDAO();
        final allAccounts = await accountDao.getAll();
        for (var account in allAccounts) {
          await accountDao.update(account.copyWith(balance: 0.0));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All records deleted and account balances reset'),
            backgroundColor: AppColors.blackBG,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade900,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _resetAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Reset All',
          style: TextStyle(color: AppColors.yellowT, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will:\n\n'
              '• Delete all transactions and budgets\n'
              '• Delete all NEW accounts and categories you created\n'
              '• Reset to DEFAULT accounts (Cash, Bank, Easypaisa) with balance 0\n'
              '• Reset to DEFAULT categories\n\n'
              'The app will restart after reset.\n\n'
              'This action cannot be undone!',
          style: TextStyle(color: AppColors.yellowT.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.yellowT, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Reset All',
              style: TextStyle(color: Colors.red.shade300, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete all transactions
        await TransactionDAO().deleteAll();

        // Delete all budgets
        await BudgetDAO().deleteAll();

        // Delete all categories
        final categoryDao = CategoryDAO();
        await categoryDao.deleteAll();

        // Delete all accounts
        final accountDao = AccountDAO();
        await accountDao.deleteAll();

        // Insert default categories
        await _insertDefaultCategories(categoryDao);

        // Insert default accounts
        await _insertDefaultAccounts(accountDao);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('App reset complete. Restarting...'),
            backgroundColor: AppColors.blackBG,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait and exit app
        await Future.delayed(Duration(seconds: 2));
        SystemNavigator.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade900,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete & Reset', style: TextStyle(color: AppColors.yellowT)),
        backgroundColor: AppColors.blackBG,
        iconTheme: IconThemeData(color: AppColors.yellowT),
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Warning banner
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These actions are permanent and cannot be undone. Please proceed with caution.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Delete Records Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blackBG.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.yellowT.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delete_sweep, color: AppColors.yellowT, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Delete Records',
                          style: TextStyle(
                            color: AppColors.yellowT,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Deletes:\n• All transactions\n• All budgets\n• Resets account balances to 0\n\nKeeps:\n• Your accounts\n• Your categories',
                    style: TextStyle(
                      color: AppColors.yellowT.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _deleteRecords(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'DELETE RECORDS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Reset All Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blackBG.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restore, color: Colors.red.shade300, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reset All',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Deletes:\n• All transactions\n• All budgets\n• All NEW accounts you created\n• All NEW categories you created\n\nRestores:\n• Default accounts (Cash, Bank, Easypaisa)\n• Default categories\n• Account balances set to 0\n\nThis makes the app like it was when first installed.',
                    style: TextStyle(
                      color: AppColors.yellowT.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _resetAll(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'RESET ALL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Info note
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blackBG.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.yellowT.withOpacity(0.6), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Create a backup before performing these actions. You can restore your data later from the backup.',
                      style: TextStyle(
                        color: AppColors.yellowT.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}