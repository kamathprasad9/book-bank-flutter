import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

enum RadioButtonType { donate, slider }

class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  RadioButtonType _radioButtonType = RadioButtonType.donate;
  LocationData _currentPosition;
  String _bookName, _author, _description, _area, _city, _mrp;
  double _percent = 4.0 / 100;
  DateTime _dateTime;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    getLoc();
  }

  void _submit() async {
    // getLoc();
    print("$_bookName+$_author+$_description+$_area+$_city+$_mrp");
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
                onChanged: (value) {
                  setState(() {
                    _bookName = value;
                  });
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
                onChanged: (value) {
                  setState(() {
                    _author = value;
                  });
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
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: '255',
                  labelText: "MRP (in Rs)",
                  border: OutlineInputBorder(),
                ),
                enableSuggestions: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _mrp = value;
                  });
                },
              ),
            ),
            if (_mrp != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Type'),
                  SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: ListTile(
                            title: const Text('Donate'),
                            leading: Radio<RadioButtonType>(
                              value: RadioButtonType.donate,
                              groupValue: _radioButtonType,
                              onChanged: (RadioButtonType value) {
                                setState(() {
                                  _radioButtonType = value;
                                  print(_radioButtonType);
                                  _percent = 0;
                                });
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            children: [
                              ListTile(
                                title: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    inactiveTickMarkColor: Colors.amber,
                                  ),
                                  child: Slider(
                                    value: _percent,
                                    onChanged: (value) {
                                      setState(() {
                                        _percent = value;
                                        print(_percent);
                                      });
                                    },
                                    min: 0,
                                    max: 20,
                                    divisions: 20,
                                    label: "${_percent.round()}",
                                  ),
                                ),
                                leading: Radio<RadioButtonType>(
                                  value: RadioButtonType.slider,
                                  groupValue: _radioButtonType,
                                  onChanged: (RadioButtonType value) {
                                    setState(() {
                                      _radioButtonType = value;
                                      print(_radioButtonType);
                                    });
                                  },
                                ),
                              ),
                              if (_radioButtonType == RadioButtonType.slider)
                                Container(
                                  padding: EdgeInsets.only(left: 70),
                                  child: Text(
                                      '${_percent.round()}% of Rs. $_mrp = Rs. ${(double.parse(_mrp) * _percent / 100).round()}'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  onChanged: (value) {
                    setState(() {
                      _area = value;
                    });
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
                  onChanged: (value) {
                    setState(() {
                      _city = value;
                    });
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
              _area = _area ?? "${value.first.subLocality}";
              _city = _city ?? '${value.first.locality}';
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
