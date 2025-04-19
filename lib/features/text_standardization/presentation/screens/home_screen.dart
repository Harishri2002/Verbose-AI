import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verbose_ai/config/routes.dart';
import 'package:verbose_ai/config/theme.dart';
import 'package:verbose_ai/core/api/text_service.dart';
import 'package:verbose_ai/shared/widgets/action_button.dart';
import 'package:verbose_ai/shared/widgets/gradient_container.dart';
import 'package:verbose_ai/shared/widgets/text_area.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextService _textService = TextService();
  bool _isProcessing = false;
  bool _isLoggedIn = false; // This would be determined by auth state

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _standardizeText() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final standardizedText = await _textService.standardizeText(_inputController.text);
      setState(() {
        _outputController.text = standardizedText;
      });
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_outputController.text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _outputController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: AppTheme.secondaryColor,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout
          final bool isWideScreen = constraints.maxWidth > 800;

          return GradientContainer(
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Verbose AI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            if (_isLoggedIn) ...[
                              IconButton(
                                icon: const Icon(Icons.history, color: Colors.white),
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.history);
                                },
                                tooltip: 'History',
                              ),
                              IconButton(
                                icon: const Icon(Icons.person, color: Colors.white),
                                onPressed: () {
                                  // Profile action
                                },
                                tooltip: 'Profile',
                              ),
                            ] else ...[
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.login);
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.signup);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.darkBackground,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 100,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI that standardizes with you',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Convert broken English text into standardized, grammatically correct English.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Text Areas
                              if (isWideScreen)
                              // Wide screen layout (side by side)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextArea(
                                        label: 'Input Text',
                                        hintText: 'Enter broken English text here...',
                                        controller: _inputController,
                                        maxLines: 10,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: TextArea(
                                        label: 'Standardized Text',
                                        hintText: 'Standardized text will appear here...',
                                        controller: _outputController,
                                        readOnly: true,
                                        maxLines: 10,
                                      ),
                                    ),
                                  ],
                                )
                              else
                              // Narrow screen layout (stacked)
                                Column(
                                  children: [
                                    TextArea(
                                      label: 'Input Text',
                                      hintText: 'Enter broken English text here...',
                                      controller: _inputController,
                                      maxLines: 8,
                                    ),
                                    const SizedBox(height: 24),
                                    TextArea(
                                      label: 'Standardized Text',
                                      hintText: 'Standardized text will appear here...',
                                      controller: _outputController,
                                      readOnly: true,
                                      maxLines: 8,
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 24),

                              // Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ActionButton(
                                    text: 'Standardize',
                                    icon: Icons.auto_fix_high,
                                    onPressed: _standardizeText,
                                    isGradient: true,
                                    isLoading: _isProcessing,
                                  ),
                                  const SizedBox(width: 16),
                                  ActionButton(
                                    text: 'Copy Result',
                                    icon: Icons.copy,
                                    onPressed: _copyToClipboard,
                                    isGradient: false,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 48),

                              // Features Section
                              if (isWideScreen)
                                Row(
                                  children: [
                                    _buildFeatureCard(
                                      icon: Icons.auto_fix_high,
                                      title: 'Text Standardization',
                                      description: 'Convert broken English to proper, grammatically correct text.',
                                    ),
                                    _buildFeatureCard(
                                      icon: Icons.history,
                                      title: 'Save History',
                                      description: 'Sign up to save your standardization history.',
                                    ),
                                    _buildFeatureCard(
                                      icon: Icons.devices,
                                      title: 'Cross-Platform',
                                      description: 'Use on web, desktop, iOS, and Android devices.',
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _buildFeatureCard(
                                      icon: Icons.auto_fix_high,
                                      title: 'Text Standardization',
                                      description: 'Convert broken English to proper, grammatically correct text.',
                                      isFullWidth: true,
                                    ),
                                    _buildFeatureCard(
                                      icon: Icons.history,
                                      title: 'Save History',
                                      description: 'Sign up to save your standardization history.',
                                      isFullWidth: true,
                                    ),
                                    _buildFeatureCard(
                                      icon: Icons.devices,
                                      title: 'Cross-Platform',
                                      description: 'Use on web, desktop, iOS, and Android devices.',
                                      isFullWidth: true,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    bool isFullWidth = false,
  }) {
    return Expanded(
      flex: isFullWidth ? 0 : 1,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
