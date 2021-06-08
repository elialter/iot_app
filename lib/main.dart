import 'dart:developer';
import 'dart:io';

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




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}

Settings settings = new Settings.Defualt();
FirebaseData firebaseData = new FirebaseData.Init();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      MyHomePage.routeName: (BuildContext context) => new MyHomePage(title: "Smart Line Home Page"),
      MyItemsPage.routeName: (BuildContext context) => new MyItemsPage(title: "MyItemsPage"),
      WeatherPage.routeName: (BuildContext context) => new WeatherPage(title: "WeatherPage"),
    };

    messageHandler(context);

    return new MaterialApp(
      title: 'Smart Line',
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new MySettings(),
      routes: routes,
    );
  }

}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  static const String routeName = "/MyHomePage ";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  class MyApp extends StatelessWidget {
  @override
  bool isLoading = false;
  CoordinateTable coordinateTable = new CoordinateTable.initTable();
  String city = settings.GetLocation();

  void initState() {
    updateToken();
    messageHandler(context);
    loadWeather();
  }

  WeatherDescriptionList weatherList;

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
                                  icon: Image.asset('Assets/basket3.png'), // Image.network(
                                        //'https://image.flaticon.com/icons/png/512/2230/2230786.png'),
                                  iconSize: 70.0,
                                  tooltip: 'Refresh',
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) =>
                                            MyBasketItemPage()));
                                  },
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
                                  icon: Image.asset('Assets/line.PNG'),    //Image.network(
                                  //'https://previews.123rf.com/images/amin268/amin2681811/amin268181100729/127364943-drying-thin-line-icon-laundry-and-dry-clothes-sign-vector-graphics-a-linear-pattern-on-a-white-backg.jpg'),
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
                                  icon: Image.network(
                                      'https://images-na.ssl-images-amazon.com/images/I/61ql%2BQimu-L.png'),
                                  iconSize: 70.0,
                                  tooltip: 'Weather Forecast',
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => WeatherPage()));
                                  },
                                  color: Colors.white,

                                ),
                              )
                            ]
                        )
                    ),
                  ],
                ),
                Center(
                    child:
                    Text(GetRecomendaition(), style: TextStyle(fontSize: 25))
                )
              ]
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
                    Navigator.push(context, MaterialPageRoute(
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
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => WeatherPage()));
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
            onChanged: (bool position) => SetCover(position),
          ),
          // This trailing comma makes auto-formatting nicer for build methods.// This trailing comma makes auto-formatting nicer for build methods.
        )
    );
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
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&'+newlatlon);
    final forecastResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&'+newlatlon);

    //    'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&lat=32.794044&lon=34.989571'

    if (weatherResponse.statusCode == 200 &&
        forecastResponse.statusCode == 200) {
      return setState(() {
        var json = jsonDecode(weatherResponse.body);
        weatherList = new WeatherDescriptionList.fromJson(json);
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
      if (weatherList == null){
        return "";
      }
      if (weatherList.list[i] == "Rain")
        return "Not a good time to hang laundry";
      if (weatherList.list[i] == "Cloud")
        cloud++;
      if (weatherList.list[i] == "Clear")
        clear++;
    }
    if (clear == 10)
      return "Ideal time to hang laundry";
    if (clear >= 8)
      return "Good time to hang laundry";
    if (clear >= 6)
      return "Ok time to hang laundry";

    return "Not rainy, but not a good time to hang laundry";
  }
}


