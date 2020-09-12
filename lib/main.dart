// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:./flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:http/http.dart';
import 'package:wakelock/wakelock.dart';
import 'package:color_setter/ColorIntSlider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color setter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Zet verlichting'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color clr;
  double clrInt;
  double witInt;
  double totalInt;

  Color witIntMinClr;

  double sliderHeight;

  @override
  void initState() {
    clr = Colors.orange; //Ring kleur
    clrInt = 1; //Algehele intensiteit
    witInt = 0.5; //Wit intensiteit - 50%
    totalInt = 50; //Algehele intensiteit
    witIntMinClr = clr;

    sliderHeight = 36;
    Wakelock.enable();
    super.initState();
  }

  void setColor(Color kleur) {
    setState(() {
      clr = kleur;
    });
  }

  void setColorInt(Color kleur) {
    setState(() {
      clr = kleur;
    });
  }

  void setWitInt(Color kleur) {
    setState(() {
      clr = kleur;
    });
  }

  //Lower end is gekozen kleur bij hoge verzadiging en zwart bij lage.
  Color getLowerWitInt() {
    double red = clr.red * clrInt;
    double green = clr.green * clrInt;
    double blue = clr.blue * clrInt;
    return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
  }

  //Percentage dat kleur maximaal mag hebben t.o.v. wit bij gemengde kleuren.
  double fract = 0.40;

  //Aandeel wit voor de kleur van de bovengrens behoudt een minimale waarde,
  //anders is niet goed zichtbaar dat wit een aandeel heeft bij hoge
  //kleurverzadigingen.
  Color getUpperWitInt() {
    double fractInt = fract * clrInt;
    double red = 255 * (1 - fractInt) + fractInt * clr.red;
    double green = 255 * (1 - fractInt) + fractInt * clr.green;
    double blue = 255 * (1 - fractInt) + fractInt * clr.blue;
    return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
  }

  Color getUpperAlgeheel() {
    //Normaliseer de intensiteiten voor kleur en wit.
    double fractClrInt = 1 - (1 - fract) * witInt;
    double fractClrWit = 1 - fract * clrInt;

    double red = clr.red * fractClrInt * clrInt + 255 * fractClrWit * witInt;
    double green =
        clr.green * fractClrInt * clrInt + 255 * fractClrWit * witInt;
    double blue = clr.blue * fractClrInt * clrInt + 255 * fractClrWit * witInt;

    return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
  }

//To do
//Wat extra berekeningen toevoegen om de juiste wit-varianten te krijgen bij het
// sliden en deze te kunnen gebruiken bij invullen van de andere sliders.
//Sliders:
// * Kleurintensiteit
// * Hoeveelheid wit licht
// * Algehele intensiteit
// * Presets: Warm wit, helder wit --> buttons? Iig eentje voor warm wit

  Color lowerGradient1;
  Color upperGradient1;
  double sliderHeight1;
  double sliderValue1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleColorPicker(
              initialColor: Colors.orange,
              onChanged: setColor,
              strokeWidth: 5,
            ),
            ColorSlider(Colors.purple, Colors.pink), //????
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Container(
                constraints: BoxConstraints.expand(
                  height: sliderHeight,
                ),
                decoration: new BoxDecoration(
                  borderRadius:
                      new BorderRadius.all(Radius.circular(sliderHeight / 2)),
                  gradient: LinearGradient(
                      colors: [Colors.grey[500].withOpacity(0), clr]),
                  // color: clr,
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
                    value: clrInt,
                    onChanged: (value) {
                      setState(() {
                        clrInt = value;
                        witIntMinClr = Color.fromRGBO(
                            (clr.red * clrInt).round(),
                            (clr.green * clrInt).round(),
                            (clr.blue * clrInt).round(),
                            1);
                      });
                    },
                  ),
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Container(
                constraints: BoxConstraints.expand(
                  height: sliderHeight,
                ),
                decoration: new BoxDecoration(
                  borderRadius:
                      new BorderRadius.all(Radius.circular(sliderHeight / 2)),
                  gradient: LinearGradient(
                      colors: [getLowerWitInt(), getUpperWitInt()]),
                  // color: clr,
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
                    label: "Wit licht",
                    min: 0,
                    max: 1,
                    value: witInt,
                    onChanged: (value) {
                      setState(() {
                        witInt = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Container(
                constraints: BoxConstraints.expand(
                  height: sliderHeight,
                ),
                decoration: new BoxDecoration(
                  borderRadius:
                      new BorderRadius.all(Radius.circular(sliderHeight / 2)),
                  gradient: LinearGradient(
                      colors: [Colors.grey[400], getUpperAlgeheel()]),
                  color: clr,
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
                    label: "Algehele intensiteit",
                    min: 0,
                    max: 100,
                    value: totalInt,
                    onChanged: (value) {
                      setState(() {
                        totalInt = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            ColorSlider(
              sliderHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                  label: Text('Uit'),
                  onPressed: () {
                    setUit();
                  },
                  icon: Icon(Icons.lightbulb_outline),
                  backgroundColor: Colors.black54,
                ),
                FloatingActionButton.extended(
                  label: Text('Aan'),
                  onPressed: () {
                    setStrip(clr, witInt, totalInt.round());
                  },
                  icon: Icon(Icons.lightbulb_outline),
                  backgroundColor: Colors.deepOrange.withAlpha(255),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void setUit() {
    post(
      'http://192.168.1.111/setlighting?targetStrip=both&r=0&g=0&b=0&w=10&intensity=0', //Blijkbaar blijven de zijkanten branden als alle kleurwaardes 0 zijn, dus w is nu 10.
      headers: <String, String>{},
    );
  }

  Future<Response> setStrip(
      Color rgb, double witIntensiteit, int totaleIntensiteit) {
    try {
      int witWaarde = (255 * witIntensiteit).round().toInt();

      return post(
        'http://192.168.1.111/setlighting?targetStrip=both&r=${rgb.red}&g=${rgb.green}&b=${rgb.blue}&w=${witWaarde}&intensity=${totaleIntensiteit}',
        headers: <String, String>{},
      );
    } catch (e) {
      return Future.value();
    }
  }
}
