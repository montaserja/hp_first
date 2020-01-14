import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart'; 




void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

GoogleMapController mapController;

class _MyAppState extends State<MyApp> {
  @override
  

  List<String> rooms = <String>[
    'Bronze room',
    'another Room',
    'another Room1',
    'another Room2'
  ];

  List<String> notRooms = <String>[
    'The Gym',
    'The Storage Place'
  ];

  List<String> places;
  //final List<String> instructions = <String>['floor 5', 'B', 'C'];

  var instructions = <String, String>{
    'Bronze room': "Building 10",
    'The Gym': 'bulding 1 (Rona Remon)',
    'The Storage Place': 'Bulding 3',
    'another Room' : 'dont know',
    'another Room1':'dont know',
    'another Room2':'dont know'
  };
  var cords = <String, List<double>>{
    'Bronze room': [31.916100999999998, 34.804888999999996],
    'The Gym': [31.915, 34.803111099999995],
    'The Storage Place': [31.917517999999998, 34.805492],
    'another Room' : [31.916100999999998, 34.804888999999996],
    'another Room1':[31.916100999999998, 34.804888999999996],
    'another Room2':[31.916100999999998, 34.804888999999996]
  };

  Position position;
  LatLng dest;
  static LatLng myLocation = LatLng(32.024226, 34.868592);
  Map<String, Marker> _markers = {};
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  bool first_update =false;
  // generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  double width ;
  double height;
  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) *1000;
  }

  void initState() {
    super.initState();
     //width = MediaQuery.of(context).size.width;
    // height = MediaQuery.of(context).size.height;
    places = rooms;
    Future.delayed(Duration.zero, () async {
      try {
        _setCurrentLocation();
        if(position!=null)
        myLocation = LatLng(position.latitude,position.longitude);
      }catch (e) {
        print(e);

      }
      
      
    }); 

  var geolocator = Geolocator();
var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    StreamSubscription<Position> positionStream = geolocator.getPositionStream(locationOptions).listen(
        (Position pos) {
          myLocation = LatLng(pos.latitude,pos.longitude);
          setState(() {
            if (mapController != null && myLocation!=null && first_update == false) {
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: myLocation, zoom: 11.0),
                ),
              );
            first_update = true;
          }
      
          });
          if(myLocation != null && dest !=null)
          if(calculateDistance(myLocation.latitude,myLocation.longitude,dest.latitude,dest.longitude) <= 100 ){
              print("push notification");

          }
           // print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());

           
        });


    print("init state");
    print(position);
    
  }

  _setCurrentLocation() async {
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Widget build(BuildContext context) {
    
    void setMapPins(String name) {
      setState(() {
        // source pin
        _markers["myLocation"] = Marker(
          markerId: MarkerId("myLocation"),
          position: LatLng(position.latitude,
              position.longitude), // neeeed to change to current location
          icon: BitmapDescriptor.defaultMarker,
        );
      });
    }

// set poly lines
    setPolylines(String name) async {
      List<PointLatLng> result =
          await polylinePoints?.getRouteBetweenCoordinates(
              "AIzaSyAi2cmQm8fEmAw1mPwSvZGFr2CzujYiToM",
              position.latitude,
              position.longitude,
              dest.latitude,
              dest.longitude,
              );
      if (result.isNotEmpty) {
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        result.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      setState(() {
        // create a Polyline instance
        // with an id, an RGB color and the list of LatLng pairs
        Polyline polyline = Polyline(
            polylineId: PolylineId('poly'),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates);
            
        // add the constructed polyline as a set of points
        // to the polyline set, which will eventually
        // end up showing up on the map
        _polylines.add(polyline);
      });
    }

    //add markers to the map
    void _add(String name) async {
      
      final MarkerId markerId = MarkerId(name);
      final LatLng center = LatLng(cords[name][0], cords[name][1]);
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
          center.latitude,
          center.longitude,
        ),
        infoWindow: InfoWindow(title: name, snippet: '*'),
      );
      _markers = {};
      setState(() {
        _markers[name] = marker;
      });
    }

    getLocation() async {
      await _setCurrentLocation();
        setState(() {        
          if(position != null) 
        myLocation =  LatLng(position.latitude, position.longitude);
        });        
        
        }

    setRooms() async {
      places = rooms;
          setState(() {     
           
          });        
        }

    setPlaces() async {
       places = notRooms;
        setState(() {        
        });        
      }

    Widget listSection = Container(
        height: 250.0,
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: places.length,
            itemBuilder: (BuildContext context, int index) {
              return  Card(
                      
                        child: InkWell(
                    onTap: () {
                      //print(mapController);
                      print(position.latitude);
                      if (mapController != null) {
                        dest = LatLng(
                            cords[places[index]][0], cords[places[index]][1]);
                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: dest, zoom: 11.0),
                          ),
                        );
                        mapController = mapController;
                      }
                      _polylines = {};
                      polylineCoordinates = [];
                      _add(places[index]);
                      setMapPins(places[index]);
                      setPolylines(places[index]);
                      
                    },
                    child: ListTile(
                          leading: FlutterLogo(size: 40.0),
                          title: Text('${places[index]}'),
                          subtitle: Text('${instructions[places[index]]}'),
                          
                        ),
                      )
                      ); 
            }));

    Widget mapSection = Container(
      padding: const EdgeInsets.all(15),
      height: 250.0,
      width: 600.0,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          getLocation();
          mapController = controller;
        },
        zoomGesturesEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: myLocation,
          //target: LatLng(position.latitude, position.longitude),
          zoom: 11,
        ),
        markers: Set<Marker>.of(_markers.values),
        polylines: _polylines,
      ),
    );

    openMap() async{
      //print(position.latitude);
      //print(position.longitude);
      final String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=${dest.latitude},${dest.longitude}&travelmode=walking";
      final String appleMapsUrl = "https://maps.apple.com/?q=${position.latitude},${position.longitude}";


     if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    }
    if (await canLaunch(appleMapsUrl)) {
      await launch(appleMapsUrl, forceSafariVC: false);
    } else {
      throw "Couldn't launch URL";
    }
   
    }

    Widget buttonSection = Padding(
          padding: const EdgeInsets.all(5.0),
          child:SizedBox(
  width: 400.0,
  height: 40.0,
  child: FlatButton.icon(
      color: Colors.blueGrey,
      icon: Icon(Icons.adjust), //`Icon` to display
      label: Text('Navigate'), //`Text` to display
      onPressed: () {
        print("button pressed");
        openMap();
      },
      textColor: Colors.white,
      
    ),
    ),
    );

  Widget currentLocationbtn = FlatButton.icon(
      color: Colors.lightBlue,
      icon: Icon(Icons.person), //`Icon` to display
      label: Text('Current Location'), //`Text` to display
      onPressed: () {
        if(mapController != null)
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(position.latitude,position.longitude), zoom: 11.0),
          ),
        );
      },
    );

    Widget buttonsbar = ButtonBar(
      
      buttonMinWidth: 150.0,
      buttonPadding:  const EdgeInsets.all(1),
      alignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text('Meeting Rooms'),
                  color: Colors.blueGrey,
                  onPressed: () {setRooms();},
                ),
                FlatButton(
                  child: Text('Places'),
                  color: Colors.blueGrey,
                  onPressed: () {setPlaces();},
                ),
              ],
            );

    return MaterialApp(
      title: 'HP map',
      home: Scaffold(
        appBar: AppBar(
          title: Text('HP PLACES'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Column(
          children: [
            buttonsbar,
            listSection,
            mapSection,
            //currentLocationbtn,
            buttonSection,
            
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
    );
  }
}
