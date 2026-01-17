import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../db/app_database.dart';
import '../utils/app_colors.dart';
import '../utils/permission_helper.dart';

class BackupRestorePage extends StatefulWidget {
  @override
  _BackupRestorePageState createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  String? selectedDirectory;

  Future<void> _selectDirectory() async {
    if (!await PermissionHelper.requestStoragePermission(context)) {
      return;
    }

    String? selectedPath = await FilePicker.platform.getDirectoryPath();
    if (selectedPath != null) {
      setState(() {
        selectedDirectory = selectedPath;
      });
    }
  }

  Future<void> _backupDatabase() async {
    try {
      if (!await PermissionHelper.requestStoragePermission(context)) {
        return;
      }

      if (selectedDirectory == null) {
        await _selectDirectory();
        if (selectedDirectory == null) return;
      }

      final db = await AppDatabase.instance.database;
      final dbPath = db.path;

      // Close database to ensure file is not locked
      await db.close();

      // Reopen database
      final newDb = await AppDatabase.instance.database;

      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception('Database file not found at: $dbPath');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = 'mykhaata_backup_$timestamp.db';
      final backupPath = path.join(selectedDirectory!, backupFileName);
      final backupFile = File(backupPath);

      // Copy database file
      await dbFile.copy(backupPath);

      if (await backupFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully!\n$backupFileName'),
            backgroundColor: AppColors.blackBG,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Failed to create backup file');
      }
    } catch (e) {
      print('Backup error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade900,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _restoreDatabase() async {
    try {
      if (!await PermissionHelper.requestStoragePermission(context)) {
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final backupPath = result.files.single.path!;
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.blackBG,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Restore Database',
            style: TextStyle(color: AppColors.yellowT, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This will replace all current data with the backup. This action cannot be undone!\n\nThe app will restart after restore.',
            style: TextStyle(color: AppColors.yellowT.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: AppColors.yellowT)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Restore',
                style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Get current database path
      final db = await AppDatabase.instance.database;
      final dbPath = db.path;

      // Close database
      await db.close();

      // Create backup of current database before restoring
      final currentDbFile = File(dbPath);
      if (await currentDbFile.exists()) {
        final emergencyBackup = File('${dbPath}_emergency_backup');
        await currentDbFile.copy(emergencyBackup.path);
      }

      // Copy backup file to database location
      await backupFile.copy(dbPath);

      // Verify the restore
      final restoredFile = File(dbPath);
      if (!await restoredFile.exists()) {
        throw Exception('Failed to restore database file');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore successful! App will restart...'),
          backgroundColor: AppColors.blackBG,
          duration: Duration(seconds: 3),
        ),
      );

      // Wait and exit app
      await Future.delayed(Duration(seconds: 3));
      SystemNavigator.pop();

    } catch (e) {
      print('Restore error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade900,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup & Restore', style: TextStyle(color: AppColors.yellowT)),
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
                    '📌 Important Information',
                    style: TextStyle(
                      color: AppColors.yellowT,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• A backup file contains all your records, categories, accounts & budgets.',
                    style: TextStyle(color: AppColors.yellowT, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Select or change the backup directory where files will be saved.',
                    style: TextStyle(color: AppColors.yellowT, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• To backup: Press BACKUP NOW. A .db file will be created.',
                    style: TextStyle(color: AppColors.yellowT, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '⚠️ After restoring, the app will close automatically. Please restart it manually.',
                    style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _backupDatabase,
              icon: Icon(Icons.backup, size: 24),
              label: Text('BACKUP NOW', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blackBG,
                foregroundColor: AppColors.yellowT,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _restoreDatabase,
              icon: Icon(Icons.restore, size: 24),
              label: Text('RESTORE FROM BACKUP', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blackBG,
                foregroundColor: AppColors.yellowT,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _selectDirectory,
              icon: Icon(Icons.folder_open, size: 24),
              label: Text('SELECT BACKUP FOLDER', style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.yellowT,
                side: BorderSide(color: AppColors.yellowT, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (selectedDirectory != null) ...[
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blackBG.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.yellowT.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected folder:',
                      style: TextStyle(
                        color: AppColors.yellowT.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      selectedDirectory!,
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}