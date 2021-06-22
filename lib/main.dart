import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';

///------------------------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:flutter_app2/lib/Settings.dart';
import 'package:flutter_app2/lib/Weather.dart';
import 'package:flutter_app2/lib/WeatherItem.dart';
import 'package:flutter_app2/models/WeatherData.dart';
import 'package:flutter_app2/models/ForecastData.dart';
import 'package:flutter_app2/models/WeatherDescriptionList.dart';
import 'package:flutter_app2/models/FirebaseData.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

const String user = "Eliezer"; // "Eliad", "Eliezer" , "Barel"
String MyToken;
_MyHomePageState HomePageState =_MyHomePageState();
CoverSwitch coverSwitch;
//int settingsStatus = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //Future.wait([GetSettingsStatus()]) ;
  //log("Main settingsStatus: ${Future.wait([getGlobalSettingsStatus()])}");
  updateToken();
  runApp(new MyApp());
}

Settings settings;
FirebaseData firebaseData;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      MyHomePage.routeName: (BuildContext context) =>
          new MyHomePage(title: "Smart Line Home Page"),
      MyItemsPage.routeName: (BuildContext context) =>
          new MyItemsPage(title: "MyItemsPage"),
      WeatherPage.routeName: (BuildContext context) =>
          new WeatherPage(title: "WeatherPage"),
      MySettings.routeName: (BuildContext context) =>
          new MySettings(title: "MySettings"),
    };

    messageHandler(context);
    firebaseData = new FirebaseData.Init();
    settings = new Settings.Defualt();

    return FutureBuilder<List<int>>(
        future: Future.wait([GetSettingsStatus()]),
        builder: (context, AsyncSnapshot<List<int>> snapshot) {
          if (!snapshot.hasData) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Loading..',
              theme: ThemeData(
                primarySwatch: Colors.teal,
              ),
              home: Scaffold(
                appBar: AppBar(
                  title: Text('Loading..'),
                ),
                body: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.purple,
                  ),
                ),
              ),
            );
          }
          Widget currentHome;
          if (snapshot.data[0] == 0) {
            currentHome = new MySettings();
            final databaseReference = FirebaseDatabase.instance.reference();
            databaseReference
                .child("Users/$user/Settings")
                .update({"Already set": 1});
          } else {
            firebaseData.SetData("Already set", 1);
            currentHome = new MyHomePage();
          }
          log("snapshot.data[0] = ${snapshot.data[0]}");
          //sleep(Duration(seconds: 15));
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Line',
            theme: new ThemeData(
              primarySwatch: Colors.teal,
            ),
            home: currentHome,
            routes: routes,
          );
        });
  }
}

