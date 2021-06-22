import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app2/models/WeatherData.dart';
import 'package:flutter_app2/main.dart';

class FirebaseData {
  Map dataMap;

  FirebaseData({this.dataMap});

  factory FirebaseData.Init() {
    Map map = new Map();
    map['Cover'] = 0;
    map['Clothes on line'] = 0;
    map['Laundry basket'] = 0;
    map['Rain'] = 0;
    map['Sun Light'] = 0;
    map['Already set'] = 0;
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Cover/Status").once().then((DataSnapshot data){
      map['Cover'] =data.value;
    });
    databaseReference.child("Clothes on line/Status").once().then((DataSnapshot data){
      map['Clothes on line'] =data.value;
    });
    databaseReference.child('Laundry basket/Status').once().then((DataSnapshot data){
      map['Laundry basket'] =data.value;
    });
    databaseReference.child('Rain/Status').once().then((DataSnapshot data){
      map['Rain'] =data.value;
    });
    databaseReference.child('Sun Light/Status').once().then((DataSnapshot data){
      map['Sun Light'] =data.value;
    });
    databaseReference.child('"Users/$user/Settings/Already set').once().then((DataSnapshot data){
      map['Already set'] = data.value;
    });

    return FirebaseData(
      dataMap: map,
    );
  }

  int GetData(String field){
    String newField;
    int newData;
    final databaseReference = FirebaseDatabase.instance.reference();
    if (field == "Settings/Already set"){
       newField = "Already set";
       databaseReference.child("Users/$user/Settings/Already set").once().then((DataSnapshot data) {
         dataMap[newField] = data.value;
       });
    }
    else {
      newField = field;
      databaseReference.child("$field/Status").once().then((DataSnapshot data) {
        dataMap[newField] = data.value;
      });
    }
    return dataMap[newField];
  }

  int GetSetStatus(){
    return dataMap["Already set"];
  }

  void SetData(String field, int data){
    if (data == 0){
      dataMap[field] = 0;
    }
    else{
      dataMap[field] = 1;
    }
  }

  loadData(Map map) async {
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("Cover/Status").once().then((DataSnapshot data){
      map['Cover'] =data.value;
    });
    await databaseReference.child("Clothes on line/Status").once().then((DataSnapshot data){
      map['Clothes on line'] =data.value;
    });
    await databaseReference.child('Laundry basket/Status').once().then((DataSnapshot data){
      map['Laundry basket'] =data.value;
    });
    await databaseReference.child('Rain/Status').once().then((DataSnapshot data){
      map['Rain'] =data.value;
    });
    await databaseReference.child('Sun Light/Status').once().then((DataSnapshot data){
      map['Sun Light'] =data.value;
    });
    await databaseReference.child('Users/$user/Settings/Already set').once().then((DataSnapshot data){
      map['Already set'] = data.value;
    });
  }

}