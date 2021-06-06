class Settings {
  bool autoCover;
  String city;
  bool goodDayAllert;
  String basketAllert;

  Settings({this.city, this.autoCover, this.goodDayAllert, this.basketAllert});

  factory Settings.Defualt() {
    return Settings(
      autoCover: false,
      city: 'haifa',
      goodDayAllert: false,
      basketAllert: 'No',
    );
  }

  void SetLocation(String city){
    this.city = city;
  }

  void SetCoverPolicy(String policy) {
    if (policy == "Yes") {
      this.autoCover = false;
    }
    else{
      this.autoCover = true;
    }
  }
  void SetGoodDayAllert(String answer) {
    if (answer == "Yes") {
      this.goodDayAllert = true;
    }
    else{
      this.goodDayAllert = true;
    }
  }
  bool GetGoodDayAllert(){
    return this.goodDayAllert;
  }

  String GetLocation(){
    return this.city;
  }

  bool GetCoverPolicy(){
    return this.autoCover;
  }
  void SetBasketCapacityAllert(String capacity){
    this.basketAllert = capacity;
  }
  String GetBasketCapacityAllert(){
    return this.basketAllert;
  }

}
