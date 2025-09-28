import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/charts_service.dart';
import '../../auth/providers/auth_provider.dart';

final chartsServiceProvider = Provider<ChartsService>((ref) => ChartsService());

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  late Future<List<dynamic>> _future;
  final _name = TextEditingController();
  final _birth = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
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
            return const Center(child: Text('No charts yet'));
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
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Create Chart'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                  TextField(controller: _birth, decoration: const InputDecoration(labelText: 'Birth (ISO8601)')),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(chartsServiceProvider).create(
                          name: _name.text,
                          birthDatetime: _birth.text,
                        );
                    if (!mounted) return;
                    Navigator.pop(context);
                    _name.clear();
                    _birth.clear();
                    await _reload();
                  },
                  child: const Text('Create'),
                )
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

