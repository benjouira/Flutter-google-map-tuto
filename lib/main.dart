import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myproject/geoLocation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: '',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Position cl;
  var lat;
  var long;
  StreamSubscription<Position>? positionStream;

  // ****
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.0, 10.0),
  );
  // geolocation functions
  Future _getPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    //nchoufou idha ken location services enable wela la
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Alert !'),
          content: const Text('Location services are disabled !'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.denied) {
      getLatAndLong();
    }

    // return permission;
  }

  Future<void> getLatAndLong() async {
    cl = await getPosition();
    lat = cl.latitude;
    long = cl.longitude;
    print("***********************************");
    print("lat $lat long $long");
    // besh nakhtarou el position by default fl current position mte3na
    _kGooglePlex = CameraPosition(
      // target: LatLng(34.735723, 10.522819),
      target: LatLng(lat, long),
      zoom: 10.0,
    );
    myMarker.add(Marker(markerId: MarkerId("3"), position: LatLng(lat, long)));
    setState(() {});
  }

  Future<Position> getPosition() async {
    return await Geolocator.getCurrentPosition().then((value) => value);
  }

  // google map functions
  Completer<GoogleMapController> _controller = Completer();

  //
  @override
  void initState() {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      changeMarker(position.latitude, position.longitude);

      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
    });
    setMarkerCustomImage();
    _getPermission();
    super.initState();
  }

  GoogleMapController? gmc;

  setMarkerCustomImage() async {
    myMarker.add(Marker(
      markerId: MarkerId("2"),
      infoWindow: InfoWindow(title: "Home"),
      position: LatLng(34.735723, 10.522819),
      draggable: true,
      onDragEnd: (LatLng l) {
        print("drag end");
      },
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "images/pin.png"),
    ));
  }

  Set<Marker> myMarker = {};

  changeMarker(newLat, newLong) {
    myMarker.clear();
    myMarker.add(
        Marker(markerId: MarkerId("3"), position: LatLng(newLat, newLong)));
    // besh tkhali el map tet7arak m3a el marker
    gmc!.animateCamera(CameraUpdate.newLatLng(LatLng(newLat, newLong)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            // bima anou el _kGoolePlex besh n7otou fiha el position elli el fonction mte3ha tekhdem bl sync
            // w el await ! alors el app mte3na dima bech tekhedh null 3allouwel w tkamel bih khater el position
            // async w mazelt ma raj3etsh ntija!
            // el 7all na3mlou if 3al _kG... idha kenha null na3mlou progressIndicator ydour w wa9t twalli el
            // kG... mch null w takhedh el position wa9tha net3adou ll else w nkamlou el code mte3na fl"SizedBox"
            _kGooglePlex.zoom != 10.0
                ? const CircularProgressIndicator()
                : SizedBox(
                    height: 500,
                    width: 400,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        gmc = controller;
                      },
                      markers: myMarker,
                      onTap: (lt) {
                        myMarker.remove(Marker(markerId: MarkerId("2")));
                        myMarker
                            .add(Marker(markerId: MarkerId("2"), position: lt));
                        setState(() {});
                      },
                    ),
                  ),
            MaterialButton(
              color: Colors.teal,
              child: const Text(
                "my home !",
              ),
              onPressed: () async {
                LatLng latlong = const LatLng(34.735723, 10.522819);
                gmc!.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: latlong, zoom: 10, tilt: 45, bearing: 45)));
              },
            )
          ],
        ));
  }
}
