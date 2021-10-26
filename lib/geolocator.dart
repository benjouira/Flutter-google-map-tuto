import 'dart:html';
import 'package:geocoding/geocoding.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorClass extends StatefulWidget {
  const GeolocatorClass({Key? key}) : super(key: key);

  @override
  _GeolocatorClassState createState() => _GeolocatorClassState();
}

class _GeolocatorClassState extends State<GeolocatorClass> {
  //services Location == Enable =>(return) True
  //services Location == Disable => False

  Future getPosition() async {
    bool services;
    LocationPermission per;
    // *************** Geo-Location services enabled check *************
    services = await Geolocator.isLocationServiceEnabled();
    if (services == false) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.BOTTOMSLIDE,
        title: "Services",
        desc: "Geo-Location Services is Not Enabled",
        btnOkOnPress: () {},
      ).show();
    }
    // *************** Geo-Location services Permission state check *************
    per = await Geolocator.checkPermission();
    print("***********");
    print(per);
    print("***********");
    if (per == LocationPermission.denied) {
      per = await Geolocator.requestPermission();
      // anwe3 el permession 4 (denied, denideForEver, whileInUse, Always)
      print(per);
      if (per == LocationPermission.whileInUse) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: "SUCCES",
          desc: "Do you want to print your Geo-Location",
          btnOkOnPress: () async {
            cl = await getLatAndLong();
            print(" latitude ${cl.latitude}");
            print(" longitude ${cl.longitude}");
            // ************ geoCoding *******
            List<Placemark> placemarks =
                await placemarkFromCoordinates(52.2165157, 6.9437819);
            print(placemarks[0].toString());
          },
          btnCancelOnPress: () {},
        ).show();
      }
    }
  }

  late Position cl;
  Future<Position> getLatAndLong() async {
    return await Geolocator.getCurrentPosition().then((value) => value);
  }

  @override
  void initState() {
    getPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geolocator Home page"),
        centerTitle: true,
      ),
    );
  }
}
