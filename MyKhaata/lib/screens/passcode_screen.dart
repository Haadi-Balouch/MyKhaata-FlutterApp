import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import 'home_page.dart';

class PasscodeScreen extends StatefulWidget {
  @override
  _PasscodeScreenState createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final TextEditingController _passcodeController = TextEditingController();
  String _enteredPasscode = '';

  void _onNumberPressed(String number) {
    if (_enteredPasscode.length < 4) {
      setState(() {
        _enteredPasscode += number;
        _passcodeController.text = _enteredPasscode;
      });

      if (_enteredPasscode.length == 4) {
        _verifyPasscode();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPasscode.isNotEmpty) {
      setState(() {
        _enteredPasscode = _enteredPasscode.substring(0, _enteredPasscode.length - 1);
        _passcodeController.text = _enteredPasscode;
      });
    }
  }

  void _verifyPasscode() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (themeProvider.verifyPasscode(_enteredPasscode)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyHomePage()),
      );
    } else {
      setState(() {
        _enteredPasscode = '';
        _passcodeController.text = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect passcode'),
          backgroundColor: Colors.red.shade900,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60),

            // App icon/logo
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.yellowT.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 60,
                color: theme.yellowT,
              ),
            ),

            SizedBox(height: 40),

            // Title
            Text(
              'Enter Passcode',
              style: TextStyle(
                color: theme.yellowT,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 40),

            // Passcode dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPasscode.length
                        ? theme.yellowT
                        : theme.yellowT.withOpacity(0.3),
                    border: Border.all(
                      color: theme.yellowT,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 60),

            // Number pad
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildNumberRow(['1', '2', '3'], theme),
                    SizedBox(height: 20),
                    _buildNumberRow(['4', '5', '6'], theme),
                    SizedBox(height: 20),
                    _buildNumberRow(['7', '8', '9'], theme),
                    SizedBox(height: 20),
                    _buildNumberRow(['', '0', 'del'], theme),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers, AppTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return SizedBox(width: 80, height: 80);
        }

        return GestureDetector(
          onTap: () {
            if (number == 'del') {
              _onDeletePressed();
            } else {
              _onNumberPressed(number);
            }
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.blackBG,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.yellowT.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: number == 'del'
                  ? Icon(
                Icons.backspace_outlined,
                color: theme.yellowT,
                size: 28,
              )
                  : Text(
                number,
                style: TextStyle(
                  color: theme.yellowT,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}