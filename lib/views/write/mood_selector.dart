import 'package:flutter/material.dart';
import 'package:mind_cove/diary/model.dart' show Mood;
import 'package:mind_cove/views/_share/mood_renderer.dart';

class MoodSelector extends StatefulWidget {
  final MoodEditingController emotionController;

  const MoodSelector(this.emotionController, {super.key});

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class MoodEditingController extends ChangeNotifier {
  Mood? _value;

  MoodEditingController({Mood? initialEmotion}) : _value = initialEmotion;

  String get text {
    return _value?.name ?? '';
  }

  Mood? get value => _value;

  void setEmotion(String emotionName) {
    final newEmotion = Mood.values.firstWhere(
      (e) => e.name.toLowerCase() == emotionName.toLowerCase(),
      orElse: () => Mood.neutral,
    );
    if (newEmotion != _value) {
      _value = newEmotion;
      notifyListeners();
    }
  }

  void clear() {
    _value = null;
    notifyListeners();
  }

  bool equals(Mood? other) {
    return _value?.name == other?.name;
  }
}

class _MoodSelectorState extends State<MoodSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: Mood.values.map((emotion) {
          // 選擇中情緒時，顯示彩色按鈕
          if (widget.emotionController.equals(emotion)) {
            return Expanded(child: _buildEmotionButton(emotion));
          }

          // 非選擇中情緒時，顯示灰階按鈕
          return Expanded(
            child: ColorFiltered(colorFilter: greyscale, child: _buildEmotionButton(emotion)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmotionButton(Mood emotion) {
    return TextButton(
      onPressed: () {
        if (widget.emotionController.equals(emotion)) {
          widget.emotionController.clear();
        } else {
          widget.emotionController.setEmotion(emotion.name);
        }
        setState(() {});
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MoodRenderer(mood: emotion, size: 24),
          Text(emotion.name, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

const ColorFilter greyscale = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);
