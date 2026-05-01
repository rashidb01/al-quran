import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ayah.dart';
import '../providers/app_state.dart';

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
    final goal = state.sanaqCount;
    final count = state.counter;
    final goalReached = goal > 0 && count >= goal && !state.goalShown;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
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
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Санақ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Container(height: 1, color: const Color(0xFFF0F0F0)),

            // Аят — сверху, занимает всё место
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
                          color: const Color(0xFFF0F7F4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.ayah.surahName} • ${widget.ayah.verseNumber}-аят',
                          style: const TextStyle(
                            fontFamily: 'ScheherazadeNew',
                            fontSize: 14,
                            color: Color(0xFF2E7D5E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.ayah.textUthmani,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'ScheherazadeNew',
                          fontSize: 28,
                          height: 2.0,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Счётчик — снизу зафиксирован
            _CounterBottom(
              count: count,
              goal: goal,
              goalReached: goalReached,
              scaleAnim: _scaleAnim,
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
  final VoidCallback onIncrement;
  final VoidCallback onReset;
  final VoidCallback onDismissGoal;

  const _CounterBottom({
    required this.count,
    required this.goal,
    required this.goalReached,
    required this.scaleAnim,
    required this.onIncrement,
    required this.onReset,
    required this.onDismissGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        boxShadow: [
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
          // Баннер "Мақсат орындалды"
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
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Мақсат орындалды! Жалғастыру үшін басыңыз',
                            style: TextStyle(
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
              // Сброс слева
              GestureDetector(
                onTap: onReset,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.refresh_rounded,
                      color: Color(0xFF9E9E9E), size: 24),
                ),
              ),
              const SizedBox(width: 16),

              // Большая кнопка-счётчик по центру — нажимаешь и число меняется
              Expanded(
                child: GestureDetector(
                  onTap: onIncrement,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 80,
                    decoration: BoxDecoration(
                      color: goalReached
                          ? const Color(0xFF2E7D5E)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: (goalReached
                                  ? const Color(0xFF2E7D5E)
                                  : const Color(0xFF1A1A2E))
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
                            'мақсат: $goal',
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