Future<int> GetSettingsStatus() async {
  final databaseReference = FirebaseDatabase.instance.reference();
  return await databaseReference
      .child("Users/$user/Settings/Already set")
      .once()
      .then((DataSnapshot data) {
    log("settingsStatus for $user: $data.value");
    firebaseData.SetData("Already set", data.value);
    return data.value;
  });
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  static const String routeName = "/MyHomePage ";

  @override
  _MyHomePageState createState() => HomePageState;//_MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  class MyApp extends StatelessWidget {
  @override
  bool isLoading = false;
  CoordinateTable coordinateTable = new CoordinateTable.initTable();
  String city = settings.GetLocation();
  //CoverSwitch coverSwitch;
  Widget liteSwitch;

  void initState() {
    //updateToken();
    coverSwitch = CoverSwitch(this.callback);
    liteSwitch = coverSwitch;
    messageHandler(context);
    loadWeather();
  }

  void callback(Widget nextSwitch) {
    setState(() {
      liteSwitch = nextSwitch;
    });
  }


  WeatherDescriptionList weatherList;
  WeatherData weatherData; //=WeatherData();

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    final databaseReference = FirebaseDatabase.instance.reference();
    //add objects to database
    /*
    databaseReference.child("Cover").set({
      'Status': 'closed'
    });

     */
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Line',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: Scaffold(
          backgroundColor: Colors.white,
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
          body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
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
                              icon: Image.asset(ShowBasketStatus()),
                              // Image.network(
                              //'https://image.flaticon.com/icons/png/512/2230/2230786.png'),
                              iconSize: 70.0,
                              tooltip: 'Refresh',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MyBasketItemPage()));
                              },
                              color: Colors.white,
                            ),
                          )
                        ])),
                    Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Image.asset('Assets/line.PNG'),
                              //Image.network(
                              //'https://previews.123rf.com/images/amin268/amin2681811/amin268181100729/127364943-drying-thin-line-icon-laundry-and-dry-clothes-sign-vector-graphics-a-linear-pattern-on-a-white-backg.jpg'),
                              iconSize: 70.0,
                              tooltip: 'Refresh',
                              onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                             builder: (context) => MyLineItemPage()));
                              },
                              color: Colors.white,
                            ),
                          )
                        ])),
                    Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Image.network(
                                  'https://images-na.ssl-images-amazon.com/images/I/61ql%2BQimu-L.png'),
                              iconSize: 70.0,
                              tooltip: 'Weather Forecast',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WeatherPage()));
                              },
                              color: Colors.white,
                            ),
                          )
                        ])),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: weatherData != null
                          ? Weather(weather: weatherData)
                          : Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: isLoading
                          ? CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor:
                                  new AlwaysStoppedAnimation(Colors.purple),
                            )
                          : IconButton(
                              icon: new Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              onPressed: loadWeather,
                              color: Colors.green,
                            ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    GetRecomendaition(),
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  heightFactor: 5,
                ),
              ]),
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
                    Navigator.push(context,MaterialPageRoute(
                                 builder: (context) => MySettings()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Washing basket'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyBasketItemPage()));
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => WeatherPage()));
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

          floatingActionButton: liteSwitch,
          // This trailing comma makes auto-formatting nicer for build methods.// This trailing comma makes auto-formatting nicer for build methods.
        ));
  }

  loadWeather() async {
    setState(() {
      isLoading = true;
    });

    String newlatlon;
    newlatlon = coordinateTable.coordinatesMap[city];

//    final lat = 32.794044;
//    final lon = 34.989571;
    final weatherResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&' +
            newlatlon);
    final forecastResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&' +
            newlatlon);

    //    'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&lat=32.794044&lon=34.989571'

    if (weatherResponse.statusCode == 200 &&
        forecastResponse.statusCode == 200) {
      return setState(() {
        var json = jsonDecode(weatherResponse.body);
        weatherList = new WeatherDescriptionList.fromJson(json);
        weatherData =
            new WeatherData.fromJson(json['list'][0], json['city']['name']);
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  String GetRecomendaition() {
    var clear = 0;
    var cloud = 0;

//    while(weatherList == null)

    for (var i = 0; i < 10; i++) {
      if (weatherList == null) {
        return "";
      }
      if (weatherList.list[i] == "Rain")
        return "Not a good time to hang laundry";
      if (weatherList.list[i] == "Cloud") cloud++;
      if (weatherList.list[i] == "Clear") clear++;
    }
    if (clear == 10) return "Ideal time to hang laundry";
    if (clear >= 8) return "Good time to hang laundry";
    if (clear >= 6) return "Ok time to hang laundry";

    return "Not rainy, but not a good time to hang laundry";
  }
}


void SetCoverDataBase(bool position) {
  final databaseReference = FirebaseDatabase.instance.reference();
  if (position) {
    databaseReference.child('Cover').update({'Status': 1});
  } else {
    databaseReference.child('Cover').update({'Status': 0});
  }
}



class CoverSwitch extends StatefulWidget{
  Function callback;

  CoverSwitch(this.callback);

  void SetState(bool state) {
    final databaseReference = FirebaseDatabase.instance.reference();
    if (state) {
      databaseReference.child('Cover').update({'Status': 1});
    } else {
      databaseReference.child('Cover').update({'Status': 0});
    }
    //liteRollingSwitch.onChanged(state);
    //liteRollingSwitch.createState();
    //coverSwitch.SetState(true);
  //_MyHomePageState().SetCover(state);
  callback(new _coverSwitchState().NewSwitch(state));
  }
/*
  LiteRollingSwitch liteRollingSwitch = LiteRollingSwitch(
  // tooltip: 'Cover the laundry',
  value: false,
  textOn: "Covered",
  textOff: " Uncovered",
  textSize: 13.0,
  colorOn: Colors.lightGreen,
  colorOff: Colors.redAccent,
  iconOn: Icons.power_settings_new,
  iconOff: Icons.power_settings_new,
  onChanged: (bool position) => SetCover(position),
  );

 */


  @override
  _coverSwitchState createState() => new _coverSwitchState();

}

class _coverSwitchState extends State<CoverSwitch> {

  @override
  Widget build(BuildContext context) {
    return LiteRollingSwitch(
      // tooltip: 'Cover the laundry',
      value: false,
      textOn: "Covered",
      textOff: " Uncovered",
      textSize: 13.0,
      colorOn: Colors.lightGreen,
      colorOff: Colors.redAccent,
      iconOn: Icons.power_settings_new,
      iconOff: Icons.power_settings_new,
      onChanged: (bool position) => SetCoverDataBase(position),
    );
  }

  Widget NewSwitch(bool state) {
    return LiteRollingSwitch(
      // tooltip: 'Cover the laundry',
      value: state,
      textOn: "Covered",
      textOff: " Uncovered",
      textSize: 13.0,
      colorOn: Colors.lightGreen,
      colorOff: Colors.redAccent,
      iconOn: Icons.power_settings_new,
      iconOff: Icons.power_settings_new,
      onChanged: (bool position) => SetCoverDataBase(position),
    );
  }
}



class WeatherPage extends StatefulWidget {
  WeatherPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/WeatherPage ";

  final String title;

//  @override
//  _WeatherPage createState() => new _WeatherPage();

  @override
  //_WeatherPage createState() => new _WeatherPage();
  State<StatefulWidget> createState() {
    return new _WeatherPage();
  }
}

class _WeatherPage extends State<WeatherPage> {
  bool isLoading = false;
  WeatherData weatherData; //=WeatherData();
  ForecastData forecastData; //=ForecastData();
  CoordinateTable coordinateTable = new CoordinateTable.initTable();
  String city = settings.GetLocation();

  @override
  void initState() {
    super.initState();
    loadWeather();
    messageHandler(context);
    //super.initState();
    /*
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification?.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });

     */
  }

  @override
  Widget build(BuildContext context) {
    //loadWeather();
    sleep(Duration(seconds: 2));
    return Scaffold(
        backgroundColor: Colors.yellow[40],
        appBar: AppBar(
          title: Text('      Weather Forecast'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: weatherData != null
                      ? Weather(weather: weatherData)
                      : Container(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: new AlwaysStoppedAnimation(Colors.purple),
                        )
                      : IconButton(
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
                child: forecastData != null
                    ? ListView.builder(
                        itemCount: forecastData.list.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => WeatherItem(
                            weather: forecastData.list.elementAt(index)))
                    : Container(),
              ),
            ),
          )
        ])));
  }

  loadWeather() async {
    setState(() {
      isLoading = true;
    });
    String newlatlon;
    newlatlon = coordinateTable.coordinatesMap[city];

//    final lat = 32.794044;
//    final lon = 34.989571;
    final weatherResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&' +
            newlatlon);
    final forecastResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&' +
            newlatlon);

    //    'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&lat=32.794044&lon=34.989571'

    if (weatherResponse.statusCode == 200 &&
        forecastResponse.statusCode == 200) {
      return setState(() {
        var json = jsonDecode(weatherResponse.body);
        weatherData =
            new WeatherData.fromJson(json['list'][0], json['city']['name']);
        forecastData = new ForecastData.fromJson(json);
        isLoading = false;
      });
    }
    return "images/emptyBasket.png";

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
    var button = new IconButton(
        icon: new Icon(Icons.arrow_back), onPressed: _onButtonPressed);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[new Text('Item1'), new Text('Item2'), button],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _onFloatingActionButtonPressed,
        tooltip: 'Add',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _onFloatingActionButtonPressed() {}

  void _onButtonPressed() {
    Navigator.pop(context);
  }
}

