import 'package:flutter/material.dart';
import 'package:./flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:http/http.dart';
import 'package:wakelock/wakelock.dart';
import 'package:color_setter/ColorSlider.dart';

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
        primarySwatch: Colors.deepOrange,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Enlightment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color clrFromPicker;

  final double sliderHeight = 36;

  double clrIntensity;
  double whiteIntensity;
  double finalClrIntensity;

  @override
  void initState() {
    clrFromPicker = Colors.deepOrange; //Ring kleur

    clrIntensity = 0.75;
    whiteIntensity = 0.5;
    finalClrIntensity = 1;

    Wakelock.enable();
    super.initState();
  }

  void setColor(Color kleur) {
    setState(() {
      clrFromPicker = kleur;
    });
  }

  Color getLowerWitInt(double intensity) {
    double red = clrFromPicker.red * intensity;
    double green = clrFromPicker.green * intensity;
    double blue = clrFromPicker.blue * intensity;
    return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
  }

  //Percentage dat kleur maximaal mag hebben t.o.v. wit bij gemengde kleuren.
  double fract = 0.40;

  //Aandeel wit voor de kleur van de bovengrens behoudt een minimale waarde,
  //anders is niet goed zichtbaar dat wit een aandeel heeft bij hoge
  //kleurverzadigingen.
  Color getUpperWitInt(double intensity) {
    double fractInt = fract * intensity;
    double red = 255 * (1 - fractInt) + fractInt * clrFromPicker.red;
    double green = 255 * (1 - fractInt) + fractInt * clrFromPicker.green;
    double blue = 255 * (1 - fractInt) + fractInt * clrFromPicker.blue;
    return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
  }

  Color getUpperAlgeheelInt(double clrInt, double witInt) {
    //Normaliseer de intensiteiten voor kleur en wit.
    double fractClrInt = 1 - (1 - fract) * witInt;
    double fractClrWit = 1 - fract * clrInt;

    double red =
        clrFromPicker.red * fractClrInt * clrInt + 255 * fractClrWit * witInt;
    double green =
        clrFromPicker.green * fractClrInt * clrInt + 255 * fractClrWit * witInt;
    double blue =
        clrFromPicker.blue * fractClrInt * clrInt + 255 * fractClrWit * witInt;

    return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
  }

  ColorSlider sliderInt; //(sliderHeight, Colors.grey, Colors.orange);

//To do
// * Presets: Warm wit, helder wit --> buttons? Iig eentje voor warm wit
// * Build triggeren bij gebruik sliders
// * Ondergrens 2e slider wordt zwart bij 0% clrInt, mag echter kleurloos/transparant worden

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleColorPicker(
            initialColor: Colors.orange,
            onChanged: setColor,
            strokeWidth: 5,
          ),

          //Color intensity slider
          ColorSlider(sliderHeight, clrFromPicker.withOpacity(0), clrFromPicker,
              clrIntensity, "Kleur intensiteit", (double sliderVal) {
            setState(() {
              clrIntensity = sliderVal;
            });
          }),

          //White intensity slider
          ColorSlider(
              sliderHeight,
              getLowerWitInt(clrIntensity),
              getUpperWitInt(clrIntensity),
              whiteIntensity,
              "Wit intensiteit", (double sliderVal) {
            setState(() {
              whiteIntensity = sliderVal;
            });
          }),

          //Overall color intensity
          ColorSlider(
              sliderHeight,
              Colors.grey,
              getUpperAlgeheelInt(clrIntensity, whiteIntensity),
              finalClrIntensity,
              "Algehele intensiteit", (double sliderVal) {
            setState(() {
              finalClrIntensity = sliderVal;
            });
          }),

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
                  setStrip(clrFromPicker, clrIntensity, whiteIntensity,
                      finalClrIntensity);
                },
                icon: Icon(Icons.lightbulb_outline),
                backgroundColor: Colors.deepOrange.withAlpha(255),
              ),
            ],
          )
        ],
      ),
    );
    // );
  }

  void setUit() {
    post(
      //TODO: Maak aparte pagina om ip adres in te stellen
      'http://192.168.1.103/setlighting?targetStrip=both&r=0&g=0&b=0&w=10&intensity=0', //Blijkbaar blijven de zijkanten branden als alle kleurwaardes 0 zijn, dus w is nu 10.
      headers: <String, String>{},
    );
  }

  Future<Response> setStrip(Color rgb, double kleurIntensiteit,
      double witIntensiteit, double totaleIntensiteit) {
    try {
      //totaleIntensiteit wordt op de microcontroller gecorrigeerd, dus hier niet nodig.
      int witWaarde = (255 * witIntensiteit).round().toInt();
      int red = (rgb.red * kleurIntensiteit).toInt();
      int green = (rgb.green * kleurIntensiteit).toInt();
      int blue = (rgb.blue * kleurIntensiteit).toInt();

      Color stripColor =
          Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
      int stripIntensiteit = (totaleIntensiteit * 100).toInt();

      return post(
        'http://192.168.1.103/setlighting?targetStrip=both&r=${stripColor.red}&g=${stripColor.green}&b=${stripColor.blue}&w=$witWaarde&intensity=$stripIntensiteit',
        headers: <String, String>{},
      );
    } catch (e) {
      return Future.value();
    }
  }
}
