import 'package:flutter/material.dart';
import '../constants.dart';

class PianoKeyboard extends StatelessWidget {
  final Set<int> highlightedNotes;
  final void Function(int note)? onKeyDown;
  final void Function(int note)? onKeyUp;
  final int startNote;
  final int endNote;
  final bool showLabels;

  const PianoKeyboard({
    super.key,
    this.highlightedNotes = const {},
    this.onKeyDown,
    this.onKeyUp,
    this.startNote = kMidiC3,
    this.endNote = kMidiC5,
    this.showLabels = true,
  });

  // ===== 几何 =====
  static const _blackKeyWidthRatio = 0.6;
  static const _blackKeyHeightRatio = 0.6;
  static const _whiteKeyRadius = 6.0;
  static const _blackKeyRadius = 4.0;
  static const _whiteKeyStrokeWidth = 0.5;

  // ===== 颜色 =====
  static const _whiteKeyColor = Color(0xFFEEEEEE);
  static const _whiteKeyBorderColor = Color(0xFFAAAAAA);
  static const _blackKeyColor = Color(0xFF1A1A1A);
  static const _highlightColor = Color(0xFF5C6BC0);
  static const _highlightAlpha = 0.6;

  // ===== 标签 =====
  static const _labelHighlightColor = Color(0xFFFFFFFF);
  static const _labelDefaultColor = Color(0xFF555555);
  static const _labelFontSize = 11.0;
  static const _labelBottomPadding = 10.0;

  static const _noteLabels = <int, String>{
    36: 'C2', 38: 'D2', 40: 'E2', 41: 'F2', 43: 'G2', 45: 'A2', 47: 'B2',
    48: 'C3', 50: 'D3', 52: 'E3', 53: 'F3', 55: 'G3', 57: 'A3', 59: 'B3',
    60: 'C4', 62: 'D4', 64: 'E4', 65: 'F4', 67: 'G4', 69: 'A4', 71: 'B4',
    72: 'C5', 74: 'D5', 76: 'E5', 77: 'F5', 79: 'G5', 81: 'A5', 83: 'B5',
    84: 'C6',
  };

  static bool _isWhite(int note) {
    final n = note % 12;
    return n == 0 || n == 2 || n == 4 || n == 5 || n == 7 || n == 9 || n == 11;
  }

  /// 计算覆盖 [lowNote..highNote] 这一段音的合理可视音域。
  /// 上下各预留 [pad] 半音，且至少展示 [minSpan] 半音宽，全部 clamp 到 [kPianoMinNote..kPianoMaxNote]。
  static (int, int) rangeForRange(
    int lowNote,
    int highNote, {
    int pad = 4,
    int minSpan = 25,
  }) {
    final start = (lowNote - pad).clamp(kPianoMinNote, kPianoMaxNote - minSpan);
    final end = (highNote + pad).clamp(start + minSpan, kPianoMaxNote);
    return (start, end);
  }

  /// 围绕单个 [centerNote] 上下扩展的便捷形式。
  static (int, int) rangeAround(int centerNote, {int pad = 12, int minSpan = 24}) =>
      rangeForRange(centerNote, centerNote, pad: pad, minSpan: minSpan);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _KeyboardLayout.compute(
          startNote: startNote,
          endNote: endNote,
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );

        return GestureDetector(
          onTapDown: (details) {
            final note = layout.hitTest(
              details.localPosition.dx,
              details.localPosition.dy,
            );
            if (note != null) onKeyDown?.call(note);
          },
          onTapUp: (details) {
            final note = layout.hitTest(
              details.localPosition.dx,
              details.localPosition.dy,
            );
            if (note != null) onKeyUp?.call(note);
          },
          onTapCancel: () {},
          child: CustomPaint(
            size: Size(constraints.maxWidth, layout.whiteKeyHeight),
            painter: _PianoPainter(
              layout: layout,
              highlightedNotes: highlightedNotes,
              showLabels: showLabels,
            ),
          ),
        );
      },
    );
  }
}

/// 钢琴几何布局：把白键/黑键的尺寸和命中测试集中在一起，
/// 避免在 painter / 手势处理器之间反复传递一长串参数。
class _KeyboardLayout {
  final List<int> whiteNotes;
  final List<int?> blackNotes;
  final double whiteKeyWidth;
  final double blackKeyWidth;
  final double whiteKeyHeight;
  final double blackKeyHeight;

  _KeyboardLayout._({
    required this.whiteNotes,
    required this.blackNotes,
    required this.whiteKeyWidth,
    required this.blackKeyWidth,
    required this.whiteKeyHeight,
    required this.blackKeyHeight,
  });

  factory _KeyboardLayout.compute({
    required int startNote,
    required int endNote,
    required Size size,
  }) {
    final whiteNotes = <int>[
      for (var i = startNote; i <= endNote; i++)
        if (PianoKeyboard._isWhite(i)) i,
    ];
    final blackNotes = <int?>[
      for (final w in whiteNotes)
        if (w + 1 <= endNote && !PianoKeyboard._isWhite(w + 1)) w + 1 else null,
    ];
    final whiteKeyWidth = size.width / whiteNotes.length;
    return _KeyboardLayout._(
      whiteNotes: whiteNotes,
      blackNotes: blackNotes,
      whiteKeyWidth: whiteKeyWidth,
      blackKeyWidth: whiteKeyWidth * PianoKeyboard._blackKeyWidthRatio,
      whiteKeyHeight: size.height,
      blackKeyHeight: size.height * PianoKeyboard._blackKeyHeightRatio,
    );
  }

