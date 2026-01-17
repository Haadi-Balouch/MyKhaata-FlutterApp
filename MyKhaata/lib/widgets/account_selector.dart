import 'package:flutter/material.dart';
import '../models/account_item.dart';
import '../dao/account_dao.dart';
import '../utils/app_colors.dart';

class AccountSelector extends StatefulWidget {
  final AccountItem? currentAccount;

  AccountSelector({this.currentAccount});

  @override
  _AccountSelectorState createState() => _AccountSelectorState();
}

class _AccountSelectorState extends State<AccountSelector> {
  final dao = AccountDAO();
  List<AccountItem> accounts = [];
  List<AccountItem> filteredAccounts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => isLoading = true);
    try {
      final loadedAccounts = await dao.getAll();
      setState(() {
        accounts = loadedAccounts;
        filteredAccounts = loadedAccounts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading accounts: $e')),
      );
    }
  }

  void _filterAccounts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAccounts = accounts;
      } else {
        filteredAccounts = accounts
            .where((account) =>
            account.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        color: AppColors.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellowT,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.yellowT),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: AppColors.yellowT),
              cursorColor: AppColors.yellowT,
              decoration: InputDecoration(
                hintText: 'Search accounts...',
                hintStyle: TextStyle(color: AppColors.yellowT.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: AppColors.yellowT),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.yellowT),
                  onPressed: () {
                    searchController.clear();
                    _filterAccounts('');
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
              onChanged: _filterAccounts,
            ),
          ),

          SizedBox(height: 16),

          // Account List
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(color: AppColors.yellowT),
            )
                : filteredAccounts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: AppColors.yellowT.withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    searchController.text.isEmpty
                        ? 'No accounts available'
                        : 'No accounts found',
                    style: TextStyle(
                      color: AppColors.yellowT.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredAccounts.length,
              itemBuilder: (_, index) {
                final item = filteredAccounts[index];
                final isSelected = widget.currentAccount?.id == item.id;

                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.yellowT.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.yellowT
                          : AppColors.yellowT.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: item.color,
                      child: Icon(
                        item.icon,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 18,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                      Icons.check_circle,
                      color: AppColors.yellowT,
                      size: 28,
                    )
                        : Icon(
                      Icons.circle_outlined,
                      color: AppColors.yellowT.withOpacity(0.3),
                      size: 28,
                    ),
                    onTap: () => Navigator.pop(context, item),
                  ),
                );
              },
            ),
          ),

          // Footer with account count
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.yellowT.withOpacity(0.2),
                ),
              ),
            ),
            child: Text(
              '${filteredAccounts.length} ${filteredAccounts.length == 1 ? 'account' : 'accounts'}',
              style: TextStyle(
                color: AppColors.yellowT.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}