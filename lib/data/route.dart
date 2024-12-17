import 'package:flutter/material.dart';

class PanelInfo {
  static const TextStyle leftTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle rightTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  static Widget buildPanelContent({
    required String leftText,
    required double distance,
    required double duration,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Text
        Text(
          leftText,
          style: leftTextStyle,
        ),
        // Right Texts
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(distance / 1000).toStringAsFixed(2)} km',
              style: rightTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              '${(duration / 60).toStringAsFixed(2)} min',
              style: rightTextStyle,
            ),
          ],
        ),
      ],
    );
  }
}
