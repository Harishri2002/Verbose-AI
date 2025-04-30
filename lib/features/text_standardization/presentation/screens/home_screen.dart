import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verbose_ai/config/routes.dart';
import 'package:verbose_ai/config/theme.dart';
import 'package:verbose_ai/core/api/text_service.dart';
import 'package:verbose_ai/features/text_standardization/Services/history_service.dart';
import 'package:verbose_ai/shared/widgets/action_button.dart';
import 'package:verbose_ai/shared/widgets/gradient_container.dart';
import 'package:verbose_ai/shared/widgets/text_area.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextService _textService = TextService();
  final HistoryService _historyService = HistoryService();
  bool _isProcessing = false;
  bool _textStandardized = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _standardizeText() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _textStandardized = false;
    });

    try {
      final standardizedText = await _textService.standardizeText(_inputController.text);

      // Save to history if user is logged in
      if (FirebaseAuth.instance.currentUser != null) {
        await _historyService.saveToHistory(_inputController.text, standardizedText);
      }

      setState(() {
        _outputController.text = standardizedText;
        _textStandardized = true;
      });

      // Trigger animation
      _animationController.reset();
      _animationController.forward();

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
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool hasOutput = _outputController.text.isNotEmpty;

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
                        ).animate()
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
                        Row(
                          children: [
                            if (isLoggedIn) ...[
                              IconButton(
                                icon: const Icon(Icons.history, color: Colors.white),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/history');
                                },
                                tooltip: 'History',
                              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                              // User avatar with popup menu
                              IconButton(
                                icon: FirebaseAuth.instance.currentUser?.photoURL != null
                                    ? CachedNetworkImage(
                                  imageUrl: FirebaseAuth.instance.currentUser!.photoURL!,
                                  imageBuilder: (context, imageProvider) => CircleAvatar(
                                    backgroundImage: imageProvider,
                                    radius: 15,
                                  ),
                                  placeholder: (context, url) => const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.person, size: 15, color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: AppTheme.primaryColor,
                                    child: Icon(Icons.person, size: 15, color: Colors.white),
                                  ),
                                )
                                    : const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Icon(Icons.person, size: 15, color: Colors.white),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Account'),
                                      content: Text('Signed in as ${FirebaseAuth.instance.currentUser?.email}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await FirebaseAuth.instance.signOut();
                                            Navigator.pop(context);
                                            setState(() {}); // Refresh UI
                                          },
                                          child: const Text('Sign Out'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                tooltip: 'Profile',
                              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                            ] else ...[
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.login);
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
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
                              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
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
                              ).animate()//animation update
                                  .fadeIn(duration: 800.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutQuad),
                              const SizedBox(height: 16),
                              const Text(
                                'Convert broken English text into standardized, grammatically correct English.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                ),
                              ).animate()
                                  .fadeIn(delay: 200.ms, duration: 800.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutQuad),
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
                                      ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Empty state robot animation
                                          if (!hasOutput && !_isProcessing)
                                            _buildRobotPrompt().animate()
                                                .fadeIn(duration: 800.ms)
                                                .scale(
                                              begin: Offset(0.8, 0.8), // Scale factor for x and y
                                              end: Offset(1.0, 1.0),   // Final scale factor for x and y
                                              duration: Duration(milliseconds: 800),
                                              curve: Curves.elasticOut,
                                            ),

                                          // Output text area
                                          FadeTransition(
                                            opacity: _fadeAnimation,
                                            child: TextArea(
                                              label: 'Standardized Text',
                                              hintText: 'Standardized text will appear here...',
                                              controller: _outputController,
                                              readOnly: true,
                                              maxLines: 10,
                                            ),
                                          ),
                                        ],
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
                                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                                    const SizedBox(height: 24),

                                    // Stack for output and robot
                                    SizedBox(
                                      height: 250, // Fixed height for better layout
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Empty state robot animation
                                          if (!hasOutput && !_isProcessing)
                                            _buildRobotPrompt().animate()
                                                .fadeIn(duration: 800.ms)
                                                .scale(
                                              begin: Offset(1.0, 1.0), // Scale factor for x and y (no change)
                                              end: Offset(1.0, 1.0),   // Scale factor for x and y (no change)
                                              duration: Duration(milliseconds: 800),
                                              curve: Curves.elasticOut,
                                            ),

                                          // Output text area
                                          FadeTransition(
                                            opacity: _fadeAnimation,
                                            child: TextArea(
                                              label: 'Standardized Text',
                                              hintText: 'Standardized text will appear here...',
                                              controller: _outputController,
                                              readOnly: true,
                                              maxLines: 8,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                  ).animate()
                                      .fadeIn(delay: 400.ms, duration: 600.ms)
                                      .slideY(begin: 0.2, end: 0, duration: 600.ms),
                                  const SizedBox(width: 16),
                                  ActionButton(
                                    text: 'Copy Result',
                                    icon: Icons.copy,
                                    onPressed: _copyToClipboard,
                                    isGradient: false,
                                  ).animate()
                                      .fadeIn(delay: 500.ms, duration: 600.ms)
                                      .slideY(begin: 0.2, end: 0, duration: 600.ms),
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
                                      delay: 600,
                                    ),
                                    _buildFeatureCard(
                                      icon: Icons.history,
                                      title: 'Save History',
                                      description: 'Sign up to save your standardization history.',
                                      delay: 700,
                                    ),
                                    _buildFeatureCard(
                                      icon: Icons.devices,
                                      title: 'Cross-Platform',
                                      description: 'Use on web, desktop, iOS, and Android devices.',
                                      delay: 800,
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
                                      delay: 600,
                                    ),
                                    _buildFeatureCard(
                                      icon: Icons.history,
                                      title: 'Save History',
                                      description: 'Sign up to save your standardization history.',
                                      isFullWidth: true,
                                      delay: 700,
                                    ),
                                    _buildFeatureCard(
                                      icon: Icons.devices,
                                      title: 'Cross-Platform',
                                      description: 'Use on web, desktop, iOS, and Android devices.',
                                      isFullWidth: true,
                                      delay: 800,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRobotPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Robot Animation
        SizedBox(
          height: 120,
          width: 120,
          child: Lottie.asset(
            'assets/animations/robot_typing.json', // Add this animation to your assets
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
        const SizedBox(height: 16),
        // Prompt Text
        const Text(
          'Type something in the input box and click "Standardize"',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).fadeIn(duration: 1.seconds)
        .then()
        .moveY(begin: 0, end: -5, duration: 2.seconds, curve: Curves.easeInOut);
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    bool isFullWidth = false,
    required int delay,
  }) {
    Widget card = Container(
      width: isFullWidth ? double.infinity : null,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
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
    ).animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 800.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: delay), duration: 800.ms);

    return Expanded(
      flex: isFullWidth ? 0 : 1,
      child: card,
    );
  }
}