class MyBasketItemPage extends StatefulWidget {
  MyBasketItemPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyBasketItemPage";

  final String title;

  @override
  _MyBasketItemPage createState() => new _MyBasketItemPage();
}

class _MyBasketItemPage extends State<MyBasketItemPage> {
  var basketStatus = 2;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('          Basket Status'),
        backgroundColor: Colors.teal,
      ),
      body: new Container(
        child: new Column(children: <Widget>[
          Column(
            children: [
              Image.asset(ShowBasketStatus()),
              Text(
                GetBasketStatus(),
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              )
            ],
          )
        ]),
      ),
    );
  }

  String GetBasketStatus() {
    int basketStatus = firebaseData.GetData("Laundry basket");

    if (basketStatus == 0) {
      return "Your basket is empty";
    }
    if (basketStatus == 1) {
      return "You don't have much laundry in your basket";
    }
    if (basketStatus == 2) {
      return "You have a lot of laundry in your basket";
    }
    if (basketStatus == 3) {
      return "Your basket is full";
    }
    return "";
  }
}

String ShowBasketStatus() {
  int basketStatus = firebaseData.GetData("Laundry basket");

  if (basketStatus == 0) {
    return "images/basket0.png";
  }
  if (basketStatus == 1) {
    return "images/basket1.png";
  }
  if (basketStatus == 2) {
    return "images/basket2.png";
  }
  if (basketStatus == 3) {
    return "images/basket3.png";
  }
  return "images/basket0.png";
}

