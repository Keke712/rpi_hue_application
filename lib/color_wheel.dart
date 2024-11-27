import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

class ColorWheel extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorWheel({
    Key? key,
    required this.initialColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _ColorWheelState createState() => _ColorWheelState();
}

class _ColorWheelState extends State<ColorWheel> {
  late Color _currentColor;
  Color _tempColor = Colors.white;
  static ui.Image? _colorWheelImage;  // Changed to static

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    if (_colorWheelImage == null) {  // Only generate if not already existing
      _generateColorWheelImage();
    }
  }

  void _onColorChanged(Color color) {
    setState(() {
      _tempColor = color;
    });
  }

  void _onColorSelected() {
    setState(() {
      _currentColor = _tempColor;
    });
    widget.onColorChanged(_currentColor);
  }

  void _updateColor(Offset localOffset, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(radius, radius);
    double distance = (localOffset - center).distance;

    if (distance <= radius) {
      double angle = (localOffset - center).direction;
      double hue = (angle / (2 * pi)) * 360;
      if (hue < 0) hue += 360; // Ensure hue is positive
      double saturation = distance / radius;
      _onColorChanged(HSVColor.fromAHSV(1, hue, saturation, 1).toColor());
    }
  }

  Future<void> _generateColorWheelImage() async {
    if (_colorWheelImage != null) return;  // Skip if already generated
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(300, 300)));
    double radius = 150;
    Offset center = Offset(radius, radius);

    for (double angle = 0; angle < 360; angle += 1) {
      for (double distance = 0; distance <= radius; distance += 1) {
        double hue = angle;
        double saturation = distance / radius;
        Paint paint = Paint()
          ..color = HSVColor.fromAHSV(1, hue, saturation, 1).toColor()
          ..strokeWidth = 1;
        double radian = (angle / 180) * pi;
        double x = center.dx + distance * cos(radian);
        double y = center.dy + distance * sin(radian);
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }

    final picture = recorder.endRecording();
    _colorWheelImage = await picture.toImage(300, 300);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.globalPosition);
        _updateColor(localOffset, box.size);
      },
      onPanEnd: (_) {
        _onColorSelected();
      },
      onTapDown: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.globalPosition);
        _updateColor(localOffset, box.size);
      },
      onTapUp: (_) {
        _onColorSelected();
      },
      child: CustomPaint(
        size: Size(300, 300),
        painter: ColorWheelPainter(_colorWheelImage),
      ),
    );
  }
}

class ColorWheelPainter extends CustomPainter {
  final ui.Image? colorWheelImage;

  ColorWheelPainter(this.colorWheelImage);

  @override
  void paint(Canvas canvas, Size size) {
    if (colorWheelImage != null) {
      canvas.drawImage(colorWheelImage!, Offset.zero, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}