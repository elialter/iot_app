
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => new _RootPageState();
}
class _RootPageState extends State<RootPage> {
  FeedPage feedPage;

  Widget currentPage;

  @override
  void initState() {
    super.initState();
    feedPage = FeedPage(this.callback);

    currentPage = feedPage;
  }

  void callback(Widget nextPage) {
    setState(() {
      this.currentPage = nextPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //Current page to be changed from other classes too?
        body: currentPage
    );
  }
}



class FeedPage extends StatefulWidget {
  Function callback;

  FeedPage(this.callback);

  @override
  _feedPageState createState() => new _feedPageState();
}
class _feedPageState extends State<FeedPage> {

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      onPressed: () {
        this.widget.callback(new NextPage());
//        setState(() {
//          //change the currentPage in RootPage so it switches FeedPage away and gets a new class that I'll make
//        });
      },
      child: new Text('Go to a new page but keep root, just replace this feed part'),
    );
  }
}