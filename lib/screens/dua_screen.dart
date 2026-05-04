import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../l10n.dart';
import 'home_screen.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final l = L10n(state.locale);

    return Scaffold(
      backgroundColor: AppTheme.bg(isDark),
      body: GestureDetector(
        onTap: _continue,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                const Spacer(),
                Text(
                  'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 28,
                    height: 2.0,
                    color: AppTheme.primary(isDark),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.audhuTranslation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondary(isDark),
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Text(
                    l.tapToContinue,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.tertiary(isDark)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
