import 'package:flutter/material.dart';
import 'package:verbose_ai/config/theme.dart';
import 'package:verbose_ai/shared/widgets/gradient_container.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This would be populated from a real data source
    final List<Map<String, String>> historyItems = [
      {
        'input': 'i need help with my english its not very good',
        'output': 'I need help with my English. It\'s not very good.',
        'date': 'Today, 2:30 PM',
      },
      {
        'input': 'can you fix this text for me please its important',
        'output': 'Can you fix this text for me please? It\'s important.',
        'date': 'Yesterday, 10:15 AM',
      },
      {
        'input': 'my name john i from london i like to travel',
        'output': 'My name is John. I am from London. I like to travel.',
        'date': 'Apr 15, 2025',
      },
    ];

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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            final item = historyItems[index];
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
                          item['date']!,
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
                      item['input']!,
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
                      item['output']!,
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, color: AppTheme.primaryColor),
                          onPressed: () {
                            // Copy to clipboard
                          },
                          tooltip: 'Copy',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () {
                            // Delete from history
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
        ),
      ),
    );
  }
}
