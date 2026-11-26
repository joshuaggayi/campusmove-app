import 'package:flutter/material.dart';

import '../db.dart';
import '../session.dart';
import 'results_screen.dart';

/// Functionality 2 (part 1): choose where you are going.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _places = [];
  String? _from;
  String? _to;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final places = await AppDatabase.instance.getPlaces();
    if (!mounted) return;
    setState(() => _places = places);
  }

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
    });
  }

  void _search() {
    if (_from == null || _to == null) {
      setState(() => _error = 'Choose where you are leaving from and going to.');
      return;
    }
    if (_from == _to) {
      setState(() => _error = 'Start and destination must be different.');
      return;
    }
    setState(() => _error = null);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResultsScreen(origin: _from!, destination: _to!),
    ));
  }

  Widget _placeDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      // The key makes the field show the new value after a swap.
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      items: _places
          .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = session.user!.name.split(' ').first;
    return Scaffold(
      appBar: AppBar(title: const Text('CampusMove')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hi $firstName, where to today?',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _placeDropdown(
                    label: 'From',
                    icon: Icons.trip_origin,
                    value: _from,
                    onChanged: (v) => setState(() => _from = v),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton.filledTonal(
                      tooltip: 'Swap',
                      onPressed: _swap,
                      icon: const Icon(Icons.swap_vert),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _placeDropdown(
                    label: 'To',
                    icon: Icons.place_outlined,
                    value: _to,
                    onChanged: (v) => setState(() => _to = v),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Search routes'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Compare taxi and boda boda options by fare and travel time, '
            'follow the stages and landmarks, and read what other students '
            'say about safety and crowding.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
