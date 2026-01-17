import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';

Future<void> showFeedbackDialog(BuildContext context) {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  String feedbackType = 'General Feedback';

  void _showEmailFallback(BuildContext context, String recipientEmail, String subject, String emailBody) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blackBG,
        title: Text('Email App Not Found', style: TextStyle(color: AppColors.yellowT)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please email us at:', style: TextStyle(color: AppColors.yellowT)),
              SizedBox(height: 8),
              SelectableText(
                recipientEmail,
                style: TextStyle(color: AppColors.yellowT, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Subject:', style: TextStyle(color: AppColors.yellowT)),
              SelectableText(
                subject,
                style: TextStyle(color: AppColors.yellowT.withOpacity(0.8)),
              ),
              SizedBox(height: 16),
              Text('Message:', style: TextStyle(color: AppColors.yellowT)),
              SelectableText(
                emailBody,
                style: TextStyle(color: AppColors.yellowT.withOpacity(0.8)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.yellowT)),
          ),
        ],
      ),
    );
  }
  final feedbackTypes = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'Question',
    'Compliment',
  ];

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: AppColors.blackBG,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          color: AppColors.yellowT,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Send Feedback',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.yellowT,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.yellowT),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We\'d love to hear from you! Your feedback helps us improve MyKhaata.',
                      style: TextStyle(
                        color: AppColors.yellowT.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Feedback Type Dropdown
                    Text(
                      'Feedback Type',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.yellowT),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: feedbackType,
                          isExpanded: true,
                          dropdownColor: AppColors.blackBG,
                          style: TextStyle(color: AppColors.yellowT, fontSize: 16),
                          icon: Icon(Icons.arrow_drop_down, color: AppColors.yellowT),
                          items: feedbackTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => feedbackType = value);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Name Field
                    Text(
                      'Your Name (Optional)',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: AppColors.yellowT),
                      cursorColor: AppColors.yellowT,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(color: AppColors.yellowT.withOpacity(0.4)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.yellowT),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.yellowT, width: 2),
                        ),
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.yellowT),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Email Field
                    Text(
                      'Your Email (Optional)',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: AppColors.yellowT),
                      cursorColor: AppColors.yellowT,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: AppColors.yellowT.withOpacity(0.4)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.yellowT),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.yellowT, width: 2),
                        ),
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.yellowT),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Message Field
                    Text(
                      'Your Message *',
                      style: TextStyle(
                        color: AppColors.yellowT,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: messageController,
                      style: TextStyle(color: AppColors.yellowT),
                      cursorColor: AppColors.yellowT,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Tell us what you think...',
                        hintStyle: TextStyle(color: AppColors.yellowT.withOpacity(0.4)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.yellowT),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.yellowT, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: AppColors.yellowT),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.yellowT,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final message = messageController.text.trim();
                              if (message.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please enter your message'),
                                    backgroundColor: Colors.red.shade900,
                                  ),
                                );
                                return;
                              }

                              final name = nameController.text.trim();
                              final email = emailController.text.trim();

                              String emailBody = 'Feedback Type: $feedbackType\n\n';
                              if (name.isNotEmpty) {
                                emailBody += 'Name: $name\n';
                              }
                              if (email.isNotEmpty) {
                                emailBody += 'Email: $email\n';
                              }
                              emailBody += '\nMessage:\n$message';

                              final subject = 'MyKhaata Feedback: $feedbackType';
                              final recipientEmail = 'haadi.baloch.7880@gmail.com';

                              // Create mailto URI with queryParameters (safer than manual encoding)
                              final uri = Uri(
                                scheme: 'mailto',
                                path: recipientEmail,
                                queryParameters: {
                                  'subject': subject,
                                  'body': emailBody,
                                },
                              );

                              try {
                                // Check if can launch
                                if (await canLaunchUrl(uri)) {
                                  final launched = await launchUrl(uri);

                                  if (launched) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Opening email app...'),
                                        backgroundColor: AppColors.blackBG,
                                      ),
                                    );
                                  } else {
                                    // Fallback if launch fails
                                    _showEmailFallback(context, recipientEmail, subject, emailBody);
                                  }
                                } else {
                                  // No email app found
                                  _showEmailFallback(context, recipientEmail, subject, emailBody);
                                }
                              } catch (e) {
                                // Error occurred
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}\nPlease email: $recipientEmail'),
                                    backgroundColor: Colors.red.shade900,
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.yellowT,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        'We typically respond within 24-48 hours',
                        style: TextStyle(
                          color: AppColors.yellowT.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
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