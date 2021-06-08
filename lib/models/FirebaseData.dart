import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app2/models/WeatherData.dart';

class FirebaseData {
  Map dataMap;

  FirebaseData({this.dataMap});

  factory FirebaseData.Init() {
    Map map = new Map();
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.once().then((DataSnapshot snapshot) {
      map['Cover'] = int.parse(snapshot.value['Cover']['Status']);
      map['Clothes on line'] =
          int.parse(snapshot.value['Clothes on line']['Status']);
      map['Laundry basket'] =
          int.parse(snapshot.value['Laundry basket']['Status']);
      map['Rain'] = int.parse(snapshot.value['Rain']['Status']);
      map['Sun Light'] = int.parse(snapshot.value['Sun Light']['Status']);
      //Do something with updated status
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