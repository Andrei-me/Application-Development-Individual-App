import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/browse_games/data/datasources/games_local_data_source.dart';
import 'features/browse_games/data/repositories/games_repository_impl.dart';
import 'features/browse_games/presentation/pages/browse_games_page.dart';
import 'features/browse_games/presentation/providers/browse_games_provider.dart';
import 'features/reviews/data/datasources/reviews_local_data_source.dart';
import 'features/reviews/data/repositories/reviews_repository_impl.dart';
import 'features/reviews/presentation/pages/reviews_page.dart';
import 'features/reviews/presentation/providers/reviews_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent local storage used for authentication/session data.
  final prefs = await SharedPreferences.getInstance();
  final authLocalDataSource = AuthLocalDataSource(prefs);
  final authRepository = AuthRepositoryImpl(authLocalDataSource);

  // Browse Games feature uses a local sample catalog and stores "My List"
  // selections in SharedPreferences (no paid API or API key required).
  final gamesLocalDataSource = GamesLocalDataSource(prefs);
  final gamesRepository = GamesRepositoryImpl(gamesLocalDataSource);

  // Reviews are stored locally per user in SharedPreferences (no DB/API).
  final reviewsLocalDataSource = ReviewsLocalDataSource(prefs);
  final reviewsRepository = ReviewsRepositoryImpl(reviewsLocalDataSource);

  runApp(
    GameListApp(
      authRepository: authRepository,
      gamesRepository: gamesRepository,
      reviewsRepository: reviewsRepository,
    ),
  );
}

class GameListApp extends StatelessWidget {
  const GameListApp({
    super.key,
    required this.authRepository,
    required this.gamesRepository,
    required this.reviewsRepository,
  });

  final AuthRepositoryImpl authRepository;
  final GamesRepositoryImpl gamesRepository;
  final ReviewsRepositoryImpl reviewsRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider<BrowseGamesProvider>(
          create: (_) => BrowseGamesProvider(gamesRepository),
        ),
        ChangeNotifierProvider<ReviewsProvider>(
          create: (_) => ReviewsProvider(reviewsRepository),
        ),
      ],
      child: MaterialApp(
        title: 'GameVault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: SplashPage.routeName,
        routes: {
          SplashPage.routeName: (_) => const SplashPage(),
          LoginPage.routeName: (_) => const LoginPage(),
          RegisterPage.routeName: (_) => const RegisterPage(),
          AppShellPage.routeName: (_) => const AppShellPage(),
          // Deep-link / direct routes kept for compatibility; pages support embedded mode.
          BrowseGamesPage.routeName: (_) => const BrowseGamesPage(),
          ReviewsPage.routeName: (_) => const ReviewsPage(),
        },
      ),
    );
  }
}

