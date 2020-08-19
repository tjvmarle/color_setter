import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ColorSlider extends StatefulWidget {
  Color lowerGradient;
  Color upperGradient;

  ColorSlider(Color lowerColor, Color upperColor) {
    lowerGradient = lowerColor;
    upperGradient = upperColor;
  };

  @override
  State<StatefulWidget> createState() {
    return _SliderState(lowerGradient, upperGradient);
  }
}

class _SliderState extends State<ColorSlider> {
  Color lowerGradient;
  Color upperGradient;
  double sliderHeight;
  double sliderValue;

  _SliderState(Color lower, Color upper) {
    lowerGradient = lower;
    upperGradient = upper;
  }

  void initState() {
    sliderHeight = 36;
    sliderValue = 0.5;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Container(
        constraints: BoxConstraints.expand(
          height: sliderHeight,
        ),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(Radius.circular(sliderHeight / 2)),
          gradient: LinearGradient(colors: [lowerGradient, upperGradient]),
          border: Border.all(
            width: 2,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[400],
            trackHeight: 4.0,
            thumbColor: Colors.grey[700],
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
          ),
          child: Slider(
            label: "Kleur intensiteit",
            min: 0.0,
            max: 1.0,
            value: sliderValue,
            onChanged: (value) {
              sliderValue = value;
            },
          ),
        ),
      ),
    );
  }
}
