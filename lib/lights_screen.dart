import 'package:flutter/material.dart';

class LightsScreen extends StatelessWidget {
  final bool isLightOn;
  final double brightness;
  final Color color;
  final ValueChanged<bool> onToggle;

  const LightsScreen({
    Key? key,
    required this.isLightOn,
    required this.brightness,
    required this.color,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hue color lamp',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => onToggle(!isLightOn),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: isLightOn ? Colors.yellow.withOpacity(0.3) : Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: isLightOn ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    size: 50,
                    color: isLightOn ? Colors.yellow[600] : Colors.grey[600],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLightOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: isLightOn ? Colors.black : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Brightness: ${brightness.round()}%',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
