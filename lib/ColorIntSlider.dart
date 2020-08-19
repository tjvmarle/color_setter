import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ColorSlider extends SingleChildRenderObjectWidget {
  FractionallySizedBox fsb;

  double sliderHeight;
  double sliderValue;
  Color clr;
  Color witIntMinClr;

  Color lowerColor;
  Color upperColor;

  double getSliderValue() {
    return sliderValue;
  }

  void setLowerColor(Color clr) {
    lowerColor = clr;
  }

  void setUpperColor(Color clr) {
    upperColor = clr;
  }

  FractionallySizedBox createFsb() {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Container(
        constraints: BoxConstraints.expand(
          height: sliderHeight,
        ),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(Radius.circular(sliderHeight / 2)),
          gradient: LinearGradient(colors: [lowerColor, upperColor]),
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
            overlayColor: clr.withAlpha(51),
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

  ColorSlider(double sh) {
    sliderHeight = sh;
    fsb = createFsb();
  }

  @override
  RenderFractionallySizedOverflowBox createRenderObject(BuildContext context) {
    return RenderFractionallySizedOverflowBox(
      alignment: null,
      widthFactor: 0.9,
      heightFactor: null,
      textDirection: Directionality.of(context),
    );
  }

  // @override
  // State<StatefulWidget> createState() {
  //   createFsb();
  // }
}
