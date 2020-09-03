import 'package:flutter/material.dart';

class VillePage extends StatefulWidget {
  @override
  _VillePageState createState() => _VillePageState();
}

class _VillePageState extends State<VillePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Villes"),
      ),
      body: Center(
        child: Text("Liste des villes"),
      ),
    );
  }
}
