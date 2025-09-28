import 'package:flutter/material.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/charts_service.dart';
import '../../chart_creation/providers/chart_creation_provider.dart';
import '../../auth/providers/auth_provider.dart';

final chartsServiceProvider = Provider<ChartsService>((ref) => ChartsService());

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(chartsServiceProvider).listMine();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ref.read(chartsServiceProvider).listMine();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushNamed('/profile'),
          icon: const Icon(Icons.person_outline),
          tooltip: t.profile,
        ),
        title: Text(t.charts),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: t.settings,
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: t.logout,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(child: Text(t.noChartsYet));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = items[i] as Map<String, dynamic>;
                return ListTile(
                  title: Text(e['name']?.toString() ?? '—'),
                  subtitle: Text(e['birthDatetime']?.toString() ?? ''),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(chartCreationProvider.notifier).reset();
          Navigator.of(context).pushNamed('/chart-creation');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
