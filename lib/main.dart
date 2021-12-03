import 'dart:io';
import 'package:flutter/material.dart';
import 'noob_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = NoobTheme.light();
    return MaterialApp(
      title: 'Calorie Needs Calculator',
      theme: theme,
      home: const Home(title: 'Figure out your calorie intake here'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool gender = false;
  double? age;
  double sliderHeight = 170.0;
  double? weightChanged;
  Object? sportSelection;
  int? calorieBase;
  int? calorieActivity;

  Map activities = {0: 'Low', 1: 'Moderate', 2: 'Active'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate your calorific requirements here'),
      ),
      body: body(),
    );
  }


  Widget body() {
    return ListView(padding: const EdgeInsets.all(15.0), children: [
      const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'Fill in all the fields to get your daily calorie requirement',
            style: TextStyle(fontSize: 17.0),
          ),
        ),
      ),
      Card(
        elevation: 10.0,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Female'),
                genderSwitch(),
                const Text('Male'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextButton(
              onPressed: selectDateOfBirth,
              child: Text(
                  (age == null)
                      ? "Please enter your age."
                      : "My age is: ${age!.toInt()}",
                  style: const TextStyle(color: Colors.white,)
              ),
              style: ButtonStyle(
                alignment: Alignment.center,
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black54),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
                "Please enter your height: ${sliderHeight
                    .toInt()} cm",
                style: const TextStyle(
                  color: Colors.black,
                )
            ),
          ),
          heightSlider(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child : TextField(
              keyboardType: TextInputType.number,
              onChanged: (String string) {
                setState(() {
                  weightChanged = double.tryParse(string);
                });
              },
              decoration: const InputDecoration(
                  labelText: 'Enter your weight in Kgs'
              ),
            ),
          ),
          const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "What is your daily activity level?",
                style: TextStyle(color: Colors.black),
              )
          ),
          Padding(
              padding: const EdgeInsets.all(15.0),
              child : rowRadio()
          ),
        ]
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: ElevatedButton(
            onPressed: calculateNeedsCalories,
            child: const Text("Calculate", style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.pink),
            )
        ),
      ),
    ],
    );

  }

// gender switch
  Widget genderSwitch() {
    return Switch(value: gender, onChanged: (bool b){
      setState(() {
        gender = b;
      });
    });

  } // end gender switch

// select DOB
  Future<void> selectDateOfBirth() async {
    DateTime? choice = await showDatePicker(
        context: context,
        initialDatePickerMode: DatePickerMode.year,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now()
    );
    if (choice != null) {
      setState(() {
        var diff = DateTime.now().difference(choice);
        var days = diff.inDays;
        var years = (days / 365);
        setState(() {
          age = years;
        });
      });
    }
  }

  Widget heightSlider() {
      return Slider(
          value: sliderHeight,
          min: 100,
          max: 220.0,
          activeColor: Colors.black54,
          divisions: 25,
          onChanged: (double d) {
            setState(() {
              sliderHeight = d;
            });
          }
      );
  }

  Row rowRadio() {
    List<Widget> l = [];
    activities.forEach((key, value) {
      Column column = Column(
        mainAxisAlignment : MainAxisAlignment.center,
        children: [
          Radio<Object>(
              activeColor: Colors.black54,
              value: key,
              groupValue: sportSelection,
              onChanged: (Object? i) {
                setState(() {
                  sportSelection = i;
                });
              }
          ),
          Text(
              value,
              style: const TextStyle(
                color: Colors.black,
              )
          )
        ],
      );
      l.add(column);
    });
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: l
    );
  }

  // calculate
  void calculateNeedsCalories() {
    if (age != null && weightChanged != null && sportSelection != null) {
      if (gender) {
        calorieBase = (66.4730 + (13.7516 * weightChanged!) + (5.0033 * sliderHeight) - (6.7550 * age!)).toInt();
      } else {
        calorieBase = (655.0955 + (9.5634 * weightChanged!) + (1.8496 * sliderHeight) - (4.6756 * age!)).toInt();
      }
      switch(sportSelection) {
        case 0:
          calorieActivity = (calorieBase! * 1.2).toInt();
          break;
        case 1:
          calorieActivity = (calorieBase! * 1.5).toInt();
          break;
        case 2:
          calorieActivity = (calorieBase! * 1.8).toInt();
          break;
        default:
          calorieActivity = calorieBase;
          break;
      }
      setState(() {
        dialog();
      });
    } else {
      alert();
    }
  }

  // alert
  Future<void> alert() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext) {
            return AlertDialog(
              title: const Text("Error", style: TextStyle(color: Colors.pink)),
              content: const Text("Please fill out all the fields"),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () => {
                      Navigator.pop(buildContext)
                    },
                    child: const Text("OK"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    )
                )
              ],
            );

        }
    );
  }

// dialog
  Future<Null> dialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext) {
          return Padding(
              padding: const EdgeInsets.all(15.0),
              child: SimpleDialog(
                title: const Text(
                    "Your calorie requirement:",
                    style: TextStyle(color: Colors.purple)
                ),
                children: [
                  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text("Your basal metabolic rate is: $calorieBase")
                  ),
                  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text("Based on what you've told us your calorie intake should be: $calorieActivity")
                  ),
                  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                          onPressed: () => {
                            Navigator.pop(buildContext)
                          },
                          child: const Text(
                              "OK",
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.pink),
                          )
                      )
                  )
                ],
              )
          );
        }
    );
  }
} // end state