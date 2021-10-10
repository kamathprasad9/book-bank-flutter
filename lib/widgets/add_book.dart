import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  LocationData _currentPosition;
  String _area, _city;
  DateTime _dateTime;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    getLoc();
  }

  void _submit() async {
    // getLoc();
    print(_dateTime);
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Book Name",
                  border: OutlineInputBorder(),
                ),
                enableSuggestions: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Author Name",
                  border: OutlineInputBorder(),
                ),
                enableSuggestions: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                enableSuggestions: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
              ),
            ),
            if (_area != null)
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Area",
                    border: OutlineInputBorder(),
                  ),
                  enableSuggestions: true,
                  initialValue: _area,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                ),
              ),
            if (_city != null)
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(),
                  ),
                  enableSuggestions: true,
                  initialValue: _city,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                ),
              ),
            ElevatedButton(
              child: Text(
                "Submit",
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              onPressed: () => _submit(),
            )
          ],
        ),
      ),
    );
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      // print("${currentLocation.longitude} : ${currentLocation.longitude}");

      if (mounted) {
        setState(() {
          _dateTime = DateTime.now();
          // _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
          _currentPosition = currentLocation;
          _getAddress(_currentPosition.latitude, _currentPosition.longitude)
              .then((value) {
            setState(() {
              print(value.first.locality); //city
              print(value.first.subLocality); //area
              _area = "${value.first.subLocality}";
              _city = '${value.first.locality}';
            });
          });
        });
      }
    });
  }

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }
}
