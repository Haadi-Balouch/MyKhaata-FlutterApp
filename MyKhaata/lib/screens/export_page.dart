import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../dao/transaction_dao.dart';
import '../utils/app_colors.dart';
import '../utils/permission_helper.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _exportRecords() async {
    try {
      if (!await PermissionHelper.requestStoragePermission(context)) {
        return;
      }

      final dao = TransactionDAO();
      final transactions = await dao.getAll();

      final filtered = transactions.where((t) {
        return t.timestamp.isAfter(startDate.subtract(Duration(days: 1))) &&
            t.timestamp.isBefore(endDate.add(Duration(days: 1)));
      }).toList();

      if (filtered.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No records in selected date range'),
            backgroundColor: Colors.orange.shade900,
          ),
        );
        return;
      }

      String? directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      String csv = 'Date,Time,Type,Category,Account,Amount,Note\n';
      for (var t in filtered) {
        final note = t.note.replaceAll('"', '""');
        csv += '${t.date},${t.time},${t.isExpense ? "Expense" : "Income"},'
            '${t.categoryName},${t.accountName},${t.amount},"$note"\n';
      }

      final file = File(
        '$directory/MyKhaata_Export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );

      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export successful: ${filtered.length} records'),
          backgroundColor: AppColors.blackBG,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
  }

  String formatDate(DateTime date) {
    const months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Records', style: TextStyle(color: AppColors.yellowT)),
        backgroundColor: AppColors.blackBG,
        iconTheme: IconThemeData(color: AppColors.yellowT),
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blackBG.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• All records between a specified time range can be exported as a CSV file.',
                    style: TextStyle(color: AppColors.yellowT, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• To export records, set the start date and end date below and tap EXPORT NOW.',
                    style: TextStyle(color: AppColors.yellowT, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Note: Exported CSV files are not backup files and cannot restore data.',
                    style: TextStyle(color: AppColors.yellowT, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text('From:', style: TextStyle(color: AppColors.yellowT, fontSize: 18)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.yellowT),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.yellowT),
                    SizedBox(width: 10),
                    Text(
                      formatDate(startDate),
                      style: TextStyle(color: AppColors.yellowT, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Text('To:', style: TextStyle(color: AppColors.yellowT, fontSize: 18)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.yellowT),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.yellowT),
                    SizedBox(width: 10),
                    Text(
                      formatDate(endDate),
                      style: TextStyle(color: AppColors.yellowT, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: _exportRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blackBG,
                foregroundColor: AppColors.yellowT,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('EXPORT NOW', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}