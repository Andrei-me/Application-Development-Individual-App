import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../browse_games/presentation/providers/browse_games_provider.dart';
import '../../../reviews/presentation/providers/reviews_provider.dart';

/// Gaming profile dashboard for the logged-in user.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.embedded = false});

  static const String routeName = '/profile';
  final bool embedded;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    context.read<BrowseGamesProvider>().load(user.id);
    context.read<ReviewsProvider>().load(user.id);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Future<void> _showEditProfileDialog() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user.username);
    final bioController = TextEditingController(text: user.bio ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isLoading = context.watch<AuthProvider>().isLoading;
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final username = value?.trim() ?? '';
                      if (username.isEmpty) return 'Please enter a username.';
                      if (username.length < 3) return 'Username must be at least 3 characters.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(
                      labelText: 'About me (optional)',
                      hintText: 'Tell others about your gaming interests',
                      alignLabelWithHint: true,
                    ),
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email cannot be changed from this screen.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      final ok = await context.read<AuthProvider>().updateProfile(
                            username: usernameController.text,
                            bio: bioController.text,
                          );
                      if (!mounted) return;
                      if (ok) {
                        if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                      } else {
                        final message = context.read<AuthProvider>().errorMessage ??
                            'Could not update profile.';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    );

    usernameController.dispose();
    bioController.dispose();

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final browseProvider = context.watch<BrowseGamesProvider>();
    final reviewsProvider = context.watch<ReviewsProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      const empty = Center(child: Text('Please log in to view your profile.'));
      if (widget.embedded) return empty;
      return const Scaffold(body: empty);
    }

    final savedGames = browseProvider.allGames.where((g) => browseProvider.isInMyList(g.id)).toList();
    final myListCount = savedGames.length;
    final reviews = reviewsProvider.reviews;
    final totalReviews = reviews.length;
    final avg = totalReviews == 0
        ? null
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews;
    final gameById = {for (final g in browseProvider.allGames) g.id: g};
    final recentReviewed = reviews
        .take(5)
        .map((r) => gameById[r.gameId]?.title)
        .whereType<String>()
        .toList();
    final recentActivity = <String>[
      if (reviews.isNotEmpty) 'Last review: ${reviews.first.rating}/10',
      if (savedGames.isNotEmpty)
        'Tracking ${savedGames.length} saved game${savedGames.length == 1 ? '' : 's'}',
      'Catalog available: ${browseProvider.allGames.length} games',
    ];

    final content = RefreshIndicator(
      color: AppColors.cyan,
      onRefresh: () async => _loadData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, widget.embedded ? 14 : 16, 16, 24),
        children: [
          if (widget.embedded)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your gaming identity and stats',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHero(
                    initials: _initials(user.username),
                    username: user.username,
                    email: user.email,
                    bio: user.bio,
                    onEdit: _showEditProfileDialog,
                  ),
                  const SizedBox(height: 16),
                  _StatsPanel(
                    myListCount: myListCount,
                    totalReviews: totalReviews,
                    averageRating: avg,
                    loading: (browseProvider.isLoading && browseProvider.allGames.isEmpty) ||
                        (reviewsProvider.isLoading && reviews.isEmpty),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, c) {
                      final wide = c.maxWidth >= 760;
                      final left = _InfoPanel(
                        title: 'Recent Activity',
                        icon: Icons.history_rounded,
                        children: [
                          for (final line in recentActivity) _BulletLine(text: line),
                          if (recentReviewed.isEmpty)
                            const _BulletLine(text: 'Write reviews to build your activity timeline.')
                          else ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Recently reviewed games',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            for (final t in recentReviewed) _BulletLine(text: t),
                          ],
                        ],
                      );
                      final right = _InfoPanel(
                        title: 'Account',
                        icon: Icons.manage_accounts_rounded,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showEditProfileDialog,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit username & profile info'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: authProvider.isLoading ? null : _logout,
                            icon: const Icon(Icons.logout_rounded),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(color: AppColors.error.withValues(alpha: 0.6)),
                            ),
                            label: const Text('Log out'),
                          ),
                        ],
                      );
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: left),
                            const SizedBox(width: 14),
                            Expanded(child: right),
                          ],
                        );
                      }
                      return Column(children: [left, const SizedBox(height: 14), right]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) return content;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: authProvider.isLoading ? null : _showEditProfileDialog,
          ),
        ],
      ),
      body: content,
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.initials,
    required this.username,
    required this.email,
    required this.bio,
    required this.onEdit,
  });

  final String initials;
  final String username;
  final String email;
  final String? bio;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppColors.surface.withValues(alpha: 0.95), AppColors.secondary.withValues(alpha: 0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: AppColors.blue.withValues(alpha: 0.16), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.blue]),
              boxShadow: [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.35), blurRadius: 18)],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      color: AppColors.cyan,
                      tooltip: 'Edit profile',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(email, style: const TextStyle(color: AppColors.textSecondary))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  (bio != null && bio!.trim().isNotEmpty)
                      ? bio!.trim()
                      : 'Build your GameVault legacy. Add games, write reviews, and curate your collection.',
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.myListCount,
    required this.totalReviews,
    required this.averageRating,
    required this.loading,
  });

  final int myListCount;
  final int totalReviews;
  final double? averageRating;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gaming Statistics',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 700;
              final tiles = [
                _StatTile(
                  icon: Icons.bookmark_rounded,
                  label: 'Games in My Lists',
                  value: '$myListCount',
                  loading: loading,
                ),
                _StatTile(
                  icon: Icons.rate_review_rounded,
                  label: 'Reviews written',
                  value: '$totalReviews',
                  loading: loading,
                ),
                _StatTile(
                  icon: Icons.star_rounded,
                  label: 'Average review rating',
                  value: averageRating == null ? 'N/A' : '${averageRating!.toStringAsFixed(1)} / 10',
                  loading: loading,
                ),
              ];
              if (wide) {
                return Row(
                  children: [
                    for (int i = 0; i < tiles.length; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i == tiles.length - 1 ? 0 : 10),
                          child: tiles[i],
                        ),
                      ),
                  ],
                );
              }
              return Column(
                children: [
                  for (int i = 0; i < tiles.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == tiles.length - 1 ? 0 : 10),
                      child: tiles[i],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.loading,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cyan),
          const SizedBox(height: 10),
          if (loading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3)),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.cyan, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, height: 1.35))),
        ],
      ),
    );
  }
}
