import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final picker = ImagePicker();

  XFile? pickedFile;
  Exif? exif;
  Map<String, Object>? attributes;
  DateTime? shootingDate;
  ExifLatLong? coordinates;

  @override
  void initState() {
    super.initState();
  }

  Future getImage() async {
    pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }

    exif = await Exif.fromPath(pickedFile!.path);
    attributes = await exif!.getAttributes();
    shootingDate = await exif!.getOriginalDate();
    coordinates = await exif!.getLatLong();

    debugPrint("Coordinates using native_exif package: $coordinates");

    setState(() {});
  }

  Future closeImage() async {
    await exif?.close();
    shootingDate = null;
    attributes = {};
    exif = null;
    coordinates = null;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pickedFile == null)
              const Text("Please open an image.")
            else
              Column(
                children: [
                  Text(
                      "The selected image has ${attributes?.length ?? 0} attributes."),
                  Text("It was taken at ${shootingDate.toString()}"),
                  Text(attributes?["UserComment"]?.toString() ?? ''),
                  Text("Attributes: $attributes"),
                  Text("Coordinates: $coordinates"),
                  ElevatedButton(
                    onPressed: closeImage,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    child: const Text('Close image'),
                  )
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Open image'),
            ),
          ],
        ),
      ),
    );
  }
}