void SetCover(bool position){
  final databaseReference = FirebaseDatabase.instance.reference();
  if(position) {
    databaseReference.child('Cover').update({
      'Status': 1
    });
  }
  else{
    databaseReference.child('Cover').update({
      'Status': 0
    });
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
  WeatherData weatherData;//=WeatherData();
  ForecastData forecastData;//=ForecastData();
  CoordinateTable coordinateTable = new CoordinateTable.initTable();
  String city = settings.GetLocation();

  @override
  void initState()  {
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
    sleep(Duration(seconds : 2));
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
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
    String newlatlon;
    newlatlon = coordinateTable.coordinatesMap[city];

//    final lat = 32.794044;
//    final lon = 34.989571;
    final weatherResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&'+newlatlon);
    final forecastResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&'+newlatlon);

    //    'https://api.openweathermap.org/data/2.5/forecast?APPID=3b223fbe211147629d3f1c189bb6ca6f&lat=32.794044&lon=34.989571'

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
        title: Text('Basket Status'),
        backgroundColor: Colors.teal,
      ),
      body: new Container(
        child: new Column(
            children: <Widget>[
              Image.asset(ShowBasketStatus())
            ]
        ),
      ),
    );
  }
  String ShowBasketStatus(){
    basketStatus = firebaseData.GetData("Laundry basket");
    print("basketStatus");
    print(basketStatus);
    if (basketStatus == 0){
      return "images/basket0.png";
    }
    if (basketStatus == 1){
      return "images/basket1.png";
    }
    if (basketStatus == 2){
      return "images/basket2.png";
    }
    if (basketStatus == 3){
      return "images/basket3.png";
    }
    return "images/basket0.png";
  }
}

class CoordinateTable{
  Map coordinatesMap;

  CoordinateTable({this.coordinatesMap});

   factory CoordinateTable.initTable(){
    Map map  = new Map();
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
        title: Text("Settings"),
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
                focusColor:Colors.white,
                value: _chosenBasketallert,
                //elevation: 5,
                style: TextStyle(color: Colors.white),
                iconEnabledColor:Colors.black,
                items: <String>[
                  'Yes, when it\'s almost full',
                  'Yes, when it\'s totaly full',
                  'No',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style:TextStyle(color:Colors.black),),
                  );
                }).toList(),
                hint:Text(
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
                focusColor:Colors.white,
                value: _chosenGoodDay,
                //elevation: 5,
                style: TextStyle(color: Colors.white),
                iconEnabledColor:Colors.black,
                items: <String>[
                  'Yes',
                  'No',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style:TextStyle(color:Colors.black),),
                  );
                }).toList(),
                hint:Text(
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
                focusColor:Colors.white,
                value: _chosenPolicy,
                //elevation: 5,
                style: TextStyle(color: Colors.white),
                iconEnabledColor:Colors.black,
                items: <String>[
                  'Cover Automatically',
                  'Ask me before covering',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style:TextStyle(color:Colors.black),),
                  );
                }).toList(),
                hint:Text(
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
                focusColor:Colors.white,
                value: _chosenCity,
                //elevation: 5,
                style: TextStyle(color: Colors.white),
                iconEnabledColor:Colors.black,
                items: <String>[
                  'Haifa',
                  'Tel Aviv',
                  'Jerusalem',
                  'Ariel',
                  'Netanya',
                  'Eilat',
                  'Beersheba',
                  'Nazareth',
                  'Rishon LeẔiyyon',
                  'Ashqelon',
                  'Nahariyya',
                  'Herzelia',
                  'Qiryat Shemona',
                  'Qatsrin',
                  'Efrat',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style:TextStyle(color:Colors.black),),
                  );
                }).toList(),
                hint: FittedBox  (
                  fit: BoxFit.fitWidth,
                  child:Text(
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
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => MyHomePage()));
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

void updateToken() async{
  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String fcmToken = await _fcm.getToken();
  log(fcmToken);
  final databaseReference = FirebaseDatabase.instance.reference();
  if(fcmToken !=null){
    databaseReference.child('Tokens').update({
      'token': fcmToken
    });
  }
}

void messageHandler(BuildContext context) {
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    handleMessage(event.data["body"]);
    print(event.notification?.body);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(event.notification?.title),
            content: Text(event.notification?.body),
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

void handleMessage(String field) { //For Eli
  final databaseReference = FirebaseDatabase.instance.reference();
  databaseReference.once().then((DataSnapshot snapshot) {
    String Status = snapshot.value[field]['Status'];
    int value = int.parse(snapshot.value[field]['Status']);
    firebaseData.SetData(field, value);
    //Do something with updated status
  });
}


