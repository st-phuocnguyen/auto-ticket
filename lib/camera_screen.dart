import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:camera_test/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io' as di;

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreen();
}

class _CameraScreen extends State<CameraScreen> {
  di.File? _image;
  Position? _currentPosition;
  String? _currentAddress;
  static const apiKey = "1f8726ca89a0c445f5bc8df389eb2908";
  final _licenseController = TextEditingController();
  final _priceController = TextEditingController();
  String license = "";

  final _picker = ImagePicker();
  // Implementing the image picker
  _openImagePicker() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      _makePostRequest();
    }
  }

  _sendMessage() async {
    // if (_currentAddress != null && _image != null) {
    if (_image != null &&
        _currentAddress != null &&
        _priceController.text.isNotEmpty &&
        _licenseController.text.isNotEmpty) {
      final date = DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());
      final ref = FirebaseStorage.instance.ref().child("bien-so").child(date);

      await ref.putFile(_image!);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("Users").doc("1").update(
        {
          'client': FieldValue.arrayUnion([
            {
              'number': _licenseController.text,
              'date': date,
              'address': _currentAddress,
              'imageURL': url,
              'state': 'Chưa Thanh Toán',
              'type': dropdownValue
            }
          ]),
        },
      );
      setState(() {
        _image = null;
        _currentAddress = null;
      });
    }
  }

  _cropImage(filePath) async {
    di.File? _cropImage = await ImageCropper().cropImage(
      sourcePath: filePath,
    );
    if (_cropImage != null) {}
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            forceAndroidLocationManager: true)
        .then((Position position) {
      _currentPosition = position;
      print("{$position.latitude}");

      _makeGetRequest();
    }).catchError((e) {
      print(e);
    });
  }

  _makeGetRequest() async {
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);

    String url =
        'https://api.map4d.vn/sdk/v2/geocode?key=$apiKey&location=${_currentPosition!.latitude},${_currentPosition!.longitude}';
    var response = await http.get(Uri.parse(url));
    String json = response.body;
    Map<String, dynamic> map = jsonDecode(json);
    Address address = Address.fromJson(map);
    setState(() {
      _currentAddress = address.result![0].address;
    });
  }

  _makePostRequest() async {
    var request = http.MultipartRequest(
        "POST", Uri.parse("http://192.168.1.110:5555/div"));
    var pic = http.MultipartFile.fromBytes(
        'image', _image!.readAsBytesSync().buffer.asInt8List(),
        filename: "image_recognized.jrpg");
    request.files.add(pic);
    var response = await request.send();

    var responseData = await response.stream.toBytes();
    var result = String.fromCharCodes(responseData);

    print(result);
    if (response.statusCode == 200) {
      setState(() {
        _licenseController.text = result;
      });
    }
  }

  String dropdownValue = 'Xe Máy';

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông tin vé phạt'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                    width: double.infinity,
                    child: Text("Biển số: ${_licenseController.text}")),
                const SizedBox(height: 10),
                SizedBox(
                    width: double.infinity,
                    child: Text("Địa chỉ: $_currentAddress")),
                const SizedBox(height: 10),
                SizedBox(
                    width: double.infinity,
                    child: Text("Thành tiền: ${_priceController.text} VND")),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                      "Nhân viên thu: ${FirebaseAuth.instance.currentUser?.email}"),
                ),
                const SizedBox(height: 10),
                Image.network(
                    "http://momofree.apimienphi.com/api/QRCode?phone=0329489007&amount=${_priceController.text}& note=Thu phí giữ xe công cộng ${_priceController.text}VND"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Chấp nhận'),
              onPressed: () {
                _sendMessage();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thu phí đỗ xe'),
        actions: [
          IconButton(
            onPressed: () => {FirebaseAuth.instance.signOut()},
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey[300],
                    child: _image != null
                        ? Image.file(_image!)
                        : const Text('Biển số trống'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('Chụp ảnh biển số'),
                    onPressed: _openImagePicker,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _licenseController,
                    decoration: const InputDecoration(label: Text('Biển số')),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: _currentAddress != null
                      ? Text("Địa chỉ: ${_currentAddress!}")
                      : const Text("Địa chỉ: Trống"),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('Lấy địa chỉ'),
                    onPressed: () => {_getCurrentLocation()},
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Colors.blueAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>['Xe Máy', 'Ô tô']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                        hintText: 'Thành tiền', label: Text('Thành tiền')),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    child: const Text('Xuất thông tin vé phạt'),
                    onPressed: () => {_showMyDialog()},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
