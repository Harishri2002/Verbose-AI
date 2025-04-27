import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:verbose_ai/config/theme.dart';
import 'package:verbose_ai/features/text_standardization/Services/history_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyService = HistoryService();

    // Check if user is logged in
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
        ),
        body: Container(
          color: AppTheme.darkBackground,
          child: const Center(
            child: Text(
              'Please sign in to view your history',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              // Show confirmation dialog to clear all history
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.cardBackground,
                  title: const Text('Clear All History',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  content: const Text(
                    'Are you sure you want to clear all your history? This action cannot be undone.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Clear All'),
                      onPressed: () async {
                        await historyService.clearAllHistory();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear All History',
          ),
        ],
      ),
      body: Container(
        color: AppTheme.darkBackground,
        child: StreamBuilder<QuerySnapshot>(
          stream: historyService.getHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No history found',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final input = data['input'] ?? '';
                final output = data['output'] ?? '';
                final timestamp = data['timestamp'] as Timestamp? ??
                    Timestamp.fromDate(DateTime.now());
                final formattedDate = _formatTimestamp(timestamp);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: AppTheme.cardBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Standardization',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Input:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          input,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Output:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          output,
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, color: AppTheme.primaryColor),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: output));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied to clipboard')),
                                );
                              },
                              tooltip: 'Copy',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () {
                                historyService.deleteHistoryItem(doc.id);
                              },
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}