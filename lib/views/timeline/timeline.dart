import 'package:flutter/material.dart';
import 'package:mind_cove/diary/service.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';
import 'package:mind_cove/diary/model.dart';
import 'package:mind_cove/views/_share/diary_card.dart';
import 'package:mind_cove/views/_share/styles/padding.dart';
import 'package:provider/provider.dart';

import '../../providers/views.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> with AutomaticKeepAliveClientMixin<TimelineView> {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();

  List<String> diaryIds = [];
  final List<Diary> diaries = [];
  bool isLoading = true;
  final int itemsPerFetch = 10;
  bool allDataLoaded = false;
  Object? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadDiaryIds();
    _scrollController.addListener(onScrollTimeLine);
  }

  @override
  void dispose() {
    _scrollController.removeListener(onScrollTimeLine);
    _scrollController.dispose();
    super.dispose();
  }

  void addNewDiary(Diary newDiary) {
    diaryIds.insert(0, newDiary.writtenAt.toIso8601String());
    diaries.insert(0, newDiary);
    _animatedListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 500));
  }

  Future<void> loadDiaryIds() async {
    setState(() {
      isLoading = true;
      error = null;
      allDataLoaded = false;
    });

    generateContentPage()
        .then((fetchedIds) async {
          setState(() {
            diaryIds = fetchedIds;
            final initialCount = diaries.length;
            diaries.clear();
            if (_animatedListKey.currentState != null) {
              for (int i = 0; i < initialCount; i++) {
                _animatedListKey.currentState!.removeItem(0, (context, animation) => const SizedBox.shrink());
              }
            }
          });
          await _fetchMoreItems();
        })
        .catchError((e) => error = e)
        .whenComplete(() => setState(() => isLoading = false));
  }

  Future<void> _fetchMoreItems() async {
    if (allDataLoaded) return;

    final int startIndex = diaries.length;
    int endIndex = diaries.length + itemsPerFetch;

    if (endIndex > diaryIds.length) {
      endIndex = diaryIds.length;
      setState(() => allDataLoaded = true);
    }

    final idsToFetch = diaryIds.sublist(startIndex, endIndex);

    Future.wait(idsToFetch.map((id) => loadDiary(id)).toList())
        .then((fetchedItems) {
          final currentLength = diaries.length;
          diaries.addAll(fetchedItems);
          if (_animatedListKey.currentState != null) {
            for (int i = 0; i < fetchedItems.length; i++) {
              _animatedListKey.currentState!.insertItem(currentLength + i);
            }
          } else {
            setState(() {});
          }
        })
        .catchError((e) => error = e);
  }

  Future<void> _handleRefresh() async {
    await loadDiaryIds();
  }

  void onScrollTimeLine() {
    if (isLoading || allDataLoaded) return;
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) return;
    setState(() => isLoading = true);
    _fetchMoreItems().whenComplete(() => setState(() => isLoading = false));
  }

  void _showErrorDetailsDialog(BuildContext context, Object error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.error_detail),
          content: SingleChildScrollView(child: Text(error.toString())),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (error != null) {
      final error = this.error!;
      this.error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.detail,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _showErrorDetailsDialog(context, error);
                },
              ),
              content: Text(AppLocalizations.of(context)!.timeline_load_failed),
            ),
          );
        }
      });
    }

    return _buildBody();
  }

  Widget _buildBody() {
    if (isLoading && diaries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (diaryIds.isEmpty && !isLoading) {
      return _buildEmptyWidget();
    }

    return Padding(padding: pagePadding, child: _buildListView());
  }

  Widget _buildAnimatedItem(BuildContext context, int index, Animation<double> animation) {
    if (index >= diaries.length) {
      if (isLoading) {
        return const Center(
          child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
        );
      }
      if (allDataLoaded) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(AppLocalizations.of(context)!.timeline_reach_end),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final diary = diaries[index];

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)),
        child: DiaryCard(
          diary,
          onDelete: () {
            // TODO: 刪除
          },
          onEdit: () {
            // TODO: 編輯
          },
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.timeline_empty,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ViewsProvider>().changeView(ViewType.write);
                      },
                      child: Text(AppLocalizations.of(context)!.start_writing),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: AnimatedList(
        key: _animatedListKey,
        controller: _scrollController,
        initialItemCount: diaries.length + ((isLoading || allDataLoaded) ? 1 : 0),
        itemBuilder: _buildAnimatedItem,
      ),
    );
  }
}