  /// 将屏幕坐标 (x, y) 映射到具体的 MIDI note。
  ///
  /// 黑键骑在两个白键之间，左半边压在左白键上、右半边压在右白键上。
  /// 因此当点击落在某白键的列上方且 y < blackKeyHeight 时，需要同时检查
  /// 它右邻黑键 (blackNotes[whiteIndex]) 与左邻黑键 (blackNotes[whiteIndex-1])。
  int? hitTest(double x, double y) {
    final whiteIndex = (x / whiteKeyWidth).floor();
    if (whiteIndex < 0 || whiteIndex >= whiteNotes.length) return null;

    if (y < blackKeyHeight) {
      final rightBlack = blackNotes[whiteIndex];
      if (rightBlack != null && _hitsBlackKeyAt(x, (whiteIndex + 1) * whiteKeyWidth)) {
        return rightBlack;
      }
      if (whiteIndex > 0) {
        final leftBlack = blackNotes[whiteIndex - 1];
        if (leftBlack != null && _hitsBlackKeyAt(x, whiteIndex * whiteKeyWidth)) {
          return leftBlack;
        }
      }
    }

    return whiteNotes[whiteIndex];
  }

  bool _hitsBlackKeyAt(double x, double centerX) {
    final half = blackKeyWidth / 2;
    return x >= centerX - half && x <= centerX + half;
  }
}

class _PianoPainter extends CustomPainter {
  final _KeyboardLayout layout;
  final Set<int> highlightedNotes;
  final bool showLabels;

  _PianoPainter({
    required this.layout,
    required this.highlightedNotes,
    required this.showLabels,
  });

  static final _whitePaint = Paint()
    ..color = PianoKeyboard._whiteKeyColor
    ..style = PaintingStyle.fill;

  static final _whiteStroke = Paint()
    ..color = PianoKeyboard._whiteKeyBorderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = PianoKeyboard._whiteKeyStrokeWidth;

  static final _blackPaint = Paint()
    ..color = PianoKeyboard._blackKeyColor
    ..style = PaintingStyle.fill;

  static final _highlightPaint = Paint()
    ..color = PianoKeyboard._highlightColor
        .withValues(alpha: PianoKeyboard._highlightAlpha)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    _drawWhiteKeys(canvas);
    _drawBlackKeys(canvas);
    if (showLabels) _drawLabels(canvas);
  }

  void _drawWhiteKeys(Canvas canvas) {
    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, layout.whiteKeyWidth, layout.whiteKeyHeight),
      bottomLeft: const Radius.circular(PianoKeyboard._whiteKeyRadius),
      bottomRight: const Radius.circular(PianoKeyboard._whiteKeyRadius),
    );
    for (var i = 0; i < layout.whiteNotes.length; i++) {
      canvas.save();
      canvas.translate(i * layout.whiteKeyWidth, 0);
      canvas.drawRRect(rrect, _whitePaint);
      canvas.drawRRect(rrect, _whiteStroke);
      if (highlightedNotes.contains(layout.whiteNotes[i])) {
        canvas.drawRRect(rrect, _highlightPaint);
      }
      canvas.restore();
    }
  }

  void _drawBlackKeys(Canvas canvas) {
    for (var i = 0; i < layout.blackNotes.length; i++) {
      final note = layout.blackNotes[i];
      if (note == null) continue;
      final x = (i + 1) * layout.whiteKeyWidth - layout.blackKeyWidth / 2;
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, 0, layout.blackKeyWidth, layout.blackKeyHeight),
        bottomLeft: const Radius.circular(PianoKeyboard._blackKeyRadius),
        bottomRight: const Radius.circular(PianoKeyboard._blackKeyRadius),
      );
      canvas.drawRRect(rrect, _blackPaint);
      if (highlightedNotes.contains(note)) {
        canvas.drawRRect(rrect, _highlightPaint);
      }
    }
  }

  void _drawLabels(Canvas canvas) {
    for (var i = 0; i < layout.whiteNotes.length; i++) {
      final note = layout.whiteNotes[i];
      final label = PianoKeyboard._noteLabels[note];
      if (label == null) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: highlightedNotes.contains(note)
                ? PianoKeyboard._labelHighlightColor
                : PianoKeyboard._labelDefaultColor,
            fontSize: PianoKeyboard._labelFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: layout.whiteKeyWidth);
      tp.paint(
        canvas,
        Offset(
          i * layout.whiteKeyWidth + (layout.whiteKeyWidth - tp.width) / 2,
          layout.whiteKeyHeight - tp.height - PianoKeyboard._labelBottomPadding,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PianoPainter oldDelegate) {
    return highlightedNotes != oldDelegate.highlightedNotes ||
        layout.whiteNotes != oldDelegate.layout.whiteNotes;
  }
}
