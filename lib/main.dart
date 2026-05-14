import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme.dart';
import 'l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const AlQuranApp());
}

class AlQuranApp extends StatefulWidget {
  const AlQuranApp({super.key});

  @override
  State<AlQuranApp> createState() => _AlQuranAppState();
}

class _AlQuranAppState extends State<AlQuranApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
    } else if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const _AudhuScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                state.isDarkMode ? Brightness.light : Brightness.dark,
          ));
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Sanaq Quran',
            debugShowCheckedModeBanner: false,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF111111),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class _AudhuScreen extends StatelessWidget {
  const _AudhuScreen();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final l = L10n(state.locale);

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: AppTheme.bg(isDark),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ScheherazadeNew',
                      fontSize: 30,
                      height: 2.2,
                      color: AppTheme.primary(isDark),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l.tapToContinue,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.tertiary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
