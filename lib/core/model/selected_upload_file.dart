import 'dart:typed_data';

class SelectedUploadFile {
  const SelectedUploadFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;

  int get sizeInBytes => bytes.lengthInBytes;
}
