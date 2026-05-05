import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ayah.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../l10n.dart';

class CounterScreen extends StatefulWidget {
  final Ayah ayah;
  const CounterScreen({super.key, required this.ayah});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _increment() async {
    await context.read<AppState>().increment();
    _animCtrl.forward().then((_) => _animCtrl.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final l = L10n(state.locale);
    final goal = state.sanaqCount;
    final count = state.counter;
    final goalReached = state.goalReached;

    return Scaffold(
      backgroundColor: AppTheme.bg(isDark),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.surface(isDark),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppTheme.primary(isDark)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l.sanaqGoal,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Container(height: 1, color: AppTheme.divider(isDark)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surface(isDark),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.ayah.surahName} • ${widget.ayah.verseNumber}',
                          style: TextStyle(
                            fontFamily: 'ScheherazadeNew',
                            fontSize: 14,
                            color: AppTheme.secondary(isDark),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.ayah.textUthmani,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'ScheherazadeNew',
                          fontSize: 28,
                          height: 2.0,
                          color: AppTheme.primary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _CounterBottom(
              count: count,
              goal: goal,
              goalReached: goalReached,
              scaleAnim: _scaleAnim,
              isDark: isDark,
              goalLabel: l.goalReached,
              goalSubLabel: l.sanaqGoal,
              onIncrement: _increment,
              onReset: () => context.read<AppState>().resetCounter(),
              onDismissGoal: () => context.read<AppState>().dismissGoal(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBottom extends StatelessWidget {
  final int count;
  final int goal;
  final bool goalReached;
  final Animation<double> scaleAnim;
  final bool isDark;
  final String goalLabel;
  final String goalSubLabel;
  final VoidCallback onIncrement;
  final VoidCallback onReset;
  final VoidCallback onDismissGoal;

  const _CounterBottom({
    required this.count,
    required this.goal,
    required this.goalReached,
    required this.scaleAnim,
    required this.isDark,
    required this.goalLabel,
    required this.goalSubLabel,
    required this.onIncrement,
    required this.onReset,
    required this.onDismissGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg(isDark),
        border: Border(top: BorderSide(color: AppTheme.divider(isDark))),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: goalReached
                ? GestureDetector(
                    key: const ValueKey('goal'),
                    onTap: onDismissGoal,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D5E),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            goalLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('no-goal')),
          ),

          Row(
            children: [
              GestureDetector(
                onTap: onReset,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.surface(isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.refresh_rounded,
                      color: AppTheme.tertiary(isDark), size: 24),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: GestureDetector(
                  onTap: onIncrement,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 80,
                    decoration: BoxDecoration(
                      color: goalReached
                          ? const Color(0xFF2E7D5E)
                          : AppTheme.primary(isDark),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: (goalReached
                                  ? const Color(0xFF2E7D5E)
                                  : AppTheme.primary(isDark))
                              .withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: scaleAnim,
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                        if (goal > 0)
                          Text(
                            '$goalSubLabel: $goal',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
