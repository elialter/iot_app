import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app2/models/WeatherData.dart';

class FirebaseData {
  Map dataMap;

  FirebaseData({this.dataMap});

  factory FirebaseData.Init() {
    Map map = new Map();
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Cover/Status").once().then((DataSnapshot data){
      map['Cover'] = data.value;
    });
    databaseReference.child("Clothes on line/Status").once().then((DataSnapshot data){
      map['Clothes on line'] = data.value;
    });
    databaseReference.child("Laundry basket/Status").once().then((DataSnapshot data){
      map['Laundry basket'] = data.value;
    });
    databaseReference.child("Rain/Status").once().then((DataSnapshot data){
      map['Rain'] = data.value;
    });
    databaseReference.child("Sun Light/Status").once().then((DataSnapshot data){
      map['Sun Light'] =  data.value;
    });

    return FirebaseData(
      dataMap: map,
    );
  }

  int GetData(String field){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("$field/Status").once().then((DataSnapshot data){
      dataMap[field] = data.value;
    });
    return dataMap[field];
  }

  void SetData(String field, int data){
    dataMap[field] = data;
  }

}