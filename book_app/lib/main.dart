import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "dart:convert";

void main() {
  runApp(MyApp());
}

class Book {
  final String title;
  final String author;
  final String year;
  final String isbn;
  final String imageUrl;
  final String rating;

  Book(
      {this.title,
      this.author,
      this.year,
      this.isbn,
      this.imageUrl,
      this.rating});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
        title: json["title"] as String,
        author: json["author"] as String,
        year: json["year"] as String,
        isbn: json["isbn"] as String,
        imageUrl: json["image_url"] as String,
        rating: json["average_rating"] as String);
  }
}

class GlobalState {
  final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};

  static GlobalState instance = GlobalState._();
  GlobalState._();

  set(dynamic key, dynamic value) => _data[key] = value;
  get(dynamic key) => _data[key];
}

final GlobalState store = GlobalState.instance;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Recommendation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          BookImageWidget("assets/images/BookIcon.png"),
          SizedBox(height: 30),
          Text("Enter a book you really like: ",
              style: TextStyle(fontFamily: "Merriweather", fontSize: 20)),
          SizedBox(height: 55),
          TextInputWidget(),
          SizedBox(height: 120),
          Text("A small project by Sunaabh Trivedi",
              style: TextStyle(color: Colors.white))
        ],
      ),
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("GiveMeABook"),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

class BookImageWidget extends StatelessWidget {
  final String _assetpath;

  BookImageWidget(this._assetpath);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(
          width: 250,
          height: 250,
        ),
        child: Image.asset(_assetpath));
  }
}

class RatingStars extends StatelessWidget {
  int rating;

  RatingStars(int rating) {
    this.rating = rating;
  }

  @override
  Widget build(BuildContext context) {
    switch (rating) {
      case 1:
        return Container(
          child: Row(
            children: [
              Icon(Icons.star),
              Icon(Icons.star_border),
              Icon(Icons.star_border),
              Icon(Icons.star_border),
              Icon(Icons.star_border)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );
      case 2:
        return Container(
          child: Row(
            children: [
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star_border),
              Icon(Icons.star_border),
              Icon(Icons.star_border)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );
      case 3:
        return Container(
          child: Row(
            children: [
              Icon(
                Icons.star,
              ),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star_border),
              Icon(Icons.star_border)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );
      case 4:
        return Container(
          child: Row(
            children: [
              Icon(
                Icons.star,
              ),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star_border)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );
      case 5:
        return Container(
          child: Row(
            children: [
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );
    }
  }
}

class BookInfoWidget extends StatelessWidget {
  AsyncSnapshot<dynamic> snapshot;

  BookInfoWidget(AsyncSnapshot<dynamic> snapshot) {
    this.snapshot = snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        Text(
          snapshot.data.title,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        Text("${snapshot.data.author}         ${snapshot.data.year}",
            style: TextStyle(fontSize: 14, color: Colors.white)),
        SizedBox(height: 5),
        Text("Isbn: ${snapshot.data.isbn}",
            style: TextStyle(fontSize: 14, color: Colors.white)),
        SizedBox(height: 50),
      ]),
    ]);
  }
}

class ResultPage extends StatelessWidget {
  final String text = store.get("text");

  Future<Book> getData() async {
    var response =
        await http.get("http://balistacratz.pythonanywhere.com/?name=$text");

    return Book.fromJson(jsonDecode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            FutureBuilder(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data.title == null) {
                      return Column(children: [
                        SizedBox(height: 50),
                        Center(
                            child: Container(
                          child: Image.asset("assets/images/sadFaceImage.jpg"),
                          constraints:
                              BoxConstraints.expand(height: 200, width: 200),
                        )),
                        SizedBox(height: 150),
                        Text("Sorry, book not found",
                            style: TextStyle(fontSize: 20, color: Colors.white))
                      ], mainAxisAlignment: MainAxisAlignment.center);
                    }
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        Image.network(snapshot.data.imageUrl,
                            width: 200, height: 300, fit: BoxFit.fill),
                        SizedBox(height: 50),
                        BookInfoWidget(snapshot),
                        RatingStars(double.parse(snapshot.data.rating).round()),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    );
                  } else {
                    return Column(children: <Widget>[
                      SizedBox(height: 200),
                      Text("Please wait, data is loading."),
                      SizedBox(height: 50),
                      Center(
                        child: Container(
                            constraints:
                                BoxConstraints.expand(height: 300, width: 300),
                            child:
                                Image.asset("assets/images/BookIndicator.gif")),
                      )
                    ]);
                  }
                }),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        backgroundColor: Colors.grey,
        appBar: AppBar(
            title: Text("You Might Like: "),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, false);
                })));
  }
}

class TextInputWidget extends StatefulWidget {
  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  final controller = new TextEditingController();

  Future navigateToResultsPage(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ResultPage()));
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  getText() {
    return controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: this.controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 40),
        SizedBox(
            child: RaisedButton(
              onPressed: () {
                store.set("text", getText());
                navigateToResultsPage(context);
              },
              child: Text("GO"),
              color: Colors.blue[700],
            ),
            width: 150,
            height: 50),
      ],
    );
  }
}
