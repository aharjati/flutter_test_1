import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Post {
  final String id;
  final String name;
  final String location;
  final String createDate;
  Post({this.id, this.name, this.location, this.createDate});
  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
      id: json["_id"],
      name: json['name'],
      location: json['location'],
      createDate: json['create_date'],
    );
  }
  @override
  String toString() {
    return name;
  }
}

class Post1 {
  final String title;
  final String thumbnailUrl;
  Post1({this.title, this.thumbnailUrl});
  factory Post1.fromJson(Map<String, dynamic> json) {
    return new Post1(
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
  @override
  String toString() {
    return title;
  }
}

class Post2 {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post2({this.userId, this.id, this.title, this.body});

  factory Post2.fromJson(Map<String, dynamic> json) {
    return Post2(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'TEST'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String tmp = "Query";
  bool isLoading = false;
  List posts = List();


  void runMyFuture() {
    fetchPosts().then((value) {
      setState(() {
        tmp = "FETCHED : $value";
        isLoading = false;
      });
    }, onError: (error) {
      print(error);
    });
  }

  Future<bool> fetchPosts() async {
    setState(() {
      isLoading = true;
      posts.clear();
    });

    final response = await http.get('http://192.168.1.86:8081/api/ride');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      Map data = json.decode(response.body);
      var tmp1 = data["data"];
      posts = tmp1.map((result) =>  Post.fromJson(result) ).toList();

      return true;
    } else {
      // If that call was not successful, throw an error.
      return false;
    }
  }

  /*@override
  void initState() {
    super.initState();
    fetchPosts();
  }*/
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: new Text(tmp),
            onPressed: runMyFuture ,
          ),
        ),
      body: isLoading
        ? Center(
        child: CircularProgressIndicator(),
    )
        : ListView.builder(
    itemCount: posts.length,
    itemBuilder: (BuildContext context, int index) {
    return ListTile(
    contentPadding: EdgeInsets.all(10.0),
    title: new Text("title: ${posts.elementAt(index).name}"),
      trailing: new RaisedButton(
        child: Text('Open'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondPage(),
          settings: RouteSettings(
          arguments: ScreenArguments('Extract Arguments Screen',Ride(posts.elementAt(index).id,posts.elementAt(index).name,posts.elementAt(index).location))
          ),
            )
          );
        },
      ),
    );
    })
    );
  }
}
class SecondPage extends StatefulWidget {
  SecondPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  _SecondPage createState() => _SecondPage();
}

class _SecondPage extends State<SecondPage> {
  @override

  final myController = TextEditingController();
  String tmp = "SET";
  bool isPosting = false;
  void runMyPost(String url, Map<String,String> body) {
    sendPost(url,body).then((value) {
      setState(() {
        tmp = "DONE: $value";
        isPosting = false;
      });
    }, onError: (error) {
      print(error);
    });
  }

  Future<int> sendPost(String url,  Map<String,String> bodyMap) async {
    setState(() {
      isPosting = true;
      tmp = "...";
    });
    // set up POST request arguments
   Map<String, String> headers = {"Content-type": "application/x-www-form-urlencoded"};
    //String json = '{"title": "Hello", "body": "body text", "userId": 1}';
    // make POST request

    print("Sending: $bodyMap");
    final response = await http.put(url, headers: headers, body: bodyMap);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    String body = response.body;

    print("Response status code: $statusCode  , body: $body");

    return statusCode;
  }
  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
      ),
      body: Column(children: <Widget>[
        Row(
          children: <Widget>[
            Text(myController.text+" "),
            Text(args.ride.id+" is at "),
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: TextField(
                controller: myController,
                obscureText: true,
                maxLength: 10,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: args.ride.location,
                ),
              )
            ),
            RaisedButton(
              onPressed: () {

                sendPost('http://192.168.1.86:8081/api/rides/${args.ride.id}', {"location":  myController.text} );
              },
              child: Text('Update'),
            )

          ],

        ),

        Row(
          children: <Widget>[
            Center(
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              child: Text('Go back!'),
              )
            )
          ],
        )
      ]
      )

    );
  }
}

class ScreenArguments {
  final String title;
  final Ride ride;

  ScreenArguments(this.title, this.ride);
}

class Ride {
  final String id;
  final String name;
  final String location;

  Ride(this.id,this.name, this.location);
}