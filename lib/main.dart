import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Post {
  final String title;
  final String thumbnailUrl;
  Post({this.title, this.thumbnailUrl});
  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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


  void runMyFuture() {
    fetchPosts().then((value) {
      setState(() {
        tmp = "FETCHED : ${value}";
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

    final response = await http.get('https://jsonplaceholder.typicode.com/photos');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      List jsonList = json.decode(response.body) as List;
      setState(() {
        isLoading = false;
      });
      jsonList.map( (jl) => print("jsonElement: ${jl.toString()}"));
      posts = jsonList.map(
              (jsonElement) => Post.fromJson(jsonElement)
      ).toList();
      return true;
    } else {
      // If that call was not successful, throw an error.
      return false;
    }
  }
  String tmp = "No";
  bool isLoading = false;
  List posts = List();
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
    title: new Text("title: ${posts.elementAt(index).title}"),
      trailing: new Image.network(
        posts.elementAt(index).thumbnailUrl,
        fit: BoxFit.cover,
        height: 40.0,
        width: 40.0,
      ),
    );
    })
    );
  }
}
