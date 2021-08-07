class WeatherData {

  final DateTime date;
  final String name;
  final double temp;
  final String main;
  final String icon;
   /*
  DateTime date = DateTime(2021,8,8,18);
  String name= "Haifa";
  double temp = 26.26;
  String main = "Clouds";
  String icon="02n";

    */

  WeatherData({this.date, this.name, this.temp, this.main, this.icon});

  factory WeatherData.fromJson(Map<String, dynamic> json,String name) {
    return WeatherData(
      date: new DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000 , isUtc: false),
      name: name,
      temp: json['main']['temp'].toDouble() - 273.15,
      main: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }
}
