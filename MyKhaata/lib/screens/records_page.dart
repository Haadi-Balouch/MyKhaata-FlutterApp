import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../dao/transaction_dao.dart';
import '../dao/account_dao.dart';
import '../models/transaction_item.dart';

class RecordsPage extends StatefulWidget {
  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final transactionDao = TransactionDAO();
  final accountDao = AccountDAO();
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

  Future<void> _showTransactionDetailPopup(TransactionItem transaction) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF5A5A52),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: transaction.isExpense ? Colors.red.shade700 : Colors.green.shade700,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.white),
                              onPressed: () async {
                                Navigator.pop(context);
                                await _deleteTransaction(transaction);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                                // TODO: Implement edit functionality
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Transaction type
                    Text(
                      transaction.isExpense ? 'EXPENSE' : 'INCOME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    // Amount
                    Text(
                      '${context.currency}${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    // Date and time
                    Text(
                      '${transaction.date} ${transaction.time}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 10),

                  ],
                ),
              ),
              // Top actions
              SizedBox(height: 20),
              // Account
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(transaction.accountColorValue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              IconData(transaction.accountIconCode, fontFamily: 'MaterialIcons'),
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  transaction.accountName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Category
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(transaction.categoryColorValue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              IconData(transaction.categoryIconCode, fontFamily: 'MaterialIcons'),
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  transaction.categoryName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Notes
                    Text(
                      transaction.note.isEmpty ? 'No notes' : transaction.note,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(TransactionItem transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Delete Transaction', style: TextStyle(color: AppColors.yellowT, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete this transaction?\n\nThis action cannot be undone.',
          style: TextStyle(color: AppColors.yellowT.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.yellowT, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red.shade300, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Revert account balance
        final account = await accountDao.getByName(transaction.accountName);
        if (account != null) {
          final revertedBalance = transaction.isExpense
              ? account.balance + transaction.amount
              : account.balance - transaction.amount;
          await accountDao.update(account.copyWith(balance: revertedBalance));
        }

        // Delete transaction
        await transactionDao.delete(transaction.id!);
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction deleted successfully'), backgroundColor: AppColors.blackBG),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting transaction: $e'), backgroundColor: Colors.red.shade900),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontSize: 20, color: AppColors.yellowT, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.yellowT),
                onPressed: () => changeMonth(1),
              ),
            ],
          ),
        ),

        // Summary
        FutureBuilder<Map<String, double>>(
          future: _calculateSummary(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.yellowT),
              );
            }

            final income = snapshot.data!['income']!;
            final expense = snapshot.data!['expense']!;
            final total = income - expense;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('INCOME', income, Colors.green.shade300),
                  _summaryItem('EXPENSE', expense, Colors.red.shade300),
                  _summaryItem('TOTAL', total, total >= 0 ? Colors.green.shade300 : Colors.red.shade300),
                ],
              ),
            );
          },
        ),

        Divider(color: AppColors.yellowT.withOpacity(0.3), thickness: 1),

        // Transaction list
        Expanded(
          child: FutureBuilder<List<TransactionItem>>(
            future: transactionDao.getTransactionsByMonth(selectedMonth.year, selectedMonth.month),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(color: AppColors.yellowT));
              }

              final transactions = snapshot.data!;

              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.yellowT.withOpacity(0.3)),
                      SizedBox(height: 16),
                      Text('No transactions this month', style: TextStyle(color: AppColors.yellowT.withOpacity(0.6), fontSize: 16)),
                    ],
                  ),
                );
              }

              // Group by date
              Map<String, List<TransactionItem>> groupedTransactions = {};
              for (var t in transactions) {
                if (!groupedTransactions.containsKey(t.date)) {
                  groupedTransactions[t.date] = [];
                }
                groupedTransactions[t.date]!.add(t);
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  final date = groupedTransactions.keys.elementAt(index);
                  final dayTransactions = groupedTransactions[date]!;
                  final dayTotal = dayTransactions.fold<double>(
                    0,
                        (sum, t) => sum + (t.isExpense ? -t.amount : t.amount),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date header
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: TextStyle(color: AppColors.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${dayTotal >= 0 ? "+" : ""}${context.currency}${dayTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: dayTotal >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Transactions
                      ...dayTransactions.map((t) => _transactionCard(t)),
                      SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(String label, double value, Color color) {
    return Flexible(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.yellowT.withOpacity(0.7)),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${context.currency}${value.abs().toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(TransactionItem transaction) {
    return GestureDetector(
      onTap: () => _showTransactionDetailPopup(transaction),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.blackBG.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.yellowT.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(transaction.categoryColorValue),
              child: Icon(IconData(transaction.categoryIconCode, fontFamily: 'MaterialIcons'), color: Colors.black, size: 24),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryName,
                    style: TextStyle(color: AppColors.yellowT, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  if (transaction.note.isNotEmpty)
                    Text(
                      transaction.note,
                      style: TextStyle(color: AppColors.yellowT.withOpacity(0.6), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Row(
                    children: [
                      Icon(IconData(transaction.accountIconCode, fontFamily: 'MaterialIcons'),
                          color: AppColors.yellowT.withOpacity(0.6), size: 14),
                      SizedBox(width: 4),
                      Text(
                        transaction.accountName,
                        style: TextStyle(color: AppColors.yellowT.withOpacity(0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isExpense ? "-" : "+"}${context.currency}${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.isExpense ? Colors.red.shade300 : Colors.green.shade300,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  transaction.time,
                  style: TextStyle(color: AppColors.yellowT.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, double>> _calculateSummary() async {
    final transactions = await transactionDao.getTransactionsByMonth(selectedMonth.year, selectedMonth.month);
    double income = 0, expense = 0;

    for (var t in transactions) {
      if (t.isExpense) {
        expense += t.amount;
      } else {
        income += t.amount;
      }
    }

    return {'income': income, 'expense': expense};
  }
}