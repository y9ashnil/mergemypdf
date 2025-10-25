import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<List<File>> getFiles(List<File> files) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  if (result != null) {
    for (var file in result.files) {
      final newFile = File(file.path!);

      // Check for duplicate by name and size
      bool isDuplicate = files.any((f) =>
      f.path.split(Platform.pathSeparator).last ==
          newFile.path.split(Platform.pathSeparator).last &&
          f.lengthSync() == newFile.lengthSync());

      if (!isDuplicate) {
        files.add(newFile);
      }
    }
  }

  return files;
}