class CoordinateTable {
  Map coordinatesMap;

  CoordinateTable({this.coordinatesMap});

  factory CoordinateTable.initTable() {
    Map map = new Map();
    map['haifa'] = 'lat=32.794044&lon=34.989571';
    map['tel aviv'] = 'lat=32.083333&lon=34.7999968';
    map['jerusalem'] = 'lat=31.76904&lon=35.21633';
    map['ariel'] = 'lat=32.1065&lon=35.18449';
    map['netanya'] = 'lat=32.33291&lon=34.85992';
    map['eilat'] = 'lat=29.55805&lon=34.94821';
    map['beersheba'] = 'lat=31.2589&lon=34.7978';
    map['nazareth'] = 'lat=32.7021&lon=35.2978';
    map['rishon leẔiyyon'] = 'lat=31.95&lon=34.81';
    map['ashqelon'] = 'lat=31.6658&lon=34.5664';
    map['nahariyya'] = 'lat=33.0036&lon=35.0925';
    map['herzelia'] = 'lat=32.184448&lon=34.870766';
    map['qiryat shemona'] = 'lat=33.2075&lon=35.5697';
    map['qatsrin'] = 'lat=32.9925&lon=35.6906';
    map['efrat'] = 'lat=31.653589&lon=35.149934';

    return CoordinateTable(
      coordinatesMap: map,
    );
  }
}

class MySettings extends StatefulWidget {
  MySettings({Key key, this.title}) : super(key: key);

  final String title;
  static const String routeName = "/MySettings ";

