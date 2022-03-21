import 'dart:io';

import 'package:book_bank/providers/authentication_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:latlng/latlng.dart';
import 'package:image_picker/image_picker.dart';
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
  late LatLng _currentPosition;
  late String _bookName, _authorName, _description;
  String? _area, _city;
  String? _mrp;
  double _percent = 4.0 / 100;
  late DateTime _dateTime;

  // Location location = Location();

  @override
  void initState() {
    super.initState();
    setState(() {
      _dateTime = DateTime.now();
    });
    // if (!kIsWeb)
    getLoc();
  }

  void _submit() async {

    print('reus ' + _imageWeb!.value.toString());
    // getLoc();
    // print("$_bookName+$_authorName+$_description+$_area+$_city+$_mrp");
    final isValid = _formKey.currentState!.validate();
    setState(() {
      if (_image != null || _imageWeb!.value!.length != 0)
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
      "image": !kIsWeb ? _image : _imageWeb,
      "latitude": !kIsWeb ? _currentPosition.latitude.toString() : '',
      "longitude": !kIsWeb ? _currentPosition.longitude.toString() : '',
      "ownerEmail":
          await Provider.of<AuthenticationManager>(context, listen: false)
              .getEmail()
    }, _imageWeb!, context);

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
                    color: imageExists ? Colors.blueAccent : Colors.red,
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
                            onPressed: !kIsWeb
                                ? () {
                                    getImage(true);
                                  }
                                : () async {
                                    // _pickImage();
                                    _imageWeb!.click();
                                    await FirebaseService()
                                        .uploadToStorage(_imageWeb!);
                                    await Future.delayed(Duration(seconds: 3));
                                    // _imageWeb!.();
                                    setState(() {
                                      _imageWebText = _imageWeb?.value;
                                      print('inside setstate $_imageWebText');
                                    });

                                    print("${_imageWeb?.value} value");
                                  },
                            padding: EdgeInsets.all(15),
                            shape: CircleBorder(),
                          ),
                      ],
                    ),
                  ),
                  !kIsWeb
                      ? _image != null
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                margin: EdgeInsets.all(8),
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
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
                              child: Text("Uded"),
                            )
                      // : _imageWeb!.value!.length != 0
                      : _imageWeb!.value!.length != 0
                          ? Container(
                              margin: EdgeInsets.all(8),
                              // height: MediaQuery.of(context).size.height * 0.25,
                              // width: MediaQuery.of(context).size.width * 0.33,
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      // _mediaInfo != null
                                      //     ? SizedBox(
                                      //         height: 200,
                                      //         width: 400,
                                      //         child: _mediaInfo)
                                      //     : Container(),
                                      Text(_imageWeb!.value!.split('\\').last),
                                    ],
                                  ),
                                  // Text("Uded"),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(100),
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
                            )
                          : Container(
                              child: Text('setstate'),
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
                  initialValue: !kIsWeb ? _area : '',
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
                  initialValue: !kIsWeb ? _city : '',
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
    try {
      var position = await GeolocatorPlatform.instance.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);

          // print("Prasad" + placemarks[0].toString());
          _area = "${placemarks[0].subLocality}";
          _city = _city ?? '${placemarks[0].locality}';
          print(_area);
          // print(_area != null || kIsWeb);
        });
      }
    } catch (err) {}
  }

  // Image Picker
  File? _image;
  html.InputElement? _imageWeb =
      html.FileUploadInputElement() as html.InputElement..accept = 'image/*';

  // String? _imageWeb?
  String? _imageWebText;

  // Image? _pickedImage;
  // MediaInfo? _mediaInfo;

  // Future<void> _pickImage() async {
  //   // final fromPicker = await ImagePickerWeb.getImageAsWidget();
  //   // print(_pickedImage == null);
  //   // if (fromPicker != null) {
  //   //   setState(() {
  //   //     _pickedImage = fromPicker;
  //   //   });
  //   // }
  //   // print(_pickedImage?.semanticLabel);
  //   // print("-");
  //   // final imagePicker = await ImagePickerWeb.getImageAsFile();
  //   // print(imagePicker?.name);
  //   //
  //   print("-");
  //   _mediaInfo = await ImagePickerWeb.getImageInfo;
  //   print(_mediaInfo?.fileName);
  //   // print(_pickedImage?.image);
  //   setState(() {});
  //   // print(_pickedImages);
  // }

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
      // ignore: unnecessary_null_comparison
      if (pickedFile != null) {
        // _images.add(File(pickedFile.path));
        if (kIsWeb) {
          _image = File(pickedFile.path);
        } else {
          _image = File(pickedFile.path);
        }
        // _image = File(pickedFile.path); // Use if you only need a single picture
      } else {
        print('No image selected.');
      }
    });
  }

  uploadToStorage() {
    print(" uploadtostorage");

    _imageWeb!.onChange.listen((event) {
      final file = _imageWeb!.files?.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file!);
      reader.onLoadEnd.listen((event) async {
        var snapshot =
            await FirebaseStorage.instance.ref().child('newfile').putBlob(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print(downloadUrl + " uploadtostorage");
      });
    });
  }
}
