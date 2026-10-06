import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/atlas_memory.dart';
import '../services/memory_service.dart';
import 'memory_details_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final MemoryService _memoryService = MemoryService();

  final TransformationController _transformationController =
      TransformationController();

  int _selectedTab = 0;

  static const double _pixelsPerDay = 0.9;
  static const double _minScale = 0.25;
  static const double _maxScale = 8.0;

  bool _positionedInitially = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavigation(),

            Expanded(
              child: _selectedTab == 0
                  ? _buildMyTimeline()
                  : _buildSharedTimeline(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Me',
              index: 0,
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Shared',
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required int index,
  }) {
    final selected = _selectedTab == index;

    return GestureDetector(
      onTap: () => _selectTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.black
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMyTimeline() {
    return StreamBuilder<List<AtlasMemory>>(
      stream: _memoryService.getAllMemories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final memories = snapshot.data ?? [];

        if (memories.isEmpty) {
          return _buildEmptyState();
        }

        return _buildTimeline(memories);
      },
    );
  }

  Widget _buildSharedTimeline() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Shared memories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Memories shared with you will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(
    List<AtlasMemory> memories,
  ) {
    final sortedMemories = [...memories]
      ..sort(
        (a, b) => a.date.compareTo(b.date),
      );

    final oldest = sortedMemories.first.date;
    final today = DateTime.now();
    final todayY = _dateToY(today, oldest);

    final totalDays = today.difference(oldest).inDays;

    const double bottomPadding = 100.0;

    final double timelineHeight = math.max(
      1200.0,
      todayY + 970 + bottomPadding,
    ).toDouble();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_positionedInitially && mounted) {
        _positionAtToday(
          timelineHeight: timelineHeight,
          oldest: oldest,
          today: today,
        );
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          // Capture horizontal gestures so they don't reach
          // the MainNavigationScreen's horizontal PageView.
          onHorizontalDragStart: (_) {},
          onHorizontalDragUpdate: (_) {},
          onHorizontalDragEnd: (_) {},
          child: InteractiveViewer(
            transformationController:
                _transformationController,

            minScale: _minScale,
            maxScale: _maxScale,

            panEnabled: true,
            panAxis: PanAxis.vertical,

            scaleEnabled: true,

            boundaryMargin:
                const EdgeInsets.symmetric(
              vertical: 500,
            ),

            constrained: false,
            alignment: Alignment.topCenter,

            child: SizedBox(
              width: width,
              height: timelineHeight,
              child: Stack(
                children: [
                  _buildTimelineLine(
                    width,
                    timelineHeight,
                  ),

                  ..._buildYearMarkers(
                    oldest,
                    today,
                    width,
                  ),

                  ...sortedMemories.map(
                    (memory) {
                      return _buildMemoryNode(
                        memory,
                        oldest,
                        width,
                      );
                    },
                  ),

                  _buildTodayMarker(
                    today,
                    oldest,
                    width,
                  ),

                  _buildFutureText(
                    today,
                    oldest,
                    width,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _positionAtToday({
    required double timelineHeight,
    required DateTime oldest,
    required DateTime today,
  }) {
    if (_positionedInitially) {
      return;
    }

    _positionedInitially = true;

    final screenHeight =
        MediaQuery.of(context).size.height;

    final todayY = _dateToY(
      today,
      oldest,
    );

    const scale = 0.8;

    _transformationController.value =
        Matrix4.identity()
          ..scale(scale)
          ..translate(
            0.0,
            -(todayY -
                (screenHeight / scale) +
                120),
          );
  }

  Widget _buildTimelineLine(
    double width,
    double height,
  ) {
    return Positioned(
      left: width / 2 - 1,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        height: height,
        color: Colors.grey.shade300,
      ),
    );
  }

  List<Widget> _buildYearMarkers(
    DateTime oldest,
    DateTime newest,
    double width,
  ) {
    final widgets = <Widget>[];

    for (int year = oldest.year;
        year <= newest.year;
        year++) {
      final date = DateTime(year, 1, 1);

      if (date.isBefore(oldest)) {
        continue;
      }

      if (date.isAfter(newest)) {
        continue;
      }

      final y = _dateToY(
        date,
        oldest,
      );

      widgets.add(
        Positioned(
          top: y - 18,
          left: 0,
          right: 0,
          child: Row(
            children: [
              Container(
                width: width / 2 - 40,
                height: 1,
                color: Colors.grey.shade200,
              ),
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '$year',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildMemoryNode(
    AtlasMemory memory,
    DateTime oldest,
    double width,
  ) {
    final y = _dateToY(
      memory.date,
      oldest,
    );

    final isLeft = memory.id.hashCode.isEven;

    return Positioned(
      top: y - 42,
      left: isLeft ? 16 : width / 2 + 28,
      width: width / 2 - 44,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemoryDetailsScreen(
                memory: memory,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: isLeft
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isLeft)
              _buildTimelineDot(),

            if (!isLeft)
              const SizedBox(width: 10),

            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(memory.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      memory.title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    if (memory.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        memory.location,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (isLeft)
              const SizedBox(width: 10),

            if (isLeft)
              _buildTimelineDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineDot() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
    );
  }

  Widget _buildTodayMarker(
    DateTime today,
    DateTime oldest,
    double width,
  ) {
    final y = _dateToY(
      today,
      oldest,
    );

    return Positioned(
      top: y - 1,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: const Text(
                'TODAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureText(
    DateTime today,
    DateTime oldest,
    double width,
  ) {
    final todayY = _dateToY(
      today,
      oldest,
    );

    return Positioned(
      top: todayY + 970,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text("Where are you going? We can't predict the future!"),
      ),
    );

  }

  double _dateToY(
    DateTime date,
    DateTime oldest,
  ) {
    final days =
        date.difference(oldest).inDays;

    return 200 +
        (days * _pixelsPerDay);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your timeline is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first memory and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 44,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load your timeline.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}