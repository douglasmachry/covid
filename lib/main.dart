// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

List<Coordinates> coordinates;
List<Marker> allMarker = [];
List<Placemark> allPlaceMarks = [];
List<DropdownMenuItem> items = [];
String selectedValue = 'Brazil';
String boxTitle = 'Title';
String boxBody = 'Body';
double pinPillPosition = -200;
double widthSearchCountry = 1;
bool _visible = false;


class _MyAppState extends State<MyApp> {
  Future<Covid> futureCovid;

  GoogleMapController mapController;
  Geocoder adresses;
  List<Country> countries;

  final LatLng _center = const LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    futureCovid = fetchCovid();
  }

  @override
  Widget build(BuildContext context) {
    Widget generalSection = Container(
        child: FutureBuilder<Covid>(
      future: futureCovid,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          countries = snapshot.data.countries;
          snapshot.data.countries.forEach((word) {
            items.add(DropdownMenuItem(
                child: Text(word.country), value: word.country));
          });

          return Text(
            "Novos casos confirmados: " +
                snapshot.data.global.newConfirmed.toString() +
                "\nTotal de casos confirmados: " +
                snapshot.data.global.totalConfirmed.toString() +
                "\nNovas mortes: " +
                snapshot.data.global.newDeaths.toString() +
                "\nTotal de mortes: " +
                snapshot.data.global.totalDeaths.toString() +
                "\nPacientes curados: " +
                snapshot.data.global.newRecovered.toString() +
                "\nTotal de pacientes curados: " +
                snapshot.data.global.totalRecovered.toString(),
            style: TextStyle(backgroundColor: Colors.yellow),
          );
        } else if (snapshot.hasError) {
          print("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    ));

    changeMarker(query) async {
      countries.forEach((word) {
        if (word.country == query) {
          setState(() {
            boxTitle = query;
            boxBody = "Casos confirmados: ${word.totalConfirmed} \n" +
                "Mortes: ${word.totalDeaths}\n" +
                "Curados: ${word.totalRecovered}";
          });
        }
      });
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      var first = addresses.first;
      MarkerId markerId = MarkerId(query);
      Marker marker = new Marker(
          markerId: markerId,
          position:
              LatLng(first.coordinates.latitude, first.coordinates.longitude));

      setState(() {
        allMarker = [];
        allMarker.add(marker);
        //pinPillPosition = 250;
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: marker.position, zoom: 4)));
      });
    }

    Visibility dropdownMenu = Visibility(
        visible: _visible,
        child: SearchableDropdown.single(
          style: TextStyle(color: Colors.white),
          items: items,
          value: selectedValue,
          hint: 'Selecione um país',
          searchHint: 'Selecione um país',
          onChanged: (value) {
            setState(() {
              selectedValue = value;
              changeMarker(value);
              pinPillPosition = -200;
            });
          },
          isExpanded: false,
        ));

    AnimatedPositioned box = AnimatedPositioned(
      bottom: pinPillPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 500),
      child: Align(
        alignment: Alignment.center,
        child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.only(left: 5),
            height: 100,
            width: 300,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      blurRadius: 20,
                      offset: Offset.zero,
                      color: Colors.black.withOpacity(0.5))
                ]),
            child: Stack(children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Text(boxTitle,
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
              Align(alignment: Alignment.centerLeft, child: Text(boxBody)),
              Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: new Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          pinPillPosition = -250;
                        });
                      }))
            ])),
      ),
    );

    AnimatedPositioned searchCountry = AnimatedPositioned(
        bottom: 20,
        left: 53,
        duration: Duration(milliseconds: 300),
        width: widthSearchCountry,
        height: 45,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.blue),
            )
    );

    Widget floatingActionButton = FloatingActionButton(
      onPressed: () {
        setState(() {
          if (widthSearchCountry == 300) {
            widthSearchCountry = 2;
            _visible = false;
          } else {
            widthSearchCountry = 300;
            _visible = true;
          }

        });
      },
      child: Icon(Icons.search),
      backgroundColor: Colors.blue,
    );

    StatefulWidget mapSection = GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 0,
      ),
      markers: Set<Marker>.of(allMarker),
      onTap: (LatLng location) {
        setState(() {
          pinPillPosition = -200;
          allMarker = [];
        });
      },
      onCameraIdle: () {
        if (allMarker.isEmpty == false) {
          setState(() {
            pinPillPosition = 250;
          });
        }
      },
    );

    Stack bodyStack() {
      return Stack(
        children: <Widget>[
          mapSection,
          generalSection,
          box,
          Positioned(bottom: 15, left: 15, child: floatingActionButton),
          searchCountry,
          Positioned(bottom: 15, left: 120, child: dropdownMenu)
        ],
      );
    }

    return MaterialApp(
      title: 'Casos de COVID-19 no mundo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('COVID-19 no Mundo'),
        ),
        body: bodyStack(),
      ),
    );
  }
}

