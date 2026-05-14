import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../l10n.dart';
import 'home_screen.dart';

class CountInputScreen extends StatefulWidget {
  const CountInputScreen({super.key});

  @override
  State<CountInputScreen> createState() => _CountInputScreenState();
}

class _CountInputScreenState extends State<CountInputScreen> {
  final _controller = TextEditingController();
  final _dividerController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _dividerController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final val = int.tryParse(_controller.text.trim()) ?? 0;
    final div = int.tryParse(_dividerController.text.trim()) ?? 0;
    await context.read<AppState>().setSanaqCount(val, divider: div);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final l = L10n(state.locale);

    return Scaffold(
      backgroundColor: AppTheme.bg(isDark),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: () => context.read<AppState>().toggleDarkMode(),
                  child: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 20,
                    color: AppTheme.tertiary(isDark),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Text(l.enterSanaqCount,
                  style: TextStyle(
                      fontSize: 15, color: AppTheme.secondary(isDark))),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  color: AppTheme.primary(isDark),
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                      color: AppTheme.tertiary(isDark),
                      fontSize: 48,
                      fontWeight: FontWeight.w200),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 32),
              Text(l.divideByPages,
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.tertiary(isDark))),
              const SizedBox(height: 8),
              TextField(
                controller: _dividerController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  color: AppTheme.primary(isDark),
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                      color: AppTheme.tertiary(isDark),
                      fontSize: 32,
                      fontWeight: FontWeight.w200),
                  border: InputBorder.none,
                ),
              ),
              const Spacer(flex: 2),
              GestureDetector(
                onTap: _continue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Text(l.continueBtn,
                          style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.secondary(isDark))),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 11, color: AppTheme.tertiary(isDark)),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(
                          'https://qazaq159.github.io/sanaq-quran-legal/privacy-policy')),
                      child: Text('Privacy Policy',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.tertiary(isDark))),
                    ),
                    Text('  ·  ',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.tertiary(isDark))),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(
                          'https://qazaq159.github.io/sanaq-quran-legal/terms')),
                      child: Text('Terms of Use',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.tertiary(isDark))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
