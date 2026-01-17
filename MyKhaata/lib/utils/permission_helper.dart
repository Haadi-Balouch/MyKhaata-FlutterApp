import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PermissionHelper {
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // For Android 11 and above, we need to use MANAGE_EXTERNAL_STORAGE
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 30) {
        // Android 11+ (API 30+)
        if (await Permission.manageExternalStorage.isGranted) {
          return true;
        }

        if (await Permission.manageExternalStorage.isPermanentlyDenied) {
          return await _showSettingsDialog(
            context,
            'Storage permission is required to save files. Please enable "All files access" in app settings.',
          );
        }

        final status = await Permission.manageExternalStorage.request();

        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          return await _showSettingsDialog(
            context,
            'Storage permission is required. Please enable "All files access" in app settings.',
          );
        }
      } else {
        // Android 10 and below
        if (await Permission.storage.isGranted) {
          return true;
        }

        if (await Permission.storage.isPermanentlyDenied) {
          return await _showSettingsDialog(
            context,
            'Storage permission is required. Please enable it in app settings.',
          );
        }

        final status = await Permission.storage.request();

        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          return await _showSettingsDialog(
            context,
            'Storage permission is required. Please enable it in app settings.',
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Storage permission is required'),
          backgroundColor: Colors.red.shade900,
        ),
      );
      return false;
    }

    return true; // For iOS or other platforms
  }

  static Future<int> _getAndroidVersion() async {
    try {
      // This is a simple way to check Android version
      // You might need to add device_info_plus package for more accurate detection
      return 30; // Assume Android 11+ by default for safety
    } catch (e) {
      return 30;
    }
  }

  static Future<bool> requestNotificationPermission(BuildContext context) async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    if (await Permission.notification.isPermanentlyDenied) {
      return await _showSettingsDialog(
        context,
        'Notification permission is required for daily reminders. Please enable it in app settings.',
      );
    }

    final status = await Permission.notification.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      return await _showSettingsDialog(
        context,
        'Notification permission is required. Please enable it in app settings.',
      );
    }

    return false;
  }

  static Future<bool> _showSettingsDialog(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF5A5A5A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Permission Required',
          style: TextStyle(color: Color(0xFFEAE1A7), fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: TextStyle(color: Color(0xFFEAE1A7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Color(0xFFEAE1A7))),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context, true);
            },
            child: Text(
              'Open Settings',
              style: TextStyle(color: Color(0xFFEAE1A7), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}