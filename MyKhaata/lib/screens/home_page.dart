import 'package:flutter/material.dart';
import 'package:mykhaata2/screens/feedback_page.dart';
import 'package:mykhaata2/screens/help_page.dart';
import 'package:mykhaata2/screens/search_page.dart';
import 'package:mykhaata2/screens/settings_page.dart';
import '../utils/app_colors.dart';
import 'backup_restore_page.dart';
import 'delete_reset_page.dart';
import 'export_page.dart';
import 'records_page.dart';
import 'analysis_page.dart';
import 'budget_page.dart';
import 'accounts_page.dart';
import 'categories_page.dart';
import 'add_expense_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  Widget getPage(int index) {
    switch (index) {
      case 0: return RecordsPage();
      case 1: return AnalysisPage();
      case 2: return BudgetPage();
      case 3: return AccountsPage();
      case 4: return CategoriesPage();
      default: return RecordsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MyKhaata",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.yellowT,
          ),
        ),
        backgroundColor: AppColors.blackBG,
        iconTheme: IconThemeData(
          color: AppColors.yellowT,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
            },
            icon: Icon(Icons.search, color: AppColors.yellowT),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.blackBG,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "MyKhaata",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.yellowT,
                ),
              ),
            ),
            SizedBox(height: 50),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: AppColors.yellowT),
              title: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.yellowT,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Management",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.yellowT,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.file_copy_outlined, color: AppColors.yellowT),
              title: Text('Export Records', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.yellowT)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ExportPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.save_outlined, color: AppColors.yellowT),
              title: Text('Backup & Restore', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.yellowT)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => BackupRestorePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.yellowT),
              title: Text('Delete & Reset', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.yellowT)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => DeleteResetPage()));
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Application",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.yellowT,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.help_outline_outlined, color: AppColors.yellowT),
              title: Text(
                'Help',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.yellowT,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => HelpPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.mail_outline_outlined, color: AppColors.yellowT),
              title: Text(
                'Feedback',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.yellowT,
                ),
              ),
              onTap: ()  => showFeedbackDialog(context),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: getPage(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blackBG,
        foregroundColor: AppColors.yellowT,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          "+",
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 40,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpensePage()),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.blackBG,
        selectedItemColor: AppColors.yellowT,
        unselectedItemColor: AppColors.yellowT.withOpacity(0.6),
        currentIndex: _selectedIndex,
        iconSize: 35,
        selectedFontSize: 14,
        unselectedFontSize: 13,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: "Records"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Analysis"),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_outlined), label: "Budget"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Accounts"),
          BottomNavigationBarItem(icon: Icon(Icons.label_outlined), label: "Categories"),
        ],
      ),
    );
  }
}