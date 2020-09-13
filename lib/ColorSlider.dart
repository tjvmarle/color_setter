import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ColorSlider extends StatefulWidget {
  final double sliderHeight;
  final Color lowerGradient;
  final Color upperGradient;
  final Function sliderCb;

  ColorSlider(
      this.sliderHeight, this.lowerGradient, this.upperGradient, this.sliderCb);

  @override
  State<StatefulWidget> createState() {
    return _SliderState();
  }
}

class _SliderState extends State<ColorSlider> {
  double sliderValue;

  _SliderState();

  void initState() {
    sliderValue = 0.5;
    super.initState();
  }

  double getVal() {
    return sliderValue;
  }

  //TODO
  //Text field toevoegen met de naam van de slider

  @override
  //Hier wordt de gehele widget gemaakt en teruggeven aan de bovenlaag
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Container(
        constraints: BoxConstraints.expand(
          height: widget.sliderHeight,
        ),
        decoration: new BoxDecoration(
          borderRadius:
              new BorderRadius.all(Radius.circular(widget.sliderHeight / 2)),
          gradient: LinearGradient(
              colors: [widget.lowerGradient, widget.upperGradient]),
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
              widget.sliderCb(value);
            },
          ),
        ),
      ),
    );
  }
}
