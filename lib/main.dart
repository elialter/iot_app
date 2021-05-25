import 'dart:io';

///------------------------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:flutter_app2/lib/Weather.dart';
import 'package:flutter_app2/lib/WeatherItem.dart';
import 'package:flutter_app2/models/WeatherData.dart';
import 'package:flutter_app2/models/ForecastData.dart';


void main() => runApp(new MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      MyItemsPage.routeName: (BuildContext context) => new MyItemsPage(title: "MyItemsPage"),
      WeatherPage.routeName: (BuildContext context) => new WeatherPage(title: "WeatherPage"),
    };

    return new MaterialApp(
      title: 'Laundry Rack App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Laundry Rack Home Page'),
      routes: routes,
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
//  class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final databaseReference = FirebaseDatabase.instance.reference();
    //add objects to database
    databaseReference.child("Cover").set({
      'Status': 'closed'
    });
    return MaterialApp(
      title: 'Laundry Rack App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
          backgroundColor: Colors.white54,
          appBar: AppBar(
            title: Text('            Smart Line'),
            actions: [
              Icon(Icons.favorite),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                //child: Icon(Icons.search),
              ),
              Icon(Icons.more_vert),
            ],
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                           icon: Image.network('https://image.flaticon.com/icons/png/512/2230/2230786.png'),
                              iconSize: 70.0,
                              tooltip: 'Refresh',
                            onPressed: () => null,
                             color: Colors.white,
                          ),
                      )
                    ]
                  )
              ),
              Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Image.network('https://previews.123rf.com/images/amin268/amin2681811/amin268181100729/127364943-drying-thin-line-icon-laundry-and-dry-clothes-sign-vector-graphics-a-linear-pattern-on-a-white-backg.jpg'),
                            iconSize: 70.0,
                            tooltip: 'Refresh',
                            onPressed: () => null,
                            color: Colors.white,
                          ),
                        )
                      ]
                  )
              ),
              Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Image.network('https://cdn3.iconfinder.com/data/icons/summer-189/64/sun_bright_sunlight-512.png'),
                            iconSize: 70.0,
                            tooltip: 'Weather Forecast',
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherPage()));
                            },
                            color: Colors.white,

                          ),
                        )
                      ]
                  )
              ),
            ],
          ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Menu'),
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('History'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Washing basket'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.schedule),
                title: Text('Schedule cover'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.wb_sunny),
                title: Text('Weather'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Contact us'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),



        floatingActionButton: LiteRollingSwitch(
          // tooltip: 'Cover the laundry',
          value: false,
          textOn: "Covered",
          textOff: "Uncovered",
          textSize: 14.0,
          colorOn: Colors.lightGreen,
          colorOff: Colors.redAccent,
          iconOn: Icons.power_settings_new,
          iconOff: Icons.power_settings_new,
          onChanged: (bool position) =>  SetCover(position),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.// This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

void SetCover(bool position){
  final databaseReference = FirebaseDatabase.instance.reference();
  if(position) {
    databaseReference.child('Cover').set({
      'Status': 'Yes'
    });
  }
  else{
    databaseReference.child('Cover').set({
      'Status': 'No'
    });
  }
}

class WeatherPage extends StatefulWidget {
  WeatherPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/WeatherPage ";

  final String title;

  @override
  //_WeatherPage createState() => new _WeatherPage();
  State<StatefulWidget> createState() {
    return new _WeatherPage();
  }
}


class _WeatherPage extends State<WeatherPage> {

  bool isLoading = false;
  WeatherData weatherData;//=WeatherData();
  ForecastData forecastData;//=ForecastData();

  @override
  void initState()  {
    super.initState();
    loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    //loadWeather();
    sleep(Duration(seconds : 2));
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast Page'),
        backgroundColor: Colors.teal,
      ),
        body: Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: weatherData != null ? Weather(weather: weatherData) : Container(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isLoading ? CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: new AlwaysStoppedAnimation(Colors.purple),
                          ) : IconButton(
                            icon: new Icon(Icons.refresh),
                            tooltip: 'Refresh',
                            onPressed: loadWeather,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200.0,
                        child: forecastData != null ? ListView.builder(
                            itemCount: forecastData.list.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => WeatherItem(weather: forecastData.list.elementAt(index))
                        ) : Container(),
                      ),
                    ),
                  )
                ]
            )
        )
    );
  }

  loadWeather() async {
    setState(() {
      isLoading = true;
    });
    final lat = 32.794044;
    final lon =  34.989571;
    final weatherResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&lat=${lat
            .toString()}&lon=${lon.toString()}');
    final forecastResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&lat=${lat
            .toString()}&lon=${lon.toString()}');

    if (weatherResponse.statusCode == 200 &&
        forecastResponse.statusCode == 200) {
      return setState(() {
        var json = jsonDecode(weatherResponse.body);
        weatherData = new WeatherData.fromJson(json['list'][0], json['city']['name']);
        forecastData = new ForecastData.fromJson(json);
        isLoading = false;
      });
    }



    setState(() {
      isLoading = false;
    });
  }

}

class MyItemsPage extends StatefulWidget {
  MyItemsPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";

  final String title;

  @override
  _MyItemsPageState createState() => new _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> {
  @override
  Widget build(BuildContext context) {
    var button = new IconButton(icon: new Icon(Icons.arrow_back), onPressed: _onButtonPressed);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Text('Item1'),
            new Text('Item2'),
            button
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _onFloatingActionButtonPressed,
        tooltip: 'Add',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _onFloatingActionButtonPressed() {
  }

  void _onButtonPressed() {
    Navigator.pop(context);
  }
}

