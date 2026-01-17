import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../dao/transaction_dao.dart';
import '../dao/account_dao.dart';
import '../models/transaction_item.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final transactionDao = TransactionDAO();
  final accountDao = AccountDAO();
  final searchController = TextEditingController();

  List<TransactionItem> allTransactions = [];
  List<TransactionItem> filteredTransactions = [];
  bool isLoading = true;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllTransactions();
  }

  Future<void> _loadAllTransactions() async {
    setState(() => isLoading = true);
    try {
      final transactions = await transactionDao.getAll();
      setState(() {
        allTransactions = transactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredTransactions = [];
        hasSearched = false;
      });
      return;
    }

    setState(() => hasSearched = true);

    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredTransactions = allTransactions.where((transaction) {
        // Search in note
        if (transaction.note.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        // Search in category name
        if (transaction.categoryName.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        // Search in account name
        if (transaction.accountName.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        // Search in amount
        if (transaction.amount.toString().contains(lowerQuery)) {
          return true;
        }

        // Search in date
        if (transaction.date.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        return false;
      }).toList();
    });
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

        await transactionDao.delete(transaction.id!);
        await _loadAllTransactions();
        _performSearch(searchController.text);

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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blackBG,
        foregroundColor: AppColors.yellowT,
        title: Text('Search Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: AppColors.yellowT),
              cursorColor: AppColors.yellowT,
              decoration: InputDecoration(
                hintText: 'Search by note, category, account, amount, or date...',
                hintStyle: TextStyle(color: AppColors.yellowT.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: AppColors.yellowT),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.yellowT),
                  onPressed: () {
                    searchController.clear();
                    _performSearch('');
                  },
                )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.yellowT.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.yellowT, width: 2),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),

          // Results
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.yellowT))
                : !hasSearched
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_outlined,
                    size: 80,
                    color: AppColors.yellowT.withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Search for transactions',
                    style: TextStyle(
                      color: AppColors.yellowT.withOpacity(0.6),
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Enter keywords to search by note, category, account, amount, or date',
                      style: TextStyle(
                        color: AppColors.yellowT.withOpacity(0.4),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
                : filteredTransactions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_outlined,
                    size: 80,
                    color: AppColors.yellowT.withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(
                      color: AppColors.yellowT.withOpacity(0.6),
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try different keywords',
                    style: TextStyle(
                      color: AppColors.yellowT.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '${filteredTransactions.length} result${filteredTransactions.length == 1 ? "" : "s"} found',
                    style: TextStyle(
                      color: AppColors.yellowT,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      return _transactionCard(filteredTransactions[index]);
                    },
                  ),
                ),
              ],
            ),
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
              child: Icon(
                IconData(transaction.categoryIconCode, fontFamily: 'MaterialIcons'),
                color: Colors.black,
                size: 24,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryName,
                    style: TextStyle(
                      color: AppColors.yellowT,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.note.isNotEmpty)
                    Text(
                      transaction.note,
                      style: TextStyle(
                        color: AppColors.yellowT.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Row(
                    children: [
                      Icon(
                        IconData(transaction.accountIconCode, fontFamily: 'MaterialIcons'),
                        color: AppColors.yellowT.withOpacity(0.6),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        transaction.accountName,
                        style: TextStyle(
                          color: AppColors.yellowT.withOpacity(0.8),
                          fontSize: 13,
                        ),
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
                  style: TextStyle(
                    color: AppColors.yellowT.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}