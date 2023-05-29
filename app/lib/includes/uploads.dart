

import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart';

Future<File> resizeImage(File file, Size size) async {
  
  // File name
  final String name = file.path.split("/").last.toLowerCase();

  // Open the image
  Image? image = decodeImage(file.readAsBytesSync());

  // Resize the image
  if(image == null) return file;

  // Resize the image
  Image resized = copyResize(image, width: size.width.toInt());

  return File(file.path)..writeAsBytesSync(encodeJpg(resized));
}

Future<File?> filePicker({ type = FileType.image }) async {
  FilePickerResult? file = await FilePicker.platform.pickFiles(type: type, allowMultiple: false);
  if (file != null) {
    return File(file.files.single.path!);
  } else {
    return null;
  }
}