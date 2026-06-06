import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../config/app_text_styles.dart';

class SignaturePad extends StatefulWidget {
  final String? initialSignature;
  final Function(String) onSave;

  const SignaturePad({
    super.key,
    this.initialSignature,
    required this.onSave,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSignature != null && widget.initialSignature!.isNotEmpty) {
      try {
        final List<dynamic> decodedStrokes = jsonDecode(widget.initialSignature!);
        _strokes = decodedStrokes.map((stroke) {
          final List<dynamic> points = stroke;
          return points.map((point) {
            final List<dynamic> coords = point;
            return Offset(coords[0].toDouble(), coords[1].toDouble());
          }).toList();
        }).toList();
      } catch (e) {
        _strokes = [];
      }
    }
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
  }

  void _save() {
    if (_strokes.isEmpty && _currentStroke.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw your signature first')),
      );
      return;
    }

    final allStrokes = List<List<Offset>>.from(_strokes);
    if (_currentStroke.isNotEmpty) {
      allStrokes.add(_currentStroke);
    }

    final serialized = jsonEncode(
      allStrokes.map((stroke) {
        return stroke.map((p) => [p.dx, p.dy]).toList();
      }).toList(),
    );

    widget.onSave(serialized);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Signature'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                    child: GestureDetector(
                      onPanStart: (details) {
                        final RenderBox renderBox = context.findRenderObject() as RenderBox;
                        final localPosition = renderBox.globalToLocal(details.globalPosition);
                        // Offset by app bar height
                        final adjustedPosition = Offset(
                          localPosition.dx - AppConstants.spacing16,
                          localPosition.dy - kToolbarHeight - AppConstants.spacing16,
                        );
                        setState(() {
                          _currentStroke = [adjustedPosition];
                        });
                      },
                      onPanUpdate: (details) {
                        final RenderBox renderBox = context.findRenderObject() as RenderBox;
                        final localPosition = renderBox.globalToLocal(details.globalPosition);
                        final adjustedPosition = Offset(
                          localPosition.dx - AppConstants.spacing16,
                          localPosition.dy - kToolbarHeight - AppConstants.spacing16,
                        );
                        setState(() {
                          _currentStroke.add(adjustedPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          if (_currentStroke.isNotEmpty) {
                            _strokes.add(List<Offset>.from(_currentStroke));
                            _currentStroke.clear();
                          }
                        });
                      },
                      child: CustomPaint(
                        painter: SignaturePainter(
                          strokes: _strokes,
                          currentStroke: _currentStroke,
                          strokeColor: theme.colorScheme.onSurface,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;

  SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    if (currentStroke.isNotEmpty) {
      final path = Path()..moveTo(currentStroke[0].dx, currentStroke[0].dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SignaturePreview extends StatelessWidget {
  final String serializedStrokes;
  final Color strokeColor;

  const SignaturePreview({
    super.key,
    required this.serializedStrokes,
    this.strokeColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    List<List<Offset>> strokes = [];
    if (serializedStrokes.isNotEmpty) {
      try {
        final List<dynamic> decodedStrokes = jsonDecode(serializedStrokes);
        strokes = decodedStrokes.map((stroke) {
          final List<dynamic> points = stroke;
          return points.map((point) {
            final List<dynamic> coords = point;
            return Offset(coords[0].toDouble(), coords[1].toDouble());
          }).toList();
        }).toList();
      } catch (e) {
        strokes = [];
      }
    }

    if (strokes.isEmpty) {
      return const Center(child: Text('No Signature Saved', style: TextStyle(color: Colors.grey)));
    }

    return CustomPaint(
      painter: SignaturePainter(
        strokes: strokes,
        currentStroke: const [],
        strokeColor: strokeColor,
      ),
      size: Size.infinite,
    );
  }
}
