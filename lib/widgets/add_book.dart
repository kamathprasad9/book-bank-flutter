import 'dart:io';

import 'package:book_bank/providers/authentication_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

//services
import '../services/firebase_service.dart';

enum RadioButtonType { donate, slider }

class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool imageExists = true;
  bool isLoading = false;

  RadioButtonType _radioButtonType = RadioButtonType.donate;
  late LocationData _currentPosition;
  late String _bookName, _authorName, _description;
  String? _area, _city;
  String? _mrp;
  double _percent = 4.0 / 100;
  late DateTime _dateTime;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    setState(() {
      _dateTime = DateTime.now();
    });
    if (!kIsWeb) getLoc();
  }

  void _submit() async {
    // getLoc();
    // print("$_bookName+$_authorName+$_description+$_area+$_city+$_mrp");
    final isValid = _formKey.currentState!.validate();
    setState(() {
      if (_image != null)
        imageExists = true;
      else
        imageExists = false;
    });
    if (!isValid || !imageExists) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
      print("$isLoading isLoading");
    });
    FirebaseService firebaseService = FirebaseService();

    print(await Provider.of<AuthenticationManager>(context, listen: false)
            .getEmail() +
        "email");

    await firebaseService.postAdvertisement(<dynamic, dynamic>{
      "bookName": _bookName,
      "authorName": _authorName,
      "description": _description,
      "mrp": _mrp,
      "percentOfMRP": _radioButtonType == RadioButtonType.donate
          ? '0'
          : _percent.toString(),
      "area": _area,
      "city": _city,
      "dateOfAdvertisement": _dateTime,
      "image": _image,
      "latitude": !kIsWeb ? _currentPosition.latitude.toString() : '',
      "longitude": !kIsWeb ? _currentPosition.longitude.toString() : '',
      "ownerEmail":
          await Provider.of<AuthenticationManager>(context, listen: false)
              .getEmail()
    }, context);

    // Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
      print("$isLoading isLoading");
    });
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
              padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
              child: TextFormField(
                decoration:
                    kTextFieldDecoration.copyWith(labelText: 'Book Name'),
                enableSuggestions: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
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
                decoration:
                    kTextFieldDecoration.copyWith(labelText: 'Author Name'),
                enableSuggestions: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _authorName = value;
                  });
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                maxLines: 5,
                decoration:
                    kTextFieldDecoration.copyWith(labelText: 'Description'),
                enableSuggestions: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
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
                decoration: kTextFieldDecoration.copyWith(
                  hintText: '255',
                  labelText: "MRP (in Rs)",
                ),
                enableSuggestions: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Required";
                  } else if (double.tryParse(value) == null) {
                    return "Should only contain numbers";
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
                              onChanged: (RadioButtonType? value) {
                                setState(() {
                                  _radioButtonType = value!;
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
                                  onChanged: (RadioButtonType? value) {
                                    setState(() {
                                      _radioButtonType = value!;
                                      print(_radioButtonType);
                                    });
                                  },
                                ),
                              ),
                              if (_radioButtonType == RadioButtonType.slider)
                                Container(
                                  padding: EdgeInsets.only(left: 70),
                                  child: Text(
                                      '${_percent.round()}% of Rs. ${_mrp!} = Rs. ${(double.parse(_mrp!) * _percent / 100).round()}'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueAccent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Text('Upload Photo'),
                        if (_image == null)
                          RawMaterialButton(
                            fillColor: Theme.of(context).colorScheme.secondary,
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              color: Colors.white,
                            ),
                            elevation: 8,
                            onPressed: () {
                              getImage(true);
                            },
                            padding: EdgeInsets.all(15),
                            shape: CircleBorder(),
                          ),
                      ],
                    ),
                  ),
                  if (_image != null)
                    !kIsWeb
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              margin: EdgeInsets.all(8),
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: MediaQuery.of(context).size.width * 0.33,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _image = null;
                                      });
                                    },
                                    child: Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(_image!.absolute),
                                ),
                              ),
                            ))
                        : Container(
                            margin: EdgeInsets.all(8),
                            // height: MediaQuery.of(context).size.height * 0.25,
                            // width: MediaQuery.of(context).size.width * 0.33,
                            child: Row(
                              children: [
                                Text(_image!.path),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _image = null;
                                        });
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(),
                          ),
                ],
              ),
            ),
            if (!imageExists)
              Text(
                'Add a image',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.red),
              ),
            if (_area != null || kIsWeb)
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: kTextFieldDecoration.copyWith(labelText: 'Area'),
                  enableSuggestions: true,
                  initialValue: kIsWeb ? _area : '',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
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
            if (_city != null || kIsWeb)
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: kTextFieldDecoration.copyWith(labelText: 'City'),
                  enableSuggestions: true,
                  initialValue: kIsWeb ? _city : '',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
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
            isLoading
                ? ElevatedButton(
                    onPressed: () {},
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: 100,
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: 150,
                      height: 50,
                      child: Text(
                        isLoading ? 'Loading' : 'Post Ad',
                        style: TextStyle(fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onPressed: () {
                      _submit();
                    },
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
          // _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
          _currentPosition = currentLocation;
          _getAddress(_currentPosition.latitude!, _currentPosition.longitude!)
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

  // Image Picker
  File? _image;

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      // ignore: deprecated_member_use
      pickedFile = (await picker.getImage(
        source: ImageSource.gallery,
      ))!;
    }
    // Otherwise open camera to get new photo
    else {
      // ignore: deprecated_member_use
      pickedFile = (await picker.getImage(
        source: ImageSource.camera,
      ))!;
    }

    setState(() {
      if (pickedFile != null) {
        // _images.add(File(pickedFile.path));
        if (kIsWeb) {
          _image = File(pickedFile.path);
        } else {
          _image = File(pickedFile.path);
        }
        _image = File(pickedFile.path); // Use if you only need a single picture
      } else {
        print('No image selected.');
      }
    });
  }
}