  @override
  _MySettingsState createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  String _chosenCity;
  String _chosenPolicy;
  String _chosenGoodDay;
  String _chosenBasketallert;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("                          Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('Assets/line.PNG')),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: DropdownButton<String>(
                focusColor: Colors.white,
                value: _chosenBasketallert,
                //elevation: 5,
                style: TextStyle(color: Colors.white),
                iconEnabledColor: Colors.black,
                items: <String>[
                  'Yes, when it\'s almost full',
                  'Yes, when it\'s totaly full',
                  'No',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                hint: Text(
                  "Get notification for the basket status",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                onChanged: (String value) {
                  setState(() {
                    _chosenBasketallert = value;
                    settings.SetBasketCapacityAllert(_chosenBasketallert);
                  });
                },
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: DropdownButton<String>(
                focusColor: Colors.white,
                value: _chosenGoodDay,
                //elevation: 5,
                style: TextStyle(color: Colors.white),
                iconEnabledColor: Colors.black,
                items: <String>[
                  'Yes',
                  'No',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                hint: Text(
                  "Get notification in case of a good day?",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                onChanged: (String value) {
                  setState(() {
                    _chosenGoodDay = value;
                    settings.SetGoodDayAllert(_chosenPolicy);
                  });
                },
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: DropdownButton<String>(
                focusColor: Colors.white,
                value: _chosenPolicy,
                //elevation: 5,
                style: TextStyle(color: Colors.white),
                iconEnabledColor: Colors.black,
                items: <String>[
                  'Cover Automatically',
                  'Ask me before covering',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                hint: Text(
                  "Default behaviour in case of rain",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                onChanged: (String value) {
                  setState(() {
                    _chosenPolicy = value;
                    settings.SetCoverPolicy(_chosenPolicy);
                  });
                },
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: DropdownButton<String>(
                focusColor: Colors.white,
                value: _chosenCity,
                //elevation: 5,
                style: TextStyle(color: Colors.white),
                iconEnabledColor: Colors.black,
                items: <String>[
                  'Ariel',
                  'Ashqelon',
                  'Beersheba',
                  'Efrat',
                  'Eilat',
                  'Haifa',
                  'Herzelia',
                  'Jerusalem',
                  'Nahariyya',
                  'Nazareth',
                  'Netanya',
                  'Qiryat Shemona',
                  'Qatsrin',
                  'Rishon LeẔiyyon',
                  'Tel Aviv',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                hint: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "Smart line location",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                onChanged: (String value) {
                  setState(() {
                    _chosenCity = value;
                    settings.SetLocation(_chosenCity);
                  });
                },
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.teal, borderRadius: BorderRadius.circular(20)),
              child: FlatButton(
                onPressed: () {
                  if (firebaseData.GetSetStatus() == 0) {
                    firebaseData.SetData("Already set", 1);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MyHomePage()));
                  }
                  else{
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Set Settings',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}

void updateToken() async {
  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String fcmToken = await _fcm.getToken();
  MyToken = fcmToken;
  log(fcmToken);
  final databaseReference = FirebaseDatabase.instance.reference();
  if (fcmToken != null) {
    databaseReference.child('Tokens').update({user: fcmToken});
  }
}

void messageHandler(BuildContext context) {
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    print(event.notification?.body);
    handleMessageOnMessage(event.data["body"], context);
    /*
    handleMessage(event.data["body"]);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              event.notification?.title,
              textAlign: TextAlign.center,
            ),
            content: Text("${event.notification?.body}",
                textAlign: TextAlign.center),
            //.substring(0,seperateCharIndex)} and status is ${event.notification?.body.substring(seperateCharIndex)}"),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });

     */
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    handleMessage(message.data["body"]); //need?
  });
  //var messaging = FirebaseMessaging.instance;
  //messaging.subscribeToTopic("messaging");
  //messaging.unsubscribeFromTopic("messaging");
}

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //handleMessage(message.notification?.title); //need?
}

void handleMessage(String field) {
  print("handleMessage was called");
  final databaseReference = FirebaseDatabase.instance.reference();
  databaseReference.child("$field/Status").once().then((DataSnapshot data) {
    print("$field/Status");
    print(data.value);
    int value = int.parse(data.value);
    firebaseData.SetData(field, data.value);
  });
}

void handleMessageOnMessageOpenedApp(String field) {}

void handleMessageOnMessage(String field, BuildContext context) {
  switch (field) {
    case "Rain":
      showDialog(
          context: context,
          builder: (BuildContext context) {
            //if cover is open and there are clothes on the line - check database
            return AlertDialog(
              title: Text(
                field + " Allert",
                textAlign: TextAlign.center,
              ),
              content: Text(
                  "Your clothes are getting wet! would you like to close the cover?",
                  textAlign: TextAlign.center),
              actions: [
                TextButton(

                  child: Text("  No  ", style: TextStyle(backgroundColor: Colors.redAccent[100], color: Colors.black),),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("  Yes  ", style: TextStyle(backgroundColor: Colors.lightGreen, color: Colors.black),),
                  onPressed: () {
                    Navigator.of(context).pop();
                    coverSwitch.SetState(true);
                  },
                ),
              ],
            );
          });
      break;
  }
}


class MyLineItemPage extends StatefulWidget {
  MyLineItemPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyLineItemPage";

  final String title;

  @override
  _MyLineItemPage createState() => new _MyLineItemPage();
}

class _MyLineItemPage extends State<MyLineItemPage> {
  var basketStatus = 2;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('          Line Status'),
        backgroundColor: Colors.teal,
      ),
      body: new Container(
        child: new Column(children: <Widget>[
          Column(
            children: [
              Image.asset(ShowLineStatus()),
              Text(
                GetLineStatus(),
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              Image.asset(ShowSunLightStatus()),
              Text(
                GetSunLightStatus(),
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              )
            ],
          )
        ]),
      ),
    );
  }

  String GetLineStatus() {
    int clothesStatus = firebaseData.GetData("Clothes on line");

    if (clothesStatus == 0) {
      return "You have no clothes on your Line";
    }
    if (clothesStatus == 1) {
      return "You have clothes on your Line";
    }
    return "";
  }

  String GetSunLightStatus() {
    int sunLightStatus = firebaseData.GetData("Sun Light");


    if (sunLightStatus == 1) {
      return "sun light intensity is 1 in 5";
    }
    if (sunLightStatus == 2) {
      return "sun light intensity is 2 in 5";
    }
    if (sunLightStatus == 3) {
      return "sun light intensity is 3 in 5";
    }
    if (sunLightStatus == 4) {
      return "sun light intensity is 4 in 5";
    }
    if (sunLightStatus == 5) {
      return "sun light intensity is 5 in 5";
    }
    return "";
  }
}

String ShowLineStatus() {
  int clothesStatus = firebaseData.GetData("Clothes on line");

  if (clothesStatus == 0) {
    return "images/barels graphics.png";
  }
  if (clothesStatus == 1) {
    return 'Assets/line.PNG';
  }

  return "images/barels graphics.png";
}

String ShowSunLightStatus() {
  int sunLightStatus = firebaseData.GetData("Sun Light");

  if (sunLightStatus == 1) {
    return 'Assets/waiting.png';
  }
  if (sunLightStatus == 2) {
    return "images/waiting.png";
  }
  if (sunLightStatus == 3) {
    return 'Assets/waiting.PNG';
  }
  if (sunLightStatus == 4) {
    return "images/waiting.png";
  }
  if (sunLightStatus == 5) {
    return 'Assets/waiting.PNG';
  }

  return "images/waiting.png";
}
