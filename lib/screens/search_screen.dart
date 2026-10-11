import 'package:flutter/material.dart';

import '../models/atlas_memory.dart';
import '../services/memory_service.dart';
import 'memory_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MemoryService _memoryService = MemoryService();
  final TextEditingController _searchController =
      TextEditingController();

  late final Stream<List<AtlasMemory>> _memoriesStream;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _memoriesStream = _memoryService.getAllMemories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesQuery(AtlasMemory memory, String query) {
    if (query.isEmpty) return true;

    final searchableFields = <String>[
      memory.title,
      memory.description,
      memory.location,
      ...memory.people,
    ];

    return searchableFields.any(
      (field) => field.toLowerCase().contains(query),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _openMemory(AtlasMemory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryDetailsScreen(memory: memory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _query = value.trim().toLowerCase();
                  });
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search your Atlas...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<AtlasMemory>>(
                stream: _memoriesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildMessage(
                      icon: Icons.cloud_off_outlined,
                      title: 'Could not load memories',
                      subtitle:
                          'Check your connection and try again.',
                    );
                  }

                  final allMemories = snapshot.data ?? [];

                  final results = allMemories
                      .where((memory) => _matchesQuery(memory, _query))
                      .toList()
                    ..sort(
                      (a, b) => b.date.compareTo(a.date),
                    );

                  if (allMemories.isEmpty) {
                    return _buildMessage(
                      icon: Icons.photo_album_outlined,
                      title: 'No memories yet',
                      subtitle:
                          'Create your first memory and it will appear here.',
                    );
                  }

                  if (results.isEmpty) {
                    return _buildMessage(
                      icon: Icons.search_off,
                      title: 'No results found',
                      subtitle:
                          'Try another title, description, place, or person.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final memory = results[index];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          onTap: () => _openMemory(memory),
                          title: Text(
                            memory.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(memory.date),
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                if (memory.location.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color:
                                            colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          memory.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (memory.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    memory.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (memory.people.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'With ${memory.people.join(', ')}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}