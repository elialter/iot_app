import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app2/models/WeatherData.dart';

class FirebaseData {
  Map dataMap;

  FirebaseData({this.dataMap});

  factory FirebaseData.Init() {
    Map map = new Map();
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Cover/Status").once().then((DataSnapshot data){
      print("Cover/Status");
      print(data.value);
      map['Cover'] =data.value;
    });
    databaseReference.child("Clothes on line/Status").once().then((DataSnapshot data){
      print("Clothes on line/Status");
      print(data.value);
      map['Clothes on line'] =data.value;
    });
    databaseReference.child('Laundry basket/Status').once().then((DataSnapshot data){
      print("Laundry basket/Status");
      print(data.value);
      map['Laundry basket'] =data.value;
    });
    databaseReference.child('Rain/Status').once().then((DataSnapshot data){
      print("Rain/Status");
      print(data.value);
      map['Rain'] =data.value;
    });
    databaseReference.child('Sun Light/Status').once().then((DataSnapshot data){
      print("Sun Light/Status");
      print(data.value);
      map['Sun Light'] =data.value;
    });


    return FirebaseData(
      dataMap: map,
    );
  }

  int GetData(String field){
      return dataMap[field];
  }

  int SetData(String field, int data){
    dataMap[field] = data;
  }

}