Future<Covid> fetchCovid() async {
  final response = await http.get('https://api.covid19api.com/summary');

  if (response.statusCode == 200) {
    var covid = Covid.fromJson(json.decode(response.body));
    return covid;
  } else {
    throw Exception('Failed to load Paises');
  }
}

class Covid {
  Global global;
  List<Country> countries;

  Covid({
    this.global,
    this.countries,
  });

  factory Covid.fromJson(Map<String, dynamic> json) => Covid(
        global: Global.fromJson(json["Global"]),
        countries: List<Country>.from(
            json["Countries"].map((x) => Country.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Global": global.toJson(),
        "Countries": List<dynamic>.from(countries.map((x) => x.toJson())),
      };
}

class Country {
  String country;
  String countryCode;
  String slug;
  int newConfirmed;
  int totalConfirmed;
  int newDeaths;
  int totalDeaths;
  int newRecovered;
  int totalRecovered;
  DateTime date;

  Country({
    this.country,
    this.countryCode,
    this.slug,
    this.newConfirmed,
    this.totalConfirmed,
    this.newDeaths,
    this.totalDeaths,
    this.newRecovered,
    this.totalRecovered,
    this.date,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        country: json["Country"],
        countryCode: json["CountryCode"],
        slug: json["Slug"],
        newConfirmed: json["NewConfirmed"],
        totalConfirmed: json["TotalConfirmed"],
        newDeaths: json["NewDeaths"],
        totalDeaths: json["TotalDeaths"],
        newRecovered: json["NewRecovered"],
        totalRecovered: json["TotalRecovered"],
        date: DateTime.parse(json["Date"]),
      );

  Map<String, dynamic> toJson() => {
        "Country": country,
        "CountryCode": countryCode,
        "Slug": slug,
        "NewConfirmed": newConfirmed,
        "TotalConfirmed": totalConfirmed,
        "NewDeaths": newDeaths,
        "TotalDeaths": totalDeaths,
        "NewRecovered": newRecovered,
        "TotalRecovered": totalRecovered,
        "Date": date.toIso8601String(),
      };
}

class Global {
  int newConfirmed;
  int totalConfirmed;
  int newDeaths;
  int totalDeaths;
  int newRecovered;
  int totalRecovered;

  Global({
    this.newConfirmed,
    this.totalConfirmed,
    this.newDeaths,
    this.totalDeaths,
    this.newRecovered,
    this.totalRecovered,
  });

  factory Global.fromJson(Map<String, dynamic> json) => Global(
        newConfirmed: json["NewConfirmed"],
        totalConfirmed: json["TotalConfirmed"],
        newDeaths: json["NewDeaths"],
        totalDeaths: json["TotalDeaths"],
        newRecovered: json["NewRecovered"],
        totalRecovered: json["TotalRecovered"],
      );

  Map<String, dynamic> toJson() => {
        "NewConfirmed": newConfirmed,
        "TotalConfirmed": totalConfirmed,
        "NewDeaths": newDeaths,
        "TotalDeaths": totalDeaths,
        "NewRecovered": newRecovered,
        "TotalRecovered": totalRecovered,
      };
}
