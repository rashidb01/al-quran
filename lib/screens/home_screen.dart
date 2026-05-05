import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/ayah.dart';
import '../theme.dart';
import '../l10n.dart';
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

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final l = L10n(state.locale);
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
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  children: [
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
                      'Sanaq Quran',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary(isDark),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showSettings,
                      child: Icon(Icons.tune_rounded,
                          size: 20, color: AppTheme.tertiary(isDark)),
                    ),
                  ],
                ),
              ),

              // Ayahs list
              if (hasAyahs) ...[
                Container(height: 1, color: AppTheme.divider(isDark)),
                Expanded(
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
              ] else
                const Spacer(),

              // Counter button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: GestureDetector(
                  onTap: _increment,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.divider(isDark), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        AnimatedOpacity(
                          opacity: state.goalReached ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () => context.read<AppState>().dismissGoal(),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(l.goalReached,
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
                              fontSize: 96,
                              fontWeight: FontWeight.w200,
                              color: AppTheme.primary(isDark),
                              height: 1,
                            ),
                          ),
                        ),
                        if (state.sanaqCount > 0)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: (state.counter / state.sanaqCount)
                                          .clamp(0.0, 1.0),
                                      minHeight: 3,
                                      backgroundColor:
                                          AppTheme.divider(isDark),
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              AppTheme.secondary(isDark)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${state.sanaqCount}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.tertiary(isDark)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Reset + Open Quran
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.read<AppState>().resetCounter(),
                      child: Icon(Icons.refresh_rounded,
                          size: 18, color: AppTheme.tertiary(isDark)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _openQuran,
                      child: Row(
                        children: [
                          Text(l.openQuran,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.secondary(isDark))),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 11, color: AppTheme.tertiary(isDark)),
                        ],
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

// ─── Settings bottom sheet ────────────────────────────────────────────────────
class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final l = L10n(state.locale);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sanaq count
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CountInputScreen()));
            },
            child: Row(
              children: [
                Text(l.sanaqGoal,
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.tertiary(isDark))),
                const Spacer(),
                Text(
                  '${state.sanaqCount}',
                  style: TextStyle(
                      fontSize: 15, color: AppTheme.secondary(isDark)),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppTheme.tertiary(isDark)),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Container(height: 1, color: AppTheme.divider(isDark)),
          const SizedBox(height: 24),

          // Language
          Text(l.language,
              style: TextStyle(
                  fontSize: 13, color: AppTheme.tertiary(isDark))),
          const SizedBox(height: 12),
          Row(
            children: AppLocale.values.map((loc) {
              final selected = state.locale == loc;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => context.read<AppState>().setLocale(loc),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary(isDark)
                            : AppTheme.divider(isDark),
                        width: selected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      L10n(loc).label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? AppTheme.primary(isDark)
                            : AppTheme.secondary(isDark),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Font size
          Row(
            children: [
              Text(l.textSize,
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.tertiary(isDark))),
              const Spacer(),
              Text(
                state.quranFontSize.round().toString(),
                style: TextStyle(
                    fontSize: 13, color: AppTheme.secondary(isDark)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppTheme.primary(isDark),
              inactiveTrackColor: AppTheme.divider(isDark),
              thumbColor: AppTheme.primary(isDark),
              overlayColor: AppTheme.primary(isDark).withValues(alpha: 0.1),
            ),
            child: Slider(
              value: state.quranFontSize,
              min: 18,
              max: 60,
              divisions: 42,
              onChanged: (v) =>
                  context.read<AppState>().setQuranFontSize(v),
            ),
          ),
          // Preview
          Center(
            child: Text(
              'بِسْمِ اللَّهِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: state.quranFontSize,
                color: AppTheme.primary(isDark),
              ),
            ),
          ),
        ],
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
    final fontSize = context.watch<AppState>().quranFontSize;
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
                    fontSize: fontSize,
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
