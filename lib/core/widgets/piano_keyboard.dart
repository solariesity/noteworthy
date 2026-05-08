import 'package:flutter/material.dart';

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
    this.startNote = 48,
    this.endNote = 72,
    this.showLabels = true,
  });

  static const _whiteNotes = [
    48, 50, 52, 53, 55, 57, 59,
    60, 62, 64, 65, 67, 69, 71, 72,
  ];

  static const _blackNotes = [
    49, 51, null, 54, 56, 58, null,
    61, 63, null, 66, 68, 70, null,
  ];

  static const _noteLabels = <int, String>{
    48: 'C3', 50: 'D3', 52: 'E3', 53: 'F3', 55: 'G3', 57: 'A3', 59: 'B3',
    60: 'C4', 62: 'D4', 64: 'E4', 65: 'F4', 67: 'G4', 69: 'A4', 71: 'B4',
    72: 'C5',
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardWidth = constraints.maxWidth;
        final whiteKeyCount = _whiteNotes.length;
        final whiteKeyWidth = keyboardWidth / whiteKeyCount;
        final blackKeyWidth = whiteKeyWidth * 0.6;
        final whiteKeyHeight = constraints.maxHeight;
        final blackKeyHeight = whiteKeyHeight * 0.6;

        return GestureDetector(
          onTapDown: (details) {
            final note = _hitTest(
              details.localPosition.dx,
              details.localPosition.dy,
              whiteKeyWidth,
              blackKeyWidth,
              whiteKeyHeight,
              blackKeyHeight,
            );
            if (note != null) {
              onKeyDown?.call(note);
            }
          },
          onTapUp: (details) {
            final note = _hitTest(
              details.localPosition.dx,
              details.localPosition.dy,
              whiteKeyWidth,
              blackKeyWidth,
              whiteKeyHeight,
              blackKeyHeight,
            );
            if (note != null) {
              onKeyUp?.call(note);
            }
          },
          onTapCancel: () {},
          child: CustomPaint(
            size: Size(keyboardWidth, whiteKeyHeight),
            painter: _PianoPainter(
              highlightedNotes: highlightedNotes,
              whiteKeyWidth: whiteKeyWidth,
              blackKeyWidth: blackKeyWidth,
              whiteKeyHeight: whiteKeyHeight,
              blackKeyHeight: blackKeyHeight,
              showLabels: showLabels,
            ),
          ),
        );
      },
    );
  }

  int? _hitTest(
    double x,
    double y,
    double whiteKeyWidth,
    double blackKeyWidth,
    double whiteKeyHeight,
    double blackKeyHeight,
  ) {
    final whiteIndex = (x / whiteKeyWidth).floor();
    if (whiteIndex < 0 || whiteIndex >= _whiteNotes.length) return null;

    // Check black keys first (they sit on top)
    if (y < blackKeyHeight) {
      final blackNote = _blackNotes[whiteIndex];
      if (blackNote != null) {
        final leftEdge = (whiteIndex + 1) * whiteKeyWidth - blackKeyWidth / 2;
        final rightEdge = leftEdge + blackKeyWidth;
        if (x >= leftEdge && x <= rightEdge) {
          return blackNote;
        }
      }
    }

    return _whiteNotes[whiteIndex];
  }
}

class _PianoPainter extends CustomPainter {
  final Set<int> highlightedNotes;
  final double whiteKeyWidth;
  final double blackKeyWidth;
  final double whiteKeyHeight;
  final double blackKeyHeight;
  final bool showLabels;

  _PianoPainter({
    required this.highlightedNotes,
    required this.whiteKeyWidth,
    required this.blackKeyWidth,
    required this.whiteKeyHeight,
    required this.blackKeyHeight,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.fill;

    final whiteStroke = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final blackPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = const Color(0xFF5C6BC0).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final whiteRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, whiteKeyWidth, whiteKeyHeight),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );

    // Draw white keys
    for (var i = 0; i < PianoKeyboard._whiteNotes.length; i++) {
      final note = PianoKeyboard._whiteNotes[i];
      final x = i * whiteKeyWidth;
      canvas.save();
      canvas.translate(x, 0);
      canvas.drawRRect(whiteRRect, whitePaint);
      canvas.drawRRect(whiteRRect, whiteStroke);
      if (highlightedNotes.contains(note)) {
        canvas.drawRRect(whiteRRect, highlightPaint);
      }
      canvas.restore();
    }

    // Draw black keys
    for (var i = 0; i < PianoKeyboard._blackNotes.length; i++) {
      final note = PianoKeyboard._blackNotes[i];
      if (note == null) continue;
      final x = (i + 1) * whiteKeyWidth - blackKeyWidth / 2;
      final blackRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, 0, blackKeyWidth, blackKeyHeight),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(blackRRect, blackPaint);
      if (highlightedNotes.contains(note)) {
        canvas.drawRRect(blackRRect, highlightPaint);
      }
    }

    // Draw labels on white keys
    if (showLabels) {
      for (var i = 0; i < PianoKeyboard._whiteNotes.length; i++) {
        final note = PianoKeyboard._whiteNotes[i];
        final label = PianoKeyboard._noteLabels[note];
        if (label == null) continue;
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: highlightedNotes.contains(note)
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF888888),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: whiteKeyWidth);
        tp.paint(
          canvas,
          Offset(
            i * whiteKeyWidth + (whiteKeyWidth - tp.width) / 2,
            whiteKeyHeight - tp.height - 10,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PianoPainter oldDelegate) {
    return highlightedNotes != oldDelegate.highlightedNotes;
  }
}
