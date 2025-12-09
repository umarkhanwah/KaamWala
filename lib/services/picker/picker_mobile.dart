import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'picker_service.dart';

PickerService createPickerService() => _MobilePicker();

class _MobilePicker implements PickerService {
  final _picker = ImagePicker();

  @override
  Future<Uint8List?> pickImageBytes() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    return file.readAsBytes();
  }
}
