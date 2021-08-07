import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app2/main.dart';

class Settings {
  bool autoCover;
  String city;
  bool goodDayAllert;
  String basketAllert;
  int alreadySet;
  int newGoodDay;

  Settings({this.alreadySet, this.city, this.autoCover, this.goodDayAllert, this.basketAllert, this.newGoodDay});

  factory Settings.Defualt() {
    return Settings(
      alreadySet: 0,
      autoCover: false,
      city: 'haifa',
      goodDayAllert: false,
      basketAllert: 'No',
      newGoodDay: 1,
    );
  }

  void SetLocation(String city){
    this.city = city;

    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings").update({
      'City': city
    });
  }

  void SetCoverPolicy(String policy) {
    int answer = 0;
    if (policy == "Ask me before covering") {
      this.autoCover = false;
      answer = 0;
    }
    else {
      this.autoCover = true;
      answer = 1;
    }
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings").update({
      'Auto cover': answer
    });
  }
  void SetGoodDayAllert(String answer) {
    int newAnswer = 0;
    if (answer == "Yes") {
      this.goodDayAllert = true;
      newAnswer = 1;
    }
    else{
      this.goodDayAllert = true;
      newAnswer = 0;
    }
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings").update({
      'Good day Allert': newAnswer
    });
  }
  bool GetGoodDayAllert(){
    return this.goodDayAllert;
  }

  String GetLocation(){
     return this.city;
  }
   bool GetAutoCover(){
    return this.autoCover;
  }

  void UpdateCity() {
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings/City").once().then((DataSnapshot data) {
      this.city = data.value.toString();
    });
  }
  void UpdateAutoCover() {
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings/Auto cover").once().then((DataSnapshot data) {
      this.city = data.value.toString();
    });
  }
  void UpdateGooddayAllert() {
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings/Good day Allert").once().then((DataSnapshot data) {
      this.city = data.value.toString();
    });
  }

  int GoodDayAllert(){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings/Good day Allert").once().then((DataSnapshot data) {
      this.newGoodDay = data.value;
    });
    return this.newGoodDay;
  }

  bool GetCoverPolicy(){
    return this.autoCover;
  }
  void SetBasketCapacityAllert(String capacity){
    int answer = 0;

    if ('Yes, when it\'s almost full' == capacity)
      answer = 2;
    if ('Yes, when it\'s totaly full'== capacity)
      answer = 1;
    if ('No' == capacity)
      answer = 0;

    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings").update({
      'Basket Allert': answer
    });

    this.basketAllert = capacity;
  }
  String GetBasketCapacityAllert(){
    return this.basketAllert;
  }
  int GetAlreadySet(){
    return this.alreadySet;
  }
  void SetAlreadySet(int status){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("Settings").update({
        'Already set': status
    });

    this.alreadySet = status;
  }

}

