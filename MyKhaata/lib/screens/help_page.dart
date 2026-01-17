import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blackBG,
        foregroundColor: AppColors.yellowT,
        title: Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.yellowT,
          unselectedLabelColor: AppColors.yellowT.withOpacity(0.5),
          indicatorColor: AppColors.yellowT,
          tabs: [
            Tab(text: 'FAQs'),
            Tab(text: 'Basics'),
            Tab(text: 'Guides'),
            Tab(text: 'Others'),
          ],
        ),
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQs(),
          _buildBasics(),
          _buildGuides(),
          _buildOthers(),
        ],
      ),
    );
  }

  Widget _buildFAQs() {
    final faqs = [
      {
        'question': 'How do I add a transaction?',
        'answer': 'Tap the + button at the bottom of the screen. Select whether it\'s income or expense, choose an account and category, enter the amount and any notes, then tap Save.',
      },
      {
        'question': 'Can I edit a transaction after saving?',
        'answer': 'Currently, you can delete transactions but not edit them. To modify a transaction, delete it and create a new one with the correct information.',
      },
      {
        'question': 'How do I set a budget?',
        'answer': 'Go to the Budget tab, select a month, and tap "SET BUDGET" next to any category. Enter your budget limit and save.',
      },
      {
        'question': 'What happens when I exceed my budget?',
        'answer': 'The budget tracker will show in red and display a "Limit exceeded" warning. This is just a visual reminder to help you stay on track.',
      },
      {
        'question': 'How do I add a new category?',
        'answer': 'Go to the Categories tab and tap "Add new Categories". Choose whether it\'s for income or expense, enter a name, select an icon, and save.',
      },
      {
        'question': 'Can I delete a category?',
        'answer': 'Yes, go to Categories, tap the three dots next to any category, and select Delete. Note that this won\'t delete existing transactions using that category.',
      },
      {
        'question': 'How do account balances work?',
        'answer': 'When you add a transaction, the account balance automatically updates. Income increases the balance, expenses decrease it.',
      },
      {
        'question': 'Can I have multiple accounts?',
        'answer': 'Yes! You can create unlimited accounts like Cash, Bank, Credit Card, etc. Go to the Accounts tab to manage them.',
      },
      {
        'question': 'How do I search for transactions?',
        'answer': 'Tap the search icon in the top right corner. You can search by note, category, account, amount, or date.',
      },
      {
        'question': 'What currency does MyKhaata use?',
        'answer': 'MyKhaata currently displays amounts in a vast Currencies. You can choose you desired currency from settings.',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return _buildExpandableCard(
          faqs[index]['question']!,
          faqs[index]['answer']!,
        );
      },
    );
  }

  Widget _buildBasics() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Getting Started'),
          _buildContentCard(
            'Welcome to MyKhaata!',
            'MyKhaata is your personal finance companion. Track income, expenses, set budgets, and gain insights into your spending habits. All your financial data stays on your device for complete privacy.',
          ),
          SizedBox(height: 16),

          _buildSectionTitle('Main Features'),
          _buildContentCard(
            '📝 Records',
            'View all your transactions organized by month and date. See your income, expenses, and total balance at a glance.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '📊 Analysis',
            'Visualize your spending with pie charts and bar graphs. Compare expenses by category or analyze account-wise spending.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '💰 Budget',
            'Set monthly budget limits for each category. Track your spending progress and get warnings when you exceed limits.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '🏦 Accounts',
            'Manage multiple accounts like Cash, Bank, Mobile Wallets. Each account maintains its own balance automatically.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '🏷️ Categories',
            'Organize transactions with customizable categories. Create separate categories for income and expenses.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuides() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Adding Your First Transaction'),
          _buildStepCard(
            '1. Tap the + Button',
            'Located at the bottom center of the screen.',
          ),
          _buildStepCard(
            '2. Choose Type',
            'Select whether this is Income or Expense.',
          ),
          _buildStepCard(
            '3. Select Account & Category',
            'Tap the account and category selectors to choose from your options.',
          ),
          _buildStepCard(
            '4. Enter Details',
            'Add the amount, write a note (optional), and adjust date/time if needed.',
          ),
          _buildStepCard(
            '5. Save',
            'Tap Save in the top right. Your transaction is now recorded!',
          ),

          SizedBox(height: 24),
          _buildSectionTitle('Setting Up Budgets'),
          _buildStepCard(
            '1. Go to Budget Tab',
            'Navigate using the bottom navigation bar.',
          ),
          _buildStepCard(
            '2. Select Month',
            'Use the arrows to choose which month to budget for.',
          ),
          _buildStepCard(
            '3. Set Budget',
            'Tap "SET BUDGET" next to any expense category.',
          ),
          _buildStepCard(
            '4. Enter Amount',
            'Type your budget limit and tap Save.',
          ),
          _buildStepCard(
            '5. Monitor Progress',
            'Watch the progress bar fill as you add expenses.',
          ),

          SizedBox(height: 24),
          _buildSectionTitle('Managing Accounts'),
          _buildStepCard(
            '1. Open Accounts Tab',
            'From the bottom navigation.',
          ),
          _buildStepCard(
            '2. Add New Account',
            'Tap "ADD NEW ACCOUNT" button.',
          ),
          _buildStepCard(
            '3. Enter Details',
            'Name your account, choose an icon, and set initial balance (optional).',
          ),
          _buildStepCard(
            '4. Save',
            'Your new account is ready to use!',
          ),
          _buildStepCard(
            '5. Edit or Delete',
            'Tap the three dots on any account to modify or remove it.',
          ),

          SizedBox(height: 24),
          _buildSectionTitle('Viewing Analysis'),
          _buildStepCard(
            '1. Go to Analysis Tab',
            'Access from bottom navigation.',
          ),
          _buildStepCard(
            '2. Choose Month',
            'Use arrows to select the period you want to analyze.',
          ),
          _buildStepCard(
            '3. Switch Views',
            'Tap the dropdown to switch between Expense Overview, Income Overview, and Account Analysis.',
          ),
          _buildStepCard(
            '4. Understand Charts',
            'Pie charts show category breakdowns. Bar charts compare account activity.',
          ),
        ],
      ),
    );
  }

  Widget _buildOthers() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tips & Best Practices'),
          _buildContentCard(
            '💡 Use Descriptive Notes',
            'Add notes to your transactions so you can remember what each expense was for when reviewing later.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '💡 Review Regularly',
            'Check your Records and Analysis tabs weekly to stay aware of your spending patterns.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '💡 Set Realistic Budgets',
            'Base your budgets on past spending. Review and adjust them monthly.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '💡 Categorize Consistently',
            'Use the same categories for similar expenses to get accurate analysis.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '💡 Multiple Accounts',
            'Create accounts for each payment method you use (Cash, Cards, E-wallets).',
          ),

          SizedBox(height: 24),
          _buildSectionTitle('Data Management'),
          _buildContentCard(
            '📤 Export Records',
            'Save your transaction history as CSV or Excel files. Find this in the drawer menu under Management.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '💾 Backup & Restore',
            'Create backups of your entire database. Restore from previous backups anytime.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '🗑️ Delete & Reset',
            'Remove specific data types or reset the entire app. Use with caution - this cannot be undone!',
          ),

          SizedBox(height: 24),
          _buildSectionTitle('Privacy & Security'),
          _buildContentCard(
            '🔒 Local Storage',
            'All your data is stored locally on your device. Nothing is sent to external servers.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '🛡️ Your Privacy',
            'MyKhaata does not collect, transmit, or share any of your financial information.',
          ),

          SizedBox(height: 24),
          _buildSectionTitle('Troubleshooting'),
          _buildContentCard(
            '❓ App Not Responding',
            'Try closing and reopening the app. If problems persist, restart your device.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '❓ Missing Transactions',
            'Check that you\'re viewing the correct month in Records tab. Use Search to find specific transactions.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '❓ Wrong Balance',
            'Verify all transactions are recorded correctly. Delete and re-add any incorrect entries.',
          ),

          SizedBox(height: 24),
          _buildSectionTitle('Contact & Feedback'),
          _buildContentCard(
            '📧 Get in Touch',
            'Have questions or suggestions? Use the Feedback option in the drawer menu to send us an email.',
          ),
          SizedBox(height: 12),
          _buildContentCard(
            '⭐ Rate the App',
            'If you find MyKhaata helpful, please consider leaving a rating on the app store!',
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard(String question, String answer) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: AppColors.blackBG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: TextStyle(
            color: AppColors.yellowT,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconColor: AppColors.yellowT,
        collapsedIconColor: AppColors.yellowT,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: AppColors.yellowT.withOpacity(0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.yellowT,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContentCard(String title, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blackBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellowT.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.yellowT,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: AppColors.yellowT.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String step, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blackBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellowT.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: AppColors.yellowT,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: TextStyle(
                    color: AppColors.yellowT,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.yellowT.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}