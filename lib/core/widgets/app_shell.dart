import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/browse_games/presentation/pages/browse_games_page.dart';
import '../../features/browse_games/presentation/providers/browse_games_provider.dart';
import '../../features/home/presentation/pages/home_dashboard_page.dart';
import '../../features/browse_games/presentation/pages/my_lists_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reviews/presentation/pages/reviews_page.dart';
import '../../features/reviews/presentation/providers/reviews_provider.dart';
import '../constants/app_colors.dart';
import 'animated_game_background.dart';

/// Responsive main shell: sidebar on desktop, bottom navigation on mobile.
class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key, this.initialIndex = 0});

  static const String routeName = '/home';

  final int initialIndex;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  late int _index;

  static const _destinations = <_NavDestination>[
    _NavDestination('Home', Icons.home_rounded, Icons.home_outlined),
    _NavDestination('Browse', Icons.explore_rounded, Icons.explore_outlined),
    _NavDestination('My Lists', Icons.bookmark_rounded, Icons.bookmark_border_rounded),
    _NavDestination('Reviews', Icons.rate_review_rounded, Icons.rate_review_outlined),
    _NavDestination('Profile', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _destinations.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  void _ensureLoaded() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    context.read<BrowseGamesProvider>().load(user.id);
    context.read<ReviewsProvider>().load(user.id);
  }

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeDashboardPage(embedded: true, onNavigate: _select),
      const BrowseGamesPage(embedded: true),
      const MyListsPage(embedded: true),
      const ReviewsPage(embedded: true),
      const ProfilePage(embedded: true),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final content = AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0.02, 0.01),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_index),
            child: pages[_index],
          ),
        );

        if (wide) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AnimatedGameBackground(
              child: Row(
                children: [
                  _DesktopSidebar(
                    index: _index,
                    destinations: _destinations,
                    onSelect: _select,
                  ),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedGameBackground(child: SafeArea(child: content)),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.96),
              border: Border(
                top: BorderSide(color: AppColors.cyan.withValues(alpha: 0.18)),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 72,
              destinations: [
                for (var i = 0; i < _destinations.length; i++)
                  NavigationDestination(
                    icon: Icon(_destinations[i].icon),
                    selectedIcon: Icon(_destinations[i].selectedIcon),
                    label: _destinations[i].label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.index,
    required this.destinations,
    required this.onSelect,
  });

  final int index;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.cyan, AppColors.blue],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.35),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sports_esports_rounded,
                      color: Colors.black, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'GameVault',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Your Games. Your Legacy.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: destinations.length,
              itemBuilder: (context, i) {
                final d = destinations[i];
                final selected = i == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    onTap: () => onSelect(i),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: selected
                            ? AppColors.cyan.withValues(alpha: 0.14)
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? AppColors.cyan.withValues(alpha: 0.35)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected ? d.selectedIcon : d.icon,
                            color: selected
                                ? AppColors.cyan
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              d.label,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (selected)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.cyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.12)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: AppColors.cyan, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cinematic gaming launcher',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.label, this.selectedIcon, this.icon);
  final String label;
  final IconData selectedIcon;
  final IconData icon;
}