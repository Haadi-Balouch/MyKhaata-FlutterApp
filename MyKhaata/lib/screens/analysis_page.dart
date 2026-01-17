import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../dao/transaction_dao.dart';
import '../models/transaction_item.dart';
import '../utils/app_colors.dart';

class AnalysisPage extends StatefulWidget {
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  DateTime selectedMonth = DateTime.now();
  String selectedView = 'EXPENSE OVERVIEW';

  final List<String> viewOptions = [
    'EXPENSE OVERVIEW',
    'INCOME OVERVIEW',
    'EXPENSE FLOW',
    'INCOME FLOW',
    'ACCOUNT ANALYSIS',
  ];

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
    return "${months[selectedMonth.month - 1]}. ${selectedMonth.year}";
  }

  Future<void> _showCategoryDetailPopup(String categoryName, bool isExpense, Color categoryColor, IconData categoryIcon) async {
    final data = await _loadAnalysisData();
    final transactions = (isExpense ? data['expenses'] : data['incomes']) as List<TransactionItem>;
    final categoryTransactions = transactions.where((t) => t.categoryName == categoryName).toList();

    Map<String, double> categoryTotals = {};
    for (var t in transactions) {
      categoryTotals[t.categoryName] = (categoryTotals[t.categoryName] ?? 0) + t.amount;
    }

    final total = categoryTotals.values.fold<double>(0, (sum, v) => sum + v);
    final categoryTotal = categoryTotals[categoryName] ?? 0;
    final percentage = total > 0 ? (categoryTotal / total * 100) : 0;

    // Group transactions by date
    Map<String, List<TransactionItem>> groupedByDate = {};
    for (var t in categoryTransactions) {
      if (!groupedByDate.containsKey(t.date)) {
        groupedByDate[t.date] = [];
      }
      groupedByDate[t.date]!.add(t);
    }

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
                      'Category details',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.yellowT),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Time period
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Time selected: ${getMonthYear()}',
                  style: TextStyle(
                    color: AppColors.yellowT.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Category info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: categoryColor,
                      child: Icon(categoryIcon, color: Colors.black, size: 27),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: TextStyle(
                              color: AppColors.yellowT,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${isExpense ? "Expense" : "Income"} category',
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
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Pie chart
                    SizedBox(
                      width: 125,
                      height: 120,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              color: AppColors.yellowT,
                              value: categoryTotal,
                              title: '',
                              radius: 25,
                            ),
                            PieChartSectionData(
                              color: Colors.grey.shade800,
                              value: total - categoryTotal,
                              title: '',
                              radius: 25,
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of total\n${isExpense ? "expense" : "income"} in\nthis period',
                            style: TextStyle(
                              color: AppColors.yellowT.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Expense in this period
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${isExpense ? "Expense" : "Income"} : ',
                      style: TextStyle(
                        color: AppColors.yellowT.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${isExpense ? "-" : ""}${context.currency}${categoryTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isExpense ? Colors.red.shade300 : Colors.green.shade300,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions grouped by date
              Expanded(
                child: ListView(
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
                                '${isExpense ? "-" : ""}${context.currency}${t.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isExpense ? Colors.red.shade300 : Colors.green.shade300,
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
      future: _loadAnalysisData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: AppColors.yellowT));
        }

        final data = snapshot.data!;
        final totalExpense = data['totalExpense'] as double;
        final totalIncome = data['totalIncome'] as double;
        final total = totalIncome - totalExpense;

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
                  IconButton(
                    icon: Icon(Icons.filter_list, color: AppColors.yellowT),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.blackBG,
                        builder: (_) => Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: viewOptions.map((option) {
                              return ListTile(
                                title: Text(option, style: TextStyle(color: AppColors.yellowT)),
                                onTap: () {
                                  setState(() => selectedView = option);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Summary row
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('EXPENSE', style: TextStyle(fontSize: 14, color: AppColors.yellowT.withOpacity(0.7))),
                      Text('${context.currency}${totalExpense.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, color: Colors.red.shade300, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('INCOME', style: TextStyle(fontSize: 14, color: AppColors.yellowT.withOpacity(0.7))),
                      Text('${context.currency}${totalIncome.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, color: Colors.green.shade300, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('TOTAL', style: TextStyle(fontSize: 14, color: AppColors.yellowT.withOpacity(0.7))),
                      Text(
                        '${total >= 0 ? "" : "-"}${context.currency}${total.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 14,
                            color: total >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // View selector button
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.blackBG,
                  builder: (_) => Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: viewOptions.map((option) {
                        return ListTile(
                          title: Text(option, style: TextStyle(color: AppColors.yellowT)),
                          onTap: () {
                            setState(() => selectedView = option);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.yellowT.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.keyboard_arrow_down, color: AppColors.yellowT),
                    SizedBox(width: 8),
                    Text(selectedView, style: TextStyle(fontSize: 16, color: AppColors.yellowT)),
                  ],
                ),
              ),
            ),

            // Content based on selected view
            Expanded(
              child: FutureBuilder<Widget>(
                future: _buildViewContent(selectedView),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(color: AppColors.yellowT));
                  }
                  return snapshot.data!;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadAnalysisData() async {
    final dao = TransactionDAO();
    final transactions = await dao.getTransactionsByMonth(
      selectedMonth.year,
      selectedMonth.month,
    );

    final expenses = transactions.where((t) => t.isExpense).toList();
    final incomes = transactions.where((t) => !t.isExpense).toList();

    final totalExpense = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final totalIncome = incomes.fold<double>(0, (sum, t) => sum + t.amount);

    return {
      'totalExpense': totalExpense,
      'totalIncome': totalIncome,
      'expenses': expenses,
      'incomes': incomes,
      'all': transactions,
    };
  }

  Future<Widget> _buildViewContent(String view) async {
    final data = await _loadAnalysisData();

    switch (view) {
      case 'EXPENSE OVERVIEW':
        return _buildCategoryOverview(data['expenses'] as List<TransactionItem>, true);
      case 'INCOME OVERVIEW':
        return _buildCategoryOverview(data['incomes'] as List<TransactionItem>, false);
      case 'ACCOUNT ANALYSIS':
        return _buildAccountAnalysis(data['all'] as List<TransactionItem>);
      default:
        return _buildCategoryOverview(data['expenses'] as List<TransactionItem>, true);
    }
  }

  Widget _buildCategoryOverview(List<TransactionItem> transactions, bool isExpense) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No ${isExpense ? "expenses" : "income"} this month',
          style: TextStyle(color: AppColors.yellowT.withOpacity(0.6), fontSize: 16),
        ),
      );
    }

    // Group by category
    Map<String, double> categoryTotals = {};
    Map<String, Color> categoryColors = {};
    Map<String, IconData> categoryIcons = {};

    for (var t in transactions) {
      categoryTotals[t.categoryName] = (categoryTotals[t.categoryName] ?? 0) + t.amount;
      categoryColors[t.categoryName] = Color(t.categoryColorValue);
      categoryIcons[t.categoryName] = IconData(t.categoryIconCode, fontFamily: 'MaterialIcons');
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryTotals.values.fold<double>(0, (sum, v) => sum + v);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pie Chart
          Container(
            height: 250,
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                      sections: sortedCategories.take(5).map((entry) {
                        final percentage = (entry.value / total * 100);
                        return PieChartSectionData(
                          color: categoryColors[entry.key],
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 45,
                          titleStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                // Legend
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sortedCategories.take(5).map((entry) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: categoryColors[entry.key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: TextStyle(color: AppColors.yellowT, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Category list
          ...sortedCategories.map((entry) {
            final percentage = (entry.value / total * 100);
            return GestureDetector(
              onTap: () => _showCategoryDetailPopup(
                entry.key,
                isExpense,
                categoryColors[entry.key]!,
                categoryIcons[entry.key]!,
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.blackBG.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.yellowT.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: categoryColors[entry.key],
                      child: Icon(categoryIcons[entry.key], color: Colors.black, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(color: AppColors.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade700,
                            valueColor: AlwaysStoppedAnimation<Color>(categoryColors[entry.key]!),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isExpense ? "-" : ""}${context.currency}${entry.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isExpense ? Colors.red.shade300 : Colors.green.shade300,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(color: AppColors.yellowT.withOpacity(0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildAccountAnalysis(List<TransactionItem> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No transactions this month',
          style: TextStyle(color: AppColors.yellowT.withOpacity(0.6), fontSize: 16),
        ),
      );
    }

    // Group by account
    Map<String, double> accountExpenses = {};
    Map<String, double> accountIncomes = {};
    Map<String, Color> accountColors = {};
    Map<String, IconData> accountIcons = {};

    for (var t in transactions) {
      if (t.isExpense) {
        accountExpenses[t.accountName] = (accountExpenses[t.accountName] ?? 0) + t.amount;
      } else {
        accountIncomes[t.accountName] = (accountIncomes[t.accountName] ?? 0) + t.amount;
      }
      accountColors[t.accountName] = Color(t.accountColorValue);
      accountIcons[t.accountName] = IconData(t.accountIconCode, fontFamily: 'MaterialIcons');
    }

    final accounts = accountExpenses.keys.toSet().union(accountIncomes.keys.toSet()).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Bar Chart
          Container(
            height: 300,
            padding: EdgeInsets.all(20),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: accounts.map((acc) {
                  final exp = accountExpenses[acc] ?? 0;
                  final inc = accountIncomes[acc] ?? 0;
                  return exp > inc ? exp : inc;
                }).reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < accounts.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              accounts[value.toInt()],
                              style: TextStyle(color: AppColors.yellowT, fontSize: 12),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${context.currency}${(value / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(color: AppColors.yellowT, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: accounts.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final acc = entry.value;
                  final exp = accountExpenses[acc] ?? 0;
                  final inc = accountIncomes[acc] ?? 0;

                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: exp,
                        color: Colors.red.shade400,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: inc,
                        color: Colors.green.shade400,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Legend
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(width: 8),
                    Text('Expense', style: TextStyle(color: AppColors.yellowT)),
                  ],
                ),
                SizedBox(width: 30),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: Colors.green.shade400,
                    ),
                    SizedBox(width: 8),
                    Text('Income', style: TextStyle(color: AppColors.yellowT)),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Account details
          ...accounts.map((acc) {
            final exp = accountExpenses[acc] ?? 0;
            final inc = accountIncomes[acc] ?? 0;
            final balance = inc - exp;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blackBG,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: accountColors[acc],
                    child: Icon(accountIcons[acc], color: Colors.black, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          acc,
                          style: TextStyle(
                            color: AppColors.yellowT,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This period: ${balance >= 0 ? "" : "-"}${context.currency}${balance.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: balance >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-${context.currency}${exp.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.red.shade300, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${context.currency}${inc.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.green.shade300, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}