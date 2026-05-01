import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ayah.dart';
import '../providers/app_state.dart';

class SelectedAyahsScreen extends StatefulWidget {
  const SelectedAyahsScreen({super.key});

  @override
  State<SelectedAyahsScreen> createState() => _SelectedAyahsScreenState();
}

class _SelectedAyahsScreenState extends State<SelectedAyahsScreen>
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Таңдалған аяттар',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          // Крестик — удалить все и вернуться в мусхаф
          GestureDetector(
            onTap: () {
              context.read<AppState>().clearAllAyahs();
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.close_rounded,
                  size: 18, color: Color(0xFFE53935)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
      ),
      body: Column(
        children: [
          // Верх — список выбранных аятов
          Expanded(
            child: state.selectedAyahs.isEmpty
                ? const Center(
                    child: Text(
                      'Таңдалған аяттар жоқ',
                      style:
                          TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: state.selectedAyahs.length,
                    separatorBuilder: (_, __) =>
                        Container(height: 1, color: const Color(0xFFF5F5F5)),
                    itemBuilder: (ctx, i) {
                      final ayah = state.selectedAyahs[i];
                      return _AyahRow(ayah: ayah);
                    },
                  ),
          ),

          // Низ — счётчик на пол экрана
          _CounterPanel(
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
    );
  }
}

class _AyahRow extends StatelessWidget {
  final Ayah ayah;
  const _AyahRow({required this.ayah});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Красный крестик — удалить этот аят
        GestureDetector(
          onTap: () => context.read<AppState>().removeAyah(ayah),
          child: Container(
            margin: const EdgeInsets.only(top: 14, right: 8),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.close_rounded,
                size: 15, color: Color(0xFFE53935)),
          ),
        ),
        // Аят
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${ayah.surahName} • ${ayah.verseNumber}-аят',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2E7D5E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    ayah.textUthmani,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'ScheherazadeNew',
                      fontSize: 20,
                      height: 1.8,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CounterPanel extends StatelessWidget {
  final int count;
  final int goal;
  final bool goalReached;
  final Animation<double> scaleAnim;
  final VoidCallback onIncrement;
  final VoidCallback onReset;
  final VoidCallback onDismissGoal;

  const _CounterPanel({
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
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.44,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
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
                              Flexible(
                                child: Text(
                                  'Мақсат орындалды! Жалғастыру үшін басыңыз',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('no-goal')),
              ),

              // Счётчик + кнопки
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Сброс слева
                    GestureDetector(
                      onTap: onReset,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.refresh_rounded,
                            color: Color(0xFF9E9E9E), size: 26),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Большая кнопка-счётчик — нажимаешь, цифра меняется
                    Expanded(
                      child: GestureDetector(
                        onTap: onIncrement,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: goalReached
                                ? const Color(0xFF2E7D5E)
                                : const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: (goalReached
                                        ? const Color(0xFF2E7D5E)
                                        : const Color(0xFF1A1A2E))
                                    .withValues(alpha: 0.2),
                                blurRadius: 24,
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
                                    fontSize: 72,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                              if (goal > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'мақсат: $goal',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
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
