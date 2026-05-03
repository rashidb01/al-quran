import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/ayah.dart';
import '../theme.dart';
import 'count_input_screen.dart';
import 'quran_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
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

  void _openQuran() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const QuranViewerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final hasAyahs = state.selectedAyahs.isNotEmpty;

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -300) _openQuran();
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg(isDark),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    // Dark mode toggle — top left
                    GestureDetector(
                      onTap: () => context.read<AppState>().toggleDarkMode(),
                      child: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        size: 20,
                        color: AppTheme.tertiary(isDark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Al Quran',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary(isDark),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CountInputScreen())),
                      child: Icon(Icons.tune_rounded,
                          size: 20, color: AppTheme.tertiary(isDark)),
                    ),
                  ],
                ),
              ),

              // Counter tap area
              Expanded(
                flex: hasAyahs ? 2 : 3,
                child: GestureDetector(
                  onTap: _increment,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: state.goalReached ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: () => context.read<AppState>().dismissGoal(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Text('✓ Мақсат орындалды',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.secondary(isDark))),
                          ),
                        ),
                      ),
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Text(
                          '${state.counter}',
                          style: TextStyle(
                            fontSize: hasAyahs ? 80 : 120,
                            fontWeight: FontWeight.w200,
                            color: AppTheme.primary(isDark),
                            height: 1,
                          ),
                        ),
                      ),
                      if (state.sanaqCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('/ ${state.sanaqCount}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.tertiary(isDark))),
                        ),
                    ],
                  ),
                ),
              ),

              // Reset
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 0, 16),
                child: GestureDetector(
                  onTap: () => context.read<AppState>().resetCounter(),
                  child: Icon(Icons.refresh_rounded,
                      size: 18, color: AppTheme.tertiary(isDark)),
                ),
              ),

              // Ayahs list
              if (hasAyahs) ...[
                Container(height: 1, color: AppTheme.divider(isDark)),
                Expanded(
                  flex: 3,
                  child: Builder(builder: (ctx) {
                    final sorted = [...state.selectedAyahs]
                      ..sort((a, b) => a.id.compareTo(b.id));
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) =>
                          Container(height: 1, color: AppTheme.divider(isDark)),
                      itemBuilder: (ctx, i) =>
                          _AyahRow(ayah: sorted[i], isDark: isDark),
                    );
                  }),
                ),
              ],

              // Open Quran
              Container(height: 1, color: AppTheme.divider(isDark)),
              GestureDetector(
                onTap: _openQuran,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Row(
                    children: [
                      Text('Құранды оқу',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AyahRow extends StatelessWidget {
  final Ayah ayah;
  final bool isDark;
  const _AyahRow({required this.ayah, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${ayah.surahName} · ${ayah.verseNumber}',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.tertiary(isDark)),
                ),
                const SizedBox(height: 4),
                Text(
                  ayah.textUthmani,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 20,
                    height: 1.8,
                    color: AppTheme.primary(isDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => context.read<AppState>().removeAyah(ayah),
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text('×',
                  style: TextStyle(
                      fontSize: 22, color: AppTheme.tertiary(isDark))),
            ),
          ),
        ],
      ),
    );
  }
}
