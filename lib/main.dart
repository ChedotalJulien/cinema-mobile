import 'package:cinema_mobile_app/menuItem.dart';
import 'package:cinema_mobile_app/setting-page.dart';
import 'package:cinema_mobile_app/villes-page.dart';
import 'package:flutter/material.dart';
import 'package:cinema_mobile_app/app-util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './cinemas-page.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,

  theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.orange),
      ),


  home: MyApp(),

));

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> listVilles;

  final menus = [
    {'title': 'Home', 'icon': Icon (Icons.home), 'page': VillePage()},
    {'title': 'Setting', 'icon': Icon (Icons.settings), 'page': SettingPage()},
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Cinema Page "),
      ),
      body: Center(
          child: this.listVilles==null?CircularProgressIndicator():
            ListView.builder(
                itemCount: (this.listVilles==null)?0:this.listVilles.length,
                itemBuilder : (context,index){
                  return Card(
                    color: Colors.orange,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: Colors.white,
                        child: Text(this.listVilles[index]['name'],
                          style: TextStyle(
                              color: Colors.black
                          ),

                        ),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context)=> new CinemasPage(this.listVilles[index])
                          ));
                        },
                      ),
                    ),
                  );
                }

            )
        ),

      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/seydou.jpeg"),
                  radius: 50.0,
                ),
              ),
              decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.white, Colors.orange])),
            ),
            ...this.menus.map((item) {
              return Column(
                children: <Widget>[
                  Divider(color: Colors.orange),
                  MenuItem(item['title'], item['icon'], (context) {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => item['page']));
                  })
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadVilles();
  }

  void loadVilles() {
    //  String url = "http://192.168.1.5:8080/villes";
    String url = AppUtil.host+ "/villes";
    http.get(url)
        .then((resp){
      setState(() {
        this.listVilles= json.decode(resp.body)['_embedded']['villes'];
      });


    }).catchError((err){
      print(err);
    })
    ;
  }
}

