import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../diary/service.dart';
import '../../diary/model.dart';
import '../../providers/diary_index.dart';
import '../_share/diary_card.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> with AutomaticKeepAliveClientMixin<CalendarView> {
  final List<DateTime?> _values = [];
  List<Diary> _selectedDiaries = const [];
  bool _isLoadingDiaries = false;
  Object? _diaryLoadError;
  int _selectionRequestId = 0;

  @override
  void initState() {
    super.initState();
    context.read<DiaryIndexProvider>().getDiaryEntries().catchError((error, stackTrace) {
      debugPrint('Failed to load diary index for calendar: $error');
      return <DiaryIndexEntry>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final diaryIndicatorColor = Theme.of(context).colorScheme.primary;
    final diaryIndexProvider = context.watch<DiaryIndexProvider>();
    final diaryDates = diaryIndexProvider.diaryEntries.map((entry) => entry.writtenAt).toSet();

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              dayBuilder: ({required date, textStyle, decoration, isSelected, isDisabled, isToday}) {
                final hasDiary = diaryDates.any(
                  (diaryDate) =>
                      diaryDate.year == date.year && diaryDate.month == date.month && diaryDate.day == date.day,
                );
                if (!hasDiary) return null;

                return Container(
                  decoration: decoration,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text('${date.day}', style: textStyle),
                      Positioned(
                        bottom: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: diaryIndicatorColor, shape: BoxShape.circle),
                          child: const SizedBox(width: 4, height: 4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            value: _values,
            onValueChanged: (dates) {
              if (dates.isNotEmpty) {
                _loadDiariesForDate(dates.first);
              }
            },
          ),
          Expanded(child: _buildSelectedDiaries()),
        ],
      ),
    );
  }

  Future<void> _loadDiariesForDate(DateTime date) async {
    final requestId = ++_selectionRequestId;
    setState(() {
      _values
        ..clear()
        ..add(date);
      _selectedDiaries = const [];
      _isLoadingDiaries = true;
      _diaryLoadError = null;
    });

    final diaryEntries = context.read<DiaryIndexProvider>().diaryEntries.where((entry) {
      final diaryDate = entry.writtenAt;
      return diaryDate.year == date.year && diaryDate.month == date.month && diaryDate.day == date.day;
    });

    try {
      final diaries = await Future.wait(diaryEntries.map((entry) => loadDiary(entry.id)));
      if (!mounted || requestId != _selectionRequestId) return;
      setState(() => _selectedDiaries = diaries);
    } catch (error) {
      if (!mounted || requestId != _selectionRequestId) return;
      setState(() => _diaryLoadError = error);
    } finally {
      if (mounted && requestId == _selectionRequestId) {
        setState(() => _isLoadingDiaries = false);
      }
    }
  }

  Widget _buildSelectedDiaries() {
    final diaryIndexProvider = context.watch<DiaryIndexProvider>();
    final selectedDiaries = _selectedDiaries.where((diary) {
      return diaryIndexProvider.containsDiary(diary.writtenAt);
    }).toList();

    if (_isLoadingDiaries) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_diaryLoadError != null) {
      return Center(child: Text(_diaryLoadError.toString()));
    }
    if (_values.isEmpty || selectedDiaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: selectedDiaries.length,
      itemBuilder: (context, index) {
        final diary = selectedDiaries[index];
        return DiaryCard(diary);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
