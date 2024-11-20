import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    Key? key,
    required this.initialColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class ColorPickerWheelPainter extends CustomPainter {
  final Color color;

  ColorPickerWheelPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Gradient gradient = SweepGradient(
      colors: [
        Colors.red,
        Colors.yellow,
        Colors.green,
        Colors.cyan,
        Colors.blue,
        Colors.purple,
        Colors.red,
      ],
    );
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawOval(rect, paint);

    final Paint selectorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(size.center(Offset.zero), 10.0, selectorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: ColorPickerWheel(
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
              });
              widget.onColorChanged(color);
            },
            currentColor: _currentColor,
          ),
        ),
      ],
    );
  }
}

class ColorPickerWheel extends StatefulWidget {
  final ValueChanged<Color> onColorChanged;
  final Color currentColor;

  const ColorPickerWheel({
    Key? key,
    required this.onColorChanged,
    required this.currentColor,
  }) : super(key: key);

  @override
  _ColorPickerWheelState createState() => _ColorPickerWheelState();
}

class _ColorPickerWheelState extends State<ColorPickerWheel> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        final double hue = (localPosition.dx / renderBox.size.width * 360) % 360;
        final double saturation = localPosition.dy / renderBox.size.height;
        final Color color = HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
        // _AssertionError ('package:flutter/src/painting/colors.dart': Failed assertion: line 80 pos 14: 'saturation <= 1.0': is not true.)
        setState(() {
          _currentColor = color;
        });
        widget.onColorChanged(color);
      },
      child: CustomPaint(
        painter: ColorPickerWheelPainter(_currentColor),
        size: const Size(300, 300),
      ),
    );
  }
}