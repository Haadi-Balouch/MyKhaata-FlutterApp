import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../utils/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold)),
        backgroundColor: theme.blackBG,
        iconTheme: IconThemeData(color: theme.yellowT),
      ),
      backgroundColor: theme.scaffoldColor,
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionTitle('Appearance', theme),
          _buildThemeSelector(themeProvider, theme),
          SizedBox(height: 8),
          _buildCurrencySelector(themeProvider, theme),

          SizedBox(height: 32),

          // Security Section
          _buildSectionTitle('Security', theme),
          _buildPasscodeSetting(themeProvider, theme),

          SizedBox(height: 32),

          // Notifications Section
          _buildSectionTitle('Notifications', theme),
          _buildDailyReminderSetting(themeProvider, theme),
          SizedBox(height: 8),
          _buildNotificationSettingsTile(theme),

          SizedBox(height: 32),

          // About Section
          _buildSectionTitle('About', theme),
          _buildPrivacyPolicyTile(theme),
          SizedBox(height: 8),
          _buildVersionTile(theme),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppTheme theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.yellowT,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider, AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.blackBG.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.yellowT.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.yellowT.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.palette_outlined, color: theme.yellowT, size: 24),
        ),
        title: Text(
          'Color Theme',
          style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          theme.name,
          style: TextStyle(color: theme.yellowT.withOpacity(0.7), fontSize: 14),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.5)),
          ),
          child: Text(
            'Coming Soon',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        enabled: false,
        onTap: null,
      ),
    );
  }

  void _showThemeDialog(ThemeProvider themeProvider, AppTheme currentTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: currentTheme.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Color Theme',
          style: TextStyle(color: currentTheme.yellowT, fontWeight: FontWeight.bold),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ThemeProvider.themes.length,
            itemBuilder: (context, index) {
              final theme = ThemeProvider.themes[index];
              final isSelected = themeProvider.selectedThemeIndex == index;

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? theme.yellowT : theme.yellowT.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.yellowT,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.blackBG,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.scaffoldColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    theme.name,
                    style: TextStyle(
                      color: currentTheme.yellowT,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: theme.yellowT)
                      : Icon(Icons.circle_outlined, color: currentTheme.yellowT.withOpacity(0.3)),
                  onTap: () {
                    themeProvider.setTheme(index);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: currentTheme.yellowT)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(ThemeProvider themeProvider, AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.blackBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.yellowT.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.yellowT.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.attach_money, color: theme.yellowT, size: 24),
        ),
        title: Text(
          'Currency Symbol',
          style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          themeProvider.currencySymbol,
          style: TextStyle(color: theme.yellowT.withOpacity(0.7), fontSize: 14),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: theme.yellowT, size: 18),
        onTap: () => _showCurrencyDialog(themeProvider, theme),
      ),
    );
  }

  void _showCurrencyDialog(ThemeProvider themeProvider, AppTheme theme) {
    final currencies = ['Rs', '\$', '€', '£', '¥', '₹', 'د.إ', 'R\$', '₦', '₱', 'Rp','৳','₽','Br','₪','₺','฿','R','₩'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Currency',
          style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold),
        ),
        content: Container(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              final isSelected = themeProvider.currencySymbol == currency;

              return GestureDetector(
                onTap: () {
                  themeProvider.setCurrency(currency);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? theme.yellowT.withOpacity(0.2) : theme.scaffoldColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? theme.yellowT : theme.yellowT.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      currency,
                      style: TextStyle(
                        color: theme.yellowT,
                        fontSize: 24,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: theme.yellowT)),
          ),
        ],
      ),
    );
  }

  Widget _buildPasscodeSetting(ThemeProvider themeProvider, AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.blackBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.yellowT.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.yellowT.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.lock_outline, color: theme.yellowT, size: 24),
            ),
            title: Text(
              'App Lock (Passcode)',
              style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              themeProvider.passcodeEnabled ? 'Enabled' : 'Disabled',
              style: TextStyle(color: theme.yellowT.withOpacity(0.7), fontSize: 14),
            ),
            value: themeProvider.passcodeEnabled,
            activeColor: theme.yellowT,
            onChanged: (value) async {
              if (value) {
                await _showPasscodeSetupDialog(themeProvider, theme);
              } else {
                await _verifyAndDisablePasscode(themeProvider, theme);
              }
            },
          ),
          if (themeProvider.passcodeEnabled)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextButton.icon(
                onPressed: () => _showPasscodeChangeDialog(themeProvider, theme),
                icon: Icon(Icons.edit, color: theme.yellowT, size: 18),
                label: Text(
                  'Change Passcode',
                  style: TextStyle(color: theme.yellowT, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                  backgroundColor: theme.scaffoldColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showPasscodeSetupDialog(ThemeProvider themeProvider, AppTheme theme) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Set Passcode',
          style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: TextStyle(color: theme.yellowT),
              cursorColor: theme.yellowT,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Enter 4-digit passcode',
                labelStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT, width: 2),
                ),
                counterStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmController,
              style: TextStyle(color: theme.yellowT),
              cursorColor: theme.yellowT,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Confirm passcode',
                labelStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT, width: 2),
                ),
                counterStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.yellowT)),
          ),
          TextButton(
            onPressed: () {
              final passcode = controller.text.trim();
              final confirm = confirmController.text.trim();

              if (passcode.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Passcode must be 4 digits'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              if (passcode != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Passcodes do not match'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              themeProvider.setPasscode(passcode);
              themeProvider.setPasscodeEnabled(true);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Passcode enabled successfully'),
                  backgroundColor: theme.blackBG,
                ),
              );
            },
            child: Text(
              'Set Passcode',
              style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyAndDisablePasscode(ThemeProvider themeProvider, AppTheme theme) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Verify Passcode',
          style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: theme.yellowT),
          cursorColor: theme.yellowT,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: 'Enter current passcode',
            labelStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.yellowT.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.yellowT, width: 2),
            ),
            counterStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.yellowT)),
          ),
          TextButton(
            onPressed: () {
              if (themeProvider.verifyPasscode(controller.text.trim())) {
                themeProvider.setPasscodeEnabled(false);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Passcode disabled'),
                    backgroundColor: theme.blackBG,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Incorrect passcode'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
              }
            },
            child: Text(
              'Disable',
              style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPasscodeChangeDialog(ThemeProvider themeProvider, AppTheme theme) async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Change Passcode',
          style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              style: TextStyle(color: theme.yellowT),
              cursorColor: theme.yellowT,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Current passcode',
                labelStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT, width: 2),
                ),
                counterStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: newController,
              style: TextStyle(color: theme.yellowT),
              cursorColor: theme.yellowT,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'New passcode',
                labelStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT, width: 2),
                ),
                counterStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: confirmController,
              style: TextStyle(color: theme.yellowT),
              cursorColor: theme.yellowT,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Confirm new passcode',
                labelStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.yellowT, width: 2),
                ),
                counterStyle: TextStyle(color: theme.yellowT.withOpacity(0.7)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.yellowT)),
          ),
          TextButton(
            onPressed: () {
              if (!themeProvider.verifyPasscode(oldController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Current passcode is incorrect'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              final newPasscode = newController.text.trim();
              final confirm = confirmController.text.trim();

              if (newPasscode.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New passcode must be 4 digits'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              if (newPasscode != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New passcodes do not match'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
                return;
              }

              themeProvider.setPasscode(newPasscode);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Passcode changed successfully'),
                  backgroundColor: theme.blackBG,
                ),
              );
            },
            child: Text(
              'Change',
              style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReminderSetting(ThemeProvider themeProvider, AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.blackBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.yellowT.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.yellowT.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.notifications_active_outlined, color: theme.yellowT, size: 24),
            ),
            title: Text(
              'Daily Reminder',
              style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              themeProvider.dailyReminderEnabled
                  ? 'At ${themeProvider.reminderTime.format(context)}'
                  : 'Disabled',
              style: TextStyle(color: theme.yellowT.withOpacity(0.7), fontSize: 14),
            ),
            value: themeProvider.dailyReminderEnabled,
            activeColor: theme.yellowT,
            onChanged: (value) async {
              if (value) {
                final hasPermission = await Permission.notification.request();
                if (hasPermission.isGranted) {
                  await themeProvider.setDailyReminderEnabled(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Daily reminder enabled'),
                      backgroundColor: theme.blackBG,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notification permission is required'),
                      backgroundColor: Colors.red.shade900,
                    ),
                  );
                }
              } else {
                await themeProvider.setDailyReminderEnabled(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Daily reminder disabled'),
                    backgroundColor: theme.blackBG,
                  ),
                );
              }
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                if (themeProvider.dailyReminderEnabled) ...[
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showTimePickerDialog(themeProvider, theme),
                      icon: Icon(Icons.access_time, color: theme.yellowT, size: 18),
                      label: Text(
                        'Change Time',
                        style: TextStyle(color: theme.yellowT, fontSize: 14),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: theme.scaffoldColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      await themeProvider.testNotification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Test notification sent!'),
                          backgroundColor: theme.blackBG,
                        ),
                      );
                    },
                    icon: Icon(Icons.notification_add, color: theme.yellowT, size: 18),
                    label: Text(
                      'Test',
                      style: TextStyle(color: theme.yellowT, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: theme.scaffoldColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePickerDialog(ThemeProvider themeProvider, AppTheme theme) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: themeProvider.reminderTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.yellowT,
              onPrimary: Colors.black,
              surface: theme.blackBG,
              onSurface: theme.yellowT,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      await themeProvider.setReminderTime(selectedTime);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder time updated to ${selectedTime.format(context)}'),
          backgroundColor: theme.blackBG,
        ),
      );
    }
  }

  Widget _buildNotificationSettingsTile(AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.blackBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.yellowT.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.yellowT.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.settings_outlined, color: theme.yellowT, size: 24),
        ),
        title: Text(
          'Notification Settings',
          style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Open system notification settings',
          style: TextStyle(color: theme.yellowT.withOpacity(0.7), fontSize: 14),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: theme.yellowT, size: 18),
        onTap: () async {
          await openAppSettings();
        },
      ),
    );
  }

  Widget _buildPrivacyPolicyTile(AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.blackBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.yellowT.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.yellowT.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.privacy_tip_outlined,
            color: theme.yellowT,
            size: 24,
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: theme.yellowT,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'View our privacy policy',
          style: TextStyle(
            color: theme.yellowT.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.yellowT,
          size: 18,
        ),
        onTap: () => _showPrivacyPolicyDialog(theme),
      ),
    );
  }

  void _showPrivacyPolicyDialog(AppTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.blackBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data Storage',
                style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'All your financial data is stored locally on your device. MyKhaata does not collect, transmit, or share any of your personal or financial information with external servers.',
                style: TextStyle(color: theme.yellowT.withOpacity(0.8), fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Permissions',
                style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Storage: Required for backup/export features\n'
                    '• Notifications: Optional, for daily reminders\n\n'
                    'We only request permissions necessary for app functionality.',
                style: TextStyle(color: theme.yellowT.withOpacity(0.8), fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Security',
                style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your data remains on your device and is protected by your device\'s security measures. Optional passcode protection adds an extra layer of security.',
                style: TextStyle(color: theme.yellowT.withOpacity(0.8), fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: theme.yellowT, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionTile(AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.blackBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.yellowT.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.yellowT.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.info_outline, color: theme.yellowT, size: 24),
        ),
        title: Text(
          'Version',
          style: TextStyle(color: theme.yellowT, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '1.0.0',
          style: TextStyle(color: theme.yellowT.withOpacity(0.7), fontSize: 14),
        ),
      ),
    );
  }
}