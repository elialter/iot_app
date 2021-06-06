import 'package:flutter_app2/models/WeatherData.dart';

class WeatherDescriptionList {
  final List list;

  WeatherDescriptionList({this.list});

  factory WeatherDescriptionList.fromJson(Map<String, dynamic> json) {
    List clist = new List();


    for (dynamic e in json['list']) {
      String w = e['weather'][0]['main'];
      clist.add(w);
    }

    return WeatherDescriptionList(
      list: clist,
    );
  }
}