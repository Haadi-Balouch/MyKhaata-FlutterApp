import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/account_item.dart';
import '../models/transaction_item.dart';
import '../dao/account_dao.dart';
import '../dao/transaction_dao.dart';

class AccountsPage extends StatefulWidget {
  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final dao = AccountDAO();
  final transactionDao = TransactionDAO();

  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  String _getShortMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  Future<void> _showAccountDetailPopup(AccountItem account) async {
    // Get all transactions for this account
    final allTransactions = await transactionDao.getAll();
    final accountTransactions = allTransactions
        .where((t) => t.accountName == account.name)
        .toList();

    // Group by month
    Map<String, List<TransactionItem>> groupedByMonth = {};
    for (var t in accountTransactions) {
      final monthKey = '${_getMonthName(t.timestamp.month)}, ${t.timestamp.year}';
      if (!groupedByMonth.containsKey(monthKey)) {
        groupedByMonth[monthKey] = [];
      }
      groupedByMonth[monthKey]!.add(t);
    }

    // Sort months (most recent first)
    final sortedMonths = groupedByMonth.keys.toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Container(
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
                      'Account details',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 22,
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

              // Records period
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Records: All time',
                  style: TextStyle(
                    color: AppColors.yellowT.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Account info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: account.color,
                      child: Icon(account.icon, color: Colors.black, size: 40),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: TextStyle(
                              color: AppColors.yellowT,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Account balance: ${context.currency}${account.balance.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.yellowT,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Info box
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.yellowT.withOpacity(0.7), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can see Monthly, weekly, or daily statistics of this account in the Analysis section.',
                        style: TextStyle(
                          color: AppColors.yellowT.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Divider(color: AppColors.yellowT.withOpacity(0.3)),

              // Transaction count and sort
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ${accountTransactions.length} records in this account',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions grouped by month
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: sortedMonths.length,
                  itemBuilder: (context, index) {
                    final monthKey = sortedMonths[index];
                    final monthTransactions = groupedByMonth[monthKey]!;

                    // Calculate totals for the month
                    double monthIncome = 0;
                    double monthExpense = 0;
                    for (var t in monthTransactions) {
                      if (t.isExpense) {
                        monthExpense += t.amount;
                      } else {
                        monthIncome += t.amount;
                      }
                    }

                    // Group by date within month
                    Map<String, List<TransactionItem>> groupedByDate = {};
                    for (var t in monthTransactions) {
                      if (!groupedByDate.containsKey(t.date)) {
                        groupedByDate[t.date] = [];
                      }
                      groupedByDate[t.date]!.add(t);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month header
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            monthKey,
                            style: TextStyle(
                              color: AppColors.yellowT,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Transactions by date
                        ...groupedByDate.entries.map((entry) {
                          final date = entry.key;
                          final dateTransactions = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date subheader
                              Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 4),
                                child: Text(
                                  date,
                                  style: TextStyle(
                                    color: AppColors.yellowT.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // Transactions
                              ...dateTransactions.map((t) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Color(t.categoryColorValue),
                                        child: Icon(
                                          IconData(t.categoryIconCode, fontFamily: 'MaterialIcons'),
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
                                              t.categoryName,
                                              style: TextStyle(
                                                color: AppColors.yellowT,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (t.note.isNotEmpty)
                                              Text(
                                                t.note,
                                                style: TextStyle(
                                                  color: AppColors.yellowT.withOpacity(0.6),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${t.isExpense ? "-" : ""}${context.currency}${t.amount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: t.isExpense
                                                  ? Colors.red.shade300
                                                  : Colors.green.shade300,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${_getShortMonthName(t.timestamp.month)} ${t.timestamp.day}',
                                            style: TextStyle(
                                              color: AppColors.yellowT.withOpacity(0.6),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        }),

                        SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: FutureBuilder<List<AccountItem>>(
        future: dao.getAll(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.yellowT),
            );
          }

          final accounts = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Accounts",
                    style: TextStyle(
                      fontSize: 25,
                      color: AppColors.yellowT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ...accounts.map((item) => accountCard(item)),
                  SizedBox(height: 20),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await showAddAccountDialog(context);
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        side: BorderSide(color: AppColors.yellowT, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.yellowT,
                        size: 24,
                      ),
                      label: Text(
                        'ADD NEW ACCOUNT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.yellowT,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteAccount(AccountItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blackBG,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Delete Account',
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
        await dao.delete(item.id!);
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
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red.shade900,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _editAccount(AccountItem item) async {
    await showEditAccountDialog(context, item);
    setState(() {});
  }

  Widget accountCard(AccountItem item) {
    return GestureDetector(
      onTap: () => _showAccountDetailPopup(item),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blackBG.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.yellowT.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.yellowT,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Balance: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.yellowT.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '${context.currency}${item.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.green.shade300,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              color: AppColors.blackBG,
              icon: Icon(Icons.more_vert, color: AppColors.yellowT, size: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == "edit") {
                  _editAccount(item);
                } else if (value == "delete") {
                  _deleteAccount(item);
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
      ),
    );
  }
}

// Add Account Dialog
Future<void> showAddAccountDialog(BuildContext context) {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  List<Map<String, dynamic>> availableIcons = [
    {"icon": Icons.account_balance, "color": Colors.blue.shade300},
    {"icon": Icons.account_balance_wallet, "color": Colors.green.shade300},
    {"icon": Icons.credit_card, "color": Colors.purple.shade300},
    {"icon": Icons.money, "color": Colors.green.shade400},
    {"icon": Icons.savings, "color": Colors.orange.shade300},
    {"icon": Icons.phone_iphone, "color": Colors.indigo.shade300},
    {"icon": Icons.payment, "color": Colors.teal.shade300},
    {"icon": Icons.account_balance_wallet_outlined, "color": Colors.cyan.shade300},
    {"icon": Icons.attach_money, "color": Colors.lightGreen.shade300},
    {"icon": Icons.wallet, "color": Colors.brown.shade300},
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add new account",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5E9A9),
                      ),
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
                          hintText: "Account Name",
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFF5E9A9)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: amountController,
                        style: TextStyle(color: Color(0xFFF5E9A9)),
                        cursorColor: Color(0xFFF5E9A9),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Initial Amount (optional)",
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Color(0xFFF5E9A9),
                          ),
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
                                  content: Text('Please enter an account name'),
                                  backgroundColor: Colors.red.shade900,
                                ),
                              );
                              return;
                            }

                            final selected = availableIcons[selectedIconIndex];
                            final amount = double.tryParse(amountController.text.trim()) ?? 0.0;

                            final newAccount = AccountItem(
                              name: name,
                              iconCode: (selected['icon'] as IconData).codePoint,
                              colorValue: (selected['color'] as Color).value,
                              balance: amount,
                            );

                            final dao = AccountDAO();
                            await dao.insert(newAccount);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account added successfully'),
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
                                "SAVE",
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


// Edit Account Dialog
Future<void> showEditAccountDialog(BuildContext context, AccountItem account) {
  TextEditingController nameController = TextEditingController(text: account.name);
  TextEditingController amountController = TextEditingController(text: account.balance.toString());

  List<Map<String, dynamic>> availableIcons = [
    {"icon": Icons.account_balance, "color": Colors.blue.shade300},
    {"icon": Icons.account_balance_wallet, "color": Colors.green.shade300},
    {"icon": Icons.credit_card, "color": Colors.purple.shade300},
    {"icon": Icons.money, "color": Colors.green.shade400},
    {"icon": Icons.savings, "color": Colors.orange.shade300},
    {"icon": Icons.phone_iphone, "color": Colors.indigo.shade300},
    {"icon": Icons.payment, "color": Colors.teal.shade300},
    {"icon": Icons.account_balance_wallet_outlined, "color": Colors.cyan.shade300},
    {"icon": Icons.attach_money, "color": Colors.lightGreen.shade300},
    {"icon": Icons.wallet, "color": Colors.brown.shade300},
  ];

  int selectedIconIndex = 0;
  for (int i = 0; i < availableIcons.length; i++) {
    if ((availableIcons[i]['icon'] as IconData).codePoint == account.iconCode &&
        (availableIcons[i]['color'] as Color).value == account.colorValue) {
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
                      "Edit Account",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5E9A9),
                      ),
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
                          hintText: "Account Name",
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFF5E9A9)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: amountController,
                        style: TextStyle(color: Color(0xFFF5E9A9)),
                        cursorColor: Color(0xFFF5E9A9),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Balance Amount",
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Color(0xFFF5E9A9),
                          ),
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
                                  content: Text('Please enter an account name'),
                                  backgroundColor: Colors.red.shade900,
                                ),
                              );
                              return;
                            }

                            final selected = availableIcons[selectedIconIndex];
                            final amount = double.tryParse(amountController.text.trim()) ?? account.balance;

                            final updatedAccount = AccountItem(
                              id: account.id,
                              name: name,
                              iconCode: (selected['icon'] as IconData).codePoint,
                              colorValue: (selected['color'] as Color).value,
                              balance: amount,
                            );

                            final dao = AccountDAO();
                            await dao.update(updatedAccount);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account updated successfully'),
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