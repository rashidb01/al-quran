import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import 'home_screen.dart';

class CountInputScreen extends StatefulWidget {
  const CountInputScreen({super.key});

  @override
  State<CountInputScreen> createState() => _CountInputScreenState();
}

class _CountInputScreenState extends State<CountInputScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final val = int.tryParse(_controller.text.trim()) ?? 0;
    await context.read<AppState>().setSanaqCount(val);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDarkMode;

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
              Text('Санақ санын енгізіңіз',
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
              const Spacer(flex: 2),
              GestureDetector(
                onTap: _continue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Text('Жалғастыру',
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
            ],
          ),
        ),
      ),
    );
  }
}
