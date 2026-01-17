import 'package:flutter/material.dart';
import '../dao/transaction_dao.dart';
import '../models/transaction_item.dart';
import '../utils/app_colors.dart';
import '../models/category_item.dart';
import '../models/account_item.dart';
import '../dao/category_dao.dart';
import '../dao/account_dao.dart';
import '../widgets/category_selector.dart';
import '../widgets/account_selector.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePage createState() => _AddExpensePage();
}

class _AddExpensePage extends State<AddExpensePage> {
  bool isExpense = true;
  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();
  CategoryItem? selectedCategory;
  AccountItem? selectedAccount;
  late String selectedDate = formattedDate(DateTime.now());
  late String selectedTime = formattedTime(TimeOfDay.now());

  String formattedDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String formattedTime(TimeOfDay time) {
    int hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute $suffix";
  }

  void showDatePickerDialog(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          selectedDate = formattedDate(pickedDate);
        });
      }
    });
  }

  void showTimePickerDialog(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedTime) {
      if (pickedTime != null) {
        setState(() {
          selectedTime = pickedTime.format(context);
        });
      }
    });
  }

  Widget _typeButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.yellowT.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  isExpense = false;
                  selectedCategory = null;
                });
              },
              child: Column(
                children: [
                  Text(
                    "Income",
                    style: TextStyle(
                      fontSize: 20,
                      color: !isExpense ? AppColors.yellowT : AppColors.yellowT.withOpacity(0.6),
                      fontWeight: !isExpense ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 5),
                  if (!isExpense)
                    Container(
                      height: 2,
                      width: 60,
                      color: AppColors.yellowT,
                    )
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.yellowT.withOpacity(0.4),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  isExpense = true;
                  selectedCategory = null;
                });
              },
              child: Column(
                children: [
                  Text(
                    "Expense",
                    style: TextStyle(
                      fontSize: 20,
                      color: isExpense ? AppColors.yellowT : AppColors.yellowT.withOpacity(0.6),
                      fontWeight: isExpense ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 5),
                  if (isExpense)
                    Container(
                      height: 2,
                      width: 60,
                      color: AppColors.yellowT,
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blackBG,
        foregroundColor: AppColors.yellowT,
        automaticallyImplyLeading: false,
        leadingWidth: 105,
        leading: TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: 20, color: AppColors.yellowT),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            child: Text(
              "Save",
              style: TextStyle(fontSize: 20, color: AppColors.yellowT),
            ),
            onPressed: () async {
              // Validation
              if (selectedCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select a category'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              if (selectedAccount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select an account'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              final amountValue = double.tryParse(amount.text.trim());
              if (amountValue == null || amountValue <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid positive amount'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              if (amountValue > 99999999) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Amount is too large'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              try {
                // Create transaction
                final transaction = TransactionItem(
                  amount: amountValue,
                  note: note.text.trim(),
                  categoryName: selectedCategory!.name,
                  categoryIconCode: selectedCategory!.iconCode,
                  categoryColorValue: selectedCategory!.colorValue,
                  accountName: selectedAccount!.name,
                  accountIconCode: selectedAccount!.iconCode,
                  accountColorValue: selectedAccount!.colorValue,
                  date: selectedDate,
                  time: selectedTime,
                  isExpense: isExpense,
                  timestamp: DateTime.now(),
                );

                // Save transaction
                final transactionDao = TransactionDAO();
                await transactionDao.insert(transaction);

                // Update account balance
                final accountDao = AccountDAO();
                final updatedBalance = isExpense
                    ? selectedAccount!.balance - amountValue
                    : selectedAccount!.balance + amountValue;

                final updatedAccount = selectedAccount!.copyWith(balance: updatedBalance);
                await accountDao.update(updatedAccount);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transaction saved successfully'),
                    backgroundColor: AppColors.blackBG,
                    duration: Duration(seconds: 2),
                  ),
                );

                // Navigate back
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving transaction: $e'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
              }
            },
          )
        ],
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: SingleChildScrollView(
    child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
          children: [
            _typeButton(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.yellowT.withOpacity(0.5), width: 1),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AccountSelector(),
                      );
                      if (result != null && result is AccountItem) {
                        setState(() => selectedAccount = result);
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: selectedAccount?.color ?? AppColors.blackBG,
                          child: Icon(
                            selectedAccount?.icon ?? Icons.account_balance_wallet_outlined,
                            color: AppColors.yellowT,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          selectedAccount?.name ?? "Account",
                          style: TextStyle(fontSize: 16, color: AppColors.yellowT),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.yellowT.withOpacity(0.5), width: 1),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CategorySelector(isExpense: isExpense),
                      );
                      if (result != null && result is CategoryItem) {
                        setState(() => selectedCategory = result);
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: selectedCategory?.color ?? AppColors.blackBG,
                          child: Icon(
                            selectedCategory?.icon ?? Icons.label_outlined,
                            color: AppColors.yellowT,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          selectedCategory?.name ?? "Category",
                          style: TextStyle(fontSize: 16, color: AppColors.yellowT),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter Amount : ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.yellowT,
                  ),
                ),
                Container(
                  height: 40,
                  width: 180,
                  child: TextField(
                    controller: amount,
                    style: TextStyle(color: AppColors.yellowT),
                    cursorColor: AppColors.yellowT,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "e.g 1000",
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.yellowT),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.yellowT, width: 2),
                      ),
                      prefixIcon: Icon(Icons.attach_money_outlined, color: AppColors.yellowT),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              height: 150,
              width: 350,
              child: TextField(
                controller: note,
                style: TextStyle(color: AppColors.yellowT),
                maxLines: 5,
                cursorColor: AppColors.yellowT,
                decoration: InputDecoration(
                  labelText: "Add a Note",
                  floatingLabelStyle: TextStyle(color: AppColors.yellowT),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.yellowT),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.yellowT, width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Date : ',
                  style: TextStyle(fontSize: 20, color: AppColors.yellowT),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => showDatePickerDialog(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.yellowT,
                    backgroundColor: AppColors.blackBG,
                    side: BorderSide(color: AppColors.yellowT),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(selectedDate),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Time : ",
                  style: TextStyle(fontSize: 20, color: AppColors.yellowT),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => showTimePickerDialog(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.yellowT,
                    backgroundColor: AppColors.blackBG,
                    side: BorderSide(color: AppColors.yellowT),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(selectedTime, style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}