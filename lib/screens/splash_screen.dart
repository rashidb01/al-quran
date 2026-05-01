import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'count_input_screen.dart';
import 'counter_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Ждём пока AppState.init() завершится, потом навигируем
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    // Небольшая задержка чтобы init() успел загрузить SharedPreferences
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final state = context.read<AppState>();
    if (state.isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CountInputScreen()),
      );
    } else if (state.activeAyah != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => CounterScreen(ayah: state.activeAyah!)),
      );
    } else {
      // Был запуск раньше, но аят не выбран — идём на мусхаф
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CountInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Al Quran',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
