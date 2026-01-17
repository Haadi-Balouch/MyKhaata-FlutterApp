
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../dao/budget_dao.dart';
import '../dao/category_dao.dart';
import '../dao/transaction_dao.dart';
import '../models/budget_item.dart';
import '../models/category_item.dart';
import '../models/transaction_item.dart';
import '../utils/app_colors.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  DateTime selectedMonth = DateTime.now();

  void changeMonth(int delta) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + delta);
    });
  }

  String getMonthYear() {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return "${months[selectedMonth.month - 1]}, ${selectedMonth.year}";
  }

  String getShortMonthYear() {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[selectedMonth.month - 1]}, ${selectedMonth.year}";
  }

  Future<void> _showBudgetDetailPopup(BudgetItem budget, CategoryItem category, double spent, Map<String, double> allSpending) async {
    final transactionDao = TransactionDAO();
    final transactions = await transactionDao.getTransactionsByMonth(selectedMonth.year, selectedMonth.month);
    final categoryTransactions = transactions.where((t) => t.isExpense && t.categoryName == budget.categoryName).toList();

    // Calculate percentage
    final totalSpent = allSpending.values.fold<double>(0, (sum, v) => sum + v);
    final percentage = totalSpent > 0 ? (spent / totalSpent * 100) : 0;
    final double safePercentage = percentage.isNaN ? 0.0 : percentage.clamp(0.0, 100.0).toDouble();


    // Group transactions by date
    Map<String, List<TransactionItem>> groupedByDate = {};
    for (var t in categoryTransactions) {
      if (!groupedByDate.containsKey(t.date)) {
        groupedByDate[t.date] = [];
      }
      groupedByDate[t.date]!.add(t);
    }

    final isOverBudget = spent > budget.limit;
    final remaining = budget.limit - spent;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: Color(0xFF5A5A52),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget details',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: AppColors.yellowT),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _showSetBudgetDialog(context, category, budget);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red.shade300),
                          onPressed: () async {
                            Navigator.pop(context);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.blackBG,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                title: Text('Delete Budget', style: TextStyle(color: AppColors.yellowT, fontWeight: FontWeight.bold)),
                                content: Text('Are you sure you want to delete this budget?', style: TextStyle(color: AppColors.yellowT.withOpacity(0.8))),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: AppColors.yellowT))),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await BudgetDAO().delete(budget.id!);
                              setState(() {});
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.yellowT),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Time period
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Time selected: ${getMonthYear()}',
                  style: TextStyle(
                    color: AppColors.yellowT.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Category info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: category.color,
                      child: Icon(category.icon, color: Colors.black, size: 32),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.categoryName,
                            style: TextStyle(
                              color: AppColors.yellowT,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Expense category',
                            style: TextStyle(
                              color: AppColors.yellowT.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Chart and percentage
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Pie chart
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                          sections: safePercentage == 0
                              ? [
                            PieChartSectionData(
                              color: Colors.grey.shade800,
                              value: 100,
                              title: '',
                              radius: 26,
                            ),
                          ]
                              : [
                            PieChartSectionData(
                              color: AppColors.yellowT,
                              value: safePercentage,
                              title: '',
                              radius: 26,
                            ),
                            PieChartSectionData(
                              color: Colors.grey.shade800,
                              value: 100 - safePercentage,
                              title: '',
                              radius: 26,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: AppColors.yellowT,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of total\nexpense in\nthis period',
                            style: TextStyle(
                              color: AppColors.yellowT.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              // Budget info
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budget Limit:', style: TextStyle(color: AppColors.yellowT.withOpacity(0.8), fontSize: 14)),
                        Text('${context.currency}${budget.limit.toStringAsFixed(2)}', style: TextStyle(color: AppColors.yellowT, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Spent:', style: TextStyle(color: AppColors.yellowT.withOpacity(0.8), fontSize: 14)),
                        Text('${context.currency}${spent.toStringAsFixed(2)}', style: TextStyle(color: isOverBudget ? Colors.red.shade300 : Colors.green.shade300, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Remaining:', style: TextStyle(color: AppColors.yellowT.withOpacity(0.8), fontSize: 14)),
                        Text('${isOverBudget ? "-" : ""}${context.currency}${remaining.abs().toStringAsFixed(2)}', style: TextStyle(color: isOverBudget ? Colors.red.shade300 : Colors.green.shade300, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (spent / budget.limit).clamp(0, 1),
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade700,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget ? Colors.red.shade400 : Colors.green.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Divider(color: AppColors.yellowT.withOpacity(0.3)),

              // Transaction list
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${getShortMonthYear()} : ${categoryTransactions.length} records',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions grouped by date
              Expanded(
                child: categoryTransactions.isEmpty
                    ? Center(
                  child: Text(
                    'No transactions in this category',
                    style: TextStyle(
                      color: AppColors.yellowT.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                )
                    : ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: groupedByDate.entries.map((entry) {
                    final date = entry.key;
                    final transactions = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            date,
                            style: TextStyle(
                              color: AppColors.yellowT,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...transactions.map((t) => Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.yellowT,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                t.time,
                                style: TextStyle(
                                  color: AppColors.yellowT.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  t.accountName,
                                  style: TextStyle(
                                    color: AppColors.yellowT,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '-${context.currency}${t.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.red.shade300,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadBudgetData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: AppColors.yellowT));
        }

        final data = snapshot.data!;
        final budgets = data['budgets'] as List<BudgetItem>;
        final spending = data['spending'] as Map<String, double>;
        final categories = data['categories'] as List<CategoryItem>;
        final totalBudget = data['totalBudget'] as double;
        final totalSpent = data['totalSpent'] as double;

        final budgetedCategories = budgets.map((b) => b.categoryName).toSet();
        final notBudgeted = categories.where((c) => c.isExpense && !budgetedCategories.contains(c.name)).toList();

        return Column(
          children: [
            // Month selector
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppColors.yellowT),
                    onPressed: () => changeMonth(-1),
                  ),
                  Text(
                    getMonthYear(),
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.yellowT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: AppColors.yellowT),
                    onPressed: () => changeMonth(1),
                  ),
                ],
              ),
            ),

            // Total Budget and Spent
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'TOTAL BUDGET',
                        style: TextStyle(fontSize: 14, color: AppColors.yellowT.withOpacity(0.7)),
                      ),
                      Text(
                        '${context.currency}${totalBudget.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, color: AppColors.yellowT, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'TOTAL SPENT',
                        style: TextStyle(fontSize: 14, color: AppColors.yellowT.withOpacity(0.7)),
                      ),
                      Text(
                        '${context.currency}${totalSpent.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: totalSpent > totalBudget ? Colors.red.shade300 : Colors.orange.shade300,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.yellowT.withOpacity(0.3), thickness: 1),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budgeted categories
                    if (budgets.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Budgeted categories: ${getShortMonthYear()}',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.yellowT,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...budgets.map((budget) {
                        final spent = spending[budget.categoryName] ?? 0;
                        final remaining = budget.limit - spent;
                        final percentage = (spent / budget.limit * 100).clamp(0, 100);
                        final isOverBudget = spent > budget.limit;

                        final category = categories.firstWhere(
                              (c) => c.name == budget.categoryName,
                          orElse: () => CategoryItem(
                            name: budget.categoryName,
                            iconCode: Icons.help_outline.codePoint,
                            colorValue: Colors.grey.value,
                            isExpense: true,
                          ),
                        );

                        return GestureDetector(
                          onTap: () => _showBudgetDetailPopup(budget, category, spent, spending),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.blackBG,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: category.color,
                                      child: Icon(category.icon, color: Colors.black, size: 24),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            budget.categoryName,
                                            style: TextStyle(
                                              color: AppColors.yellowT,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Limit: ${context.currency}${budget.limit.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: AppColors.yellowT.withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Spent: ${isOverBudget ? "-" : ""}${context.currency}${spent.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: isOverBudget ? Colors.red.shade300 : Colors.green.shade300,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Remaining: ${isOverBudget ? "-" : ""}${context.currency}${remaining.abs().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: isOverBudget ? Colors.red.shade300 : Colors.green.shade300,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        PopupMenuButton(
                                          color: AppColors.blackBG,
                                          icon: Icon(Icons.more_vert, color: AppColors.yellowT),
                                          onSelected: (value) async {
                                            if (value == "edit") {
                                              await _showSetBudgetDialog(context, category, budget);
                                            } else if (value == "delete") {
                                              await BudgetDAO().delete(budget.id!);
                                              setState(() {});
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            PopupMenuItem(
                                              value: "edit",
                                              child: Text("Edit", style: TextStyle(color: AppColors.yellowT)),
                                            ),
                                            PopupMenuItem(
                                              value: "delete",
                                              child: Text("Delete", style: TextStyle(color: AppColors.yellowT)),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '(${getShortMonthYear()})',
                                          style: TextStyle(
                                            color: AppColors.yellowT.withOpacity(0.5),
                                            fontSize: 11,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${context.currency}${budget.limit.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.green.shade300,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (isOverBudget)
                                          Text(
                                            '*Limit exceeded',
                                            style: TextStyle(
                                              color: Colors.red.shade300,
                                              fontSize: 10,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 12,
                                    backgroundColor: Colors.grey.shade700,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isOverBudget ? Colors.red.shade400 : Colors.green.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],

                    // Not budgeted categories
                    if (notBudgeted.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Not budgeted this month',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.yellowT,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...notBudgeted.map((category) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.blackBG,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: category.color,
                                child: Icon(category.icon, color: Colors.black, size: 20),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: AppColors.yellowT,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await _showSetBudgetDialog(context, category, null);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: AppColors.yellowT,
                                  side: BorderSide(color: AppColors.yellowT),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('SET BUDGET'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],

                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadBudgetData() async {
    final budgetDao = BudgetDAO();
    final transactionDao = TransactionDAO();
    final categoryDao = CategoryDAO();

    final budgets = await budgetDao.getBudgetsByMonth(
      selectedMonth.year,
      selectedMonth.month,
    );

    final transactions = await transactionDao.getTransactionsByMonth(
      selectedMonth.year,
      selectedMonth.month,
    );

    final categories = await categoryDao.getAllCategories();

    // Calculate spending per category
    Map<String, double> spending = {};
    for (var t in transactions.where((t) => t.isExpense)) {
      spending[t.categoryName] = (spending[t.categoryName] ?? 0) + t.amount;
    }

    final totalBudget = budgets.fold<double>(0, (sum, b) => sum + b.limit);
    final totalSpent = spending.values.fold<double>(0, (sum, v) => sum + v);

    return {
      'budgets': budgets,
      'spending': spending,
      'categories': categories,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
    };
  }

  Future<void> _showSetBudgetDialog(BuildContext context, CategoryItem category, BudgetItem? existingBudget) async {
    final controller = TextEditingController(text: existingBudget?.limit.toString() ?? '');

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.blackBG,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  existingBudget == null ? 'Set Budget' : 'Edit Budget',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellowT,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: category.color,
                      child: Icon(category.icon, color: Colors.black, size: 28),
                    ),
                    SizedBox(width: 16),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.yellowT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.yellowT),
                  cursorColor: AppColors.yellowT,
                  decoration: InputDecoration(
                    labelText: 'Budget Amount',
                    labelStyle: TextStyle(color: AppColors.yellowT),
                    prefixText: '${context.currency} ',
                    prefixStyle: TextStyle(color: AppColors.yellowT),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.yellowT),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.yellowT, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.yellowT,
                        side: BorderSide(color: AppColors.yellowT),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(controller.text);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a valid amount'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final dao = BudgetDAO();

                        if (existingBudget != null) {
                          // Update existing
                          await dao.update(
                            existingBudget.id!,
                            amount,
                          );
                        } else {
                          // Create new
                          final budget = BudgetItem(
                            categoryName: category.name,
                            limit: amount,
                            month: selectedMonth.month,
                            year: selectedMonth.year,
                          );
                          await dao.insert(budget);
                        }

                        Navigator.pop(context);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.yellowT,
                        side: BorderSide(color: AppColors.yellowT),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text('SAVE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}