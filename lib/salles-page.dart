import 'package:cinema_mobile_app/app-util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SallesPage extends StatefulWidget {
  dynamic cinema;

  SallesPage(this.cinema);

  @override
  _SallesPageState createState() => _SallesPageState();
}

class _SallesPageState extends State<SallesPage> {
  List<dynamic> listSalles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salle du cinema ${widget.cinema['name']}'),
      ),
      body: Center(
        child: this.listSalles == null
            ? CircularProgressIndicator()
            : ListView.builder(
            itemCount:
            (this.listSalles == null) ? 0 : this.listSalles.length,
            itemBuilder: (context, index) {
              return Card(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: RaisedButton(
                            color: Colors.deepOrange,
                            child: Text(
                              this.listSalles[index]['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              LoadProjections(this.listSalles[index]);
                            },
                          ),
                        ),
                      ),
                      if (this.listSalles[index]['projections'] != null)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Image.network(AppUtil.host +
                                  "/imageFilm/${this
                                      .listSalles[index]['currentProjection']['film']['id']}",
                                width: 140,
                              ),
                              Column(
                                children: <Widget>[
                                  ...this.listSalles[index]['projections'].map((projection) {
                                    return RaisedButton(
                                      color:(this.listSalles[index]['currentProjection']['id'] == projection['id'])
                                      ?Colors.deepOrange : Colors.green ,
                                      child:
                                    Text(
                                        "${projection['seance']['heureDebut']} ("
                                            "Duree:${projection['film']['duree']}  "
                                            "Prix:${projection['prix']}F )",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12
                                        ),),
                                      onPressed: () {
                                        LoadTickets(projection,this.listSalles[index]);
                                      },
                                    );
                                  })
                                ],
                              )
                            ],
                          ),
                        ),
                      if(this.listSalles[index]['currentProjection'] !=null &&
                          this.listSalles[index]['currentProjection']['listTickets'] !=null
                         )
                        Column(
                          children: <Widget>[
                            Row(
                                children: <Widget>[
                                  Text("Le nombre de places disponibles: ${this.listSalles[index]['currentProjection']['nombrePlacesDisponibles']} ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18
                                  ),)
                                ],
                            ),
                               Container(
                                 padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                                 child: TextField(
                                     decoration: InputDecoration(
                                       hintText: 'Nom Du Client'
                                     ),
                                 ),
                               ),
                              Container(
                                padding: EdgeInsets.fromLTRB(6, 2, 6, 3),

                                child: TextField(
                                  decoration: InputDecoration(
                                      hintText: 'Code Paiement'
                                  ),
                                ),
                              ),
                            Container(
                              padding: EdgeInsets.fromLTRB(6, 2, 6, 3),

                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Nombre de Tickets'
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: RaisedButton(
                                color: Colors.green,
                                child: Text("Payer Tickets" ,style:
                                  TextStyle(
                                    color: Colors.white,
                                    fontSize: 24
                                  ),),
                                  onPressed:  (){
                                    //fonction reserver a faire
                                  }
                              ),
                            ),
                            Wrap(
                              children: <Widget>[
                                ...this.listSalles[index]['currentProjection']['listTickets'].map((ticket){
                                  if(ticket['reservee'] == false)
                                    return Container(

                                      width: 50,
                                      padding: EdgeInsets.all(2),
                                      child: RaisedButton(

                                        color: Colors.green,
                                        child: Text(
                                          "${ticket['place']['numero']}",

                                          style: TextStyle(
                                              color: Colors.white,
                                            fontSize: 12

                                          ),),
                                        onPressed: () {

                                        },
                                      ),
                                    );
                                  else return Container();
                                })
                              ],
                            ),
                          ],
                        ),

                    ],
                  ));
            }),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSalles();
  }

  void loadSalles() {
    String url = this.widget.cinema['_links']['salles']['href'];
    http.get(url).then((resp) {
      setState(() {
        this.listSalles = jsonDecode(resp.body)['_embedded']['salles'];
      });
    }).catchError((err) {
      print(err);
    });
  }

  void LoadProjections(salle) {
    //String url1 = AppUtil.host + "/salles/${salle['id']}/projections?projection=p1";
    String url = salle['_links']['projections']['href']
        .toString()
        .replaceAll("{?projection}", "?projection=p1");
    http.get(url).then((resp) {
      setState(() {
        salle['projections'] =
        json.decode(resp.body)['_embedded']['projections'];
        salle['currentProjection'] = salle['projections'][0];
        salle['currentProjection']['listTickets'] = [];

      });
    }).catchError((err) {
      print(err);
    });
  }


  void LoadTickets(projection,salle) {
    String url = projection['_links']['tickets']['href']
        .toString()
        .replaceAll("{?projection}", "?projection=ticketProj");
    http.get(url).then((resp) {
      setState(() {
        projection['listTickets'] =
        json.decode(resp.body)['_embedded']['tickets'];
        salle['currentProjection']= projection;
        projection['nombrePlacesDisponibles'] = nombrePlacesDisponibles(projection);
      });
    }).catchError((err) {
      print(err);
    });
  }
  nombrePlacesDisponibles(projection){
    int nombre = 0 ;
    for(int i=0;i<projection['tickets'].length;i++){
      if(projection['tickets'][i]['reservee']==false)
        ++nombre;
    }
  return nombre;
  